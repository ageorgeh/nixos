import { spawn } from "node:child_process";
import { createInterface } from "node:readline";
import { fileURLToPath } from "node:url";

import {
  decodeHyprClientList,
  decodeHyprClientOrNull,
  decodeHyprCursorPosition,
  decodeHyprMonitorList,
  decodeHyprWorkspace,
  decodeHyprWorkspaceList,
} from "./codec";
import { parseHyprlandEventLine, type HyprlandEvent } from "./events";
import type {
  ActiveWindowSelector,
  HyprClient,
  HyprCursorPosition,
  HyprDispatchers,
  HyprMonitor,
  HyprWorkspace,
  MonitorSelector,
  ResizeSpec,
  WindowSelector,
} from "./types";

interface RequestFlags {
  json?: boolean;
  refresh?: boolean;
  all?: boolean;
  config?: boolean;
}

const NODE_BINARY = "node";
const NODE_HELPER_PATH = fileURLToPath(
  new URL("./node-ipc-helper.mjs", import.meta.url),
);

export class HyprlandError extends Error {
  constructor(
    message: string,
    readonly request: string,
    readonly response?: string,
  ) {
    super(message);
  }
}

function formatFlags(flags: RequestFlags | undefined): string {
  if (!flags) {
    return "";
  }

  let prefix = "";
  if (flags.json) {
    prefix += "j";
  }
  if (flags.refresh) {
    prefix += "r";
  }
  if (flags.all) {
    prefix += "a";
  }
  if (flags.config) {
    prefix += "c";
  }

  return prefix;
}

function buildRequest(command: string, flags?: RequestFlags): string {
  const prefix = formatFlags(flags);
  return prefix === "" ? command : `${prefix}/${command}`;
}

function formatMonitorSelector(selector: MonitorSelector): string {
  return String(selector);
}

function formatWindowSelector(selector: WindowSelector): string {
  switch (selector.type) {
    case "address":
    case "class":
    case "initialClass":
    case "title":
    case "initialTitle":
    case "tag":
      return `${selector.type === "initialClass" ? "initialclass" : selector.type === "initialTitle" ? "initialtitle" : selector.type}:${selector.value}`;
    case "pid":
      return `pid:${selector.value}`;
    case "activewindow":
    case "floating":
    case "tiled":
      return selector.type;
  }
}

function formatActiveWindowSelector(
  selector: ActiveWindowSelector | undefined,
): string {
  if (selector === undefined) {
    return "";
  }

  if (selector === "active") {
    return "active";
  }

  return formatWindowSelector(selector);
}

function formatResizeSpec(resize: ResizeSpec): string {
  if (resize.mode === "exact") {
    return `exact ${resize.width} ${resize.height}`;
  }

  return "";
}

function formatDispatcherArgs(
  dispatcher: keyof HyprDispatchers,
  args: readonly unknown[],
): string {
  switch (dispatcher) {
    case "exec":
    case "execr":
    case "focusmonitor":
      return String(args[0] ?? "");
    case "focuswindow":
      return formatWindowSelector(args[0] as WindowSelector);
    case "movewindow": {
      const target = args[0] as HyprDispatchers["movewindow"][0];
      if (typeof target === "string") {
        return target;
      }

      const suffix = target.silent ? " silent" : "";
      return `mon:${formatMonitorSelector(target.monitor)}${suffix}`;
    }
    case "setfloating":
    case "settiled":
    case "moveoutofgroup":
      return formatActiveWindowSelector(
        args[0] as ActiveWindowSelector | undefined,
      );
    case "resizewindowpixel": {
      const resize = args[0] as ResizeSpec;
      const selector = args[1] as WindowSelector;
      return `${formatResizeSpec(resize)}, ${formatWindowSelector(selector)}`;
    }
    case "togglegroup":
      return "";
    case "changegroupactive":
    case "lockgroups":
    case "moveintogroup":
      return String(args[0]);
  }
}

async function runNodeHelper(
  mode: "request" | "events",
  socketPath: string,
  payload?: string,
  signal?: AbortSignal,
): Promise<{
  child: ReturnType<typeof spawn>;
  stdout: string;
  stderr: string;
  exitCode: number;
}> {
  const args = [NODE_HELPER_PATH, mode, socketPath];
  if (payload !== undefined) {
    args.push(payload);
  }

  const child = spawn(NODE_BINARY, args, {
    stdio: ["ignore", "pipe", "pipe"],
    signal,
  });

  let stdout = "";
  let stderr = "";

  child.stdout?.setEncoding("utf8");
  child.stdout?.on("data", (chunk: string) => {
    stdout += chunk;
  });

  child.stderr?.setEncoding("utf8");
  child.stderr?.on("data", (chunk: string) => {
    stderr += chunk;
  });

  const exitCode = await new Promise<number>((resolve, reject) => {
    child.on("error", reject);
    child.on("close", (code) => {
      resolve(code ?? 0);
    });
  });

  return { child, stdout, stderr, exitCode };
}

export class HyprlandClient {
  readonly instanceSignature: string;
  readonly runtimeDir: string;
  readonly requestSocketPath: string;
  readonly eventSocketPath: string;

  constructor(options?: { instanceSignature?: string; runtimeDir?: string }) {
    this.instanceSignature =
      options?.instanceSignature ??
      process.env.HYPRLAND_INSTANCE_SIGNATURE ??
      "";
    this.runtimeDir = options?.runtimeDir ?? process.env.XDG_RUNTIME_DIR ?? "";

    if (this.instanceSignature === "") {
      throw new Error("HYPRLAND_INSTANCE_SIGNATURE is not set.");
    }

    if (this.runtimeDir === "") {
      throw new Error("XDG_RUNTIME_DIR is not set.");
    }

    this.requestSocketPath = `${this.runtimeDir}/hypr/${this.instanceSignature}/.socket.sock`;
    this.eventSocketPath = `${this.runtimeDir}/hypr/${this.instanceSignature}/.socket2.sock`;
  }

  async requestRaw(command: string, flags?: RequestFlags): Promise<string> {
    const request = buildRequest(command, flags);
    const result = await runNodeHelper(
      "request",
      this.requestSocketPath,
      request,
    );

    if (result.exitCode !== 0) {
      throw new HyprlandError(
        `Node IPC helper failed for ${request}`,
        request,
        result.stderr,
      );
    }

    return result.stdout;
  }

  async requestJson<T>(
    command: string,
    decode: (value: unknown) => T,
    flags?: Omit<RequestFlags, "json">,
  ): Promise<T> {
    const requestFlags: RequestFlags = { json: true };
    if (flags?.refresh !== undefined) {
      requestFlags.refresh = flags.refresh;
    }
    if (flags?.all !== undefined) {
      requestFlags.all = flags.all;
    }
    if (flags?.config !== undefined) {
      requestFlags.config = flags.config;
    }
    const raw = await this.requestRaw(command, requestFlags);

    let parsed: unknown;
    try {
      parsed = JSON.parse(raw);
    } catch (error) {
      throw new HyprlandError(
        `Hyprland returned non-JSON data for ${command}`,
        buildRequest(command, requestFlags),
        raw,
      );
    }

    try {
      return decode(parsed);
    } catch (error) {
      const message = error instanceof Error ? error.message : String(error);
      throw new HyprlandError(
        message,
        buildRequest(command, requestFlags),
        raw,
      );
    }
  }

  async batch(commands: string[]): Promise<string[]> {
    if (commands.length === 0) {
      return [];
    }

    const raw = await this.requestRaw(
      `[[BATCH]]${commands.join(" ; ")}`,
    );
    return raw.split("\n\n\n");
  }

  async monitors(options?: { all?: boolean }): Promise<HyprMonitor[]> {
    const command = options?.all ? "monitors all" : "monitors";
    return await this.requestJson(command, decodeHyprMonitorList);
  }

  async clients(options?: { all?: boolean }): Promise<HyprClient[]> {
    return await this.requestJson(
      "clients",
      decodeHyprClientList,
      options?.all ? { all: true } : undefined,
    );
  }

  async activeWindow(): Promise<HyprClient | null> {
    return await this.requestJson("activewindow", decodeHyprClientOrNull);
  }

  async workspaces(): Promise<HyprWorkspace[]> {
    return await this.requestJson("workspaces", decodeHyprWorkspaceList);
  }

  async activeWorkspace(): Promise<HyprWorkspace> {
    return await this.requestJson("activeworkspace", decodeHyprWorkspace);
  }

  async cursorPosition(): Promise<HyprCursorPosition> {
    return await this.requestJson("cursorpos", decodeHyprCursorPosition);
  }

  async dispatch<K extends keyof HyprDispatchers>(
    dispatcher: K,
    ...args: HyprDispatchers[K]
  ): Promise<string> {
    const serializedArgs = formatDispatcherArgs(dispatcher, args);
    const command =
      serializedArgs === ""
        ? `dispatch ${dispatcher}`
        : `dispatch ${dispatcher} ${serializedArgs}`;
    return await this.requestRaw(command);
  }

  async dispatchRaw(dispatcher: string, args?: string): Promise<string> {
    const command =
      args && args !== ""
        ? `dispatch ${dispatcher} ${args}`
        : `dispatch ${dispatcher}`;
    return await this.requestRaw(command);
  }

  async focusWindow(selector: WindowSelector): Promise<void> {
    await this.dispatch("focuswindow", selector);
  }

  async focusMonitor(selector: MonitorSelector): Promise<void> {
    await this.dispatch("focusmonitor", selector);
  }

  async setTiled(selector?: ActiveWindowSelector): Promise<void> {
    if (selector === undefined) {
      await this.dispatch("settiled");
      return;
    }

    await this.dispatch("settiled", selector);
  }

  async setFloating(selector?: ActiveWindowSelector): Promise<void> {
    if (selector === undefined) {
      await this.dispatch("setfloating");
      return;
    }

    await this.dispatch("setfloating", selector);
  }

  async moveActiveWindowToMonitor(
    monitor: MonitorSelector,
    options?: { silent?: boolean },
  ): Promise<void> {
    if (options?.silent === undefined) {
      await this.dispatch("movewindow", { monitor });
      return;
    }

    await this.dispatch("movewindow", { monitor, silent: options.silent });
  }

  async resizeWindowPixel(
    resize: ResizeSpec,
    selector: WindowSelector,
  ): Promise<void> {
    await this.dispatch("resizewindowpixel", resize, selector);
  }

  async exec(command: string): Promise<void> {
    await this.dispatch("exec", command);
  }

  async *events(signal?: AbortSignal): AsyncGenerator<HyprlandEvent> {
    const child = spawn(
      NODE_BINARY,
      [NODE_HELPER_PATH, "events", this.eventSocketPath],
      {
        stdio: ["ignore", "pipe", "pipe"],
        signal,
      },
    );

    if (!child.stdout) {
      throw new HyprlandError(
        "Node IPC helper did not expose stdout for events.",
        "events",
      );
    }

    if (!child.stderr) {
      throw new HyprlandError(
        "Node IPC helper did not expose stderr for events.",
        "events",
      );
    }

    child.stdout.setEncoding("utf8");
    child.stderr.setEncoding("utf8");

    let stderr = "";
    child.stderr.on("data", (chunk: string) => {
      stderr += chunk;
    });

    const reader = createInterface({
      input: child.stdout,
      crlfDelay: Infinity,
    });

    const abort = () => {
      child.kill();
      reader.close();
    };

    signal?.addEventListener("abort", abort, { once: true });

    try {
      for await (const line of reader) {
        if (signal?.aborted) {
          break;
        }

        yield parseHyprlandEventLine(line);
      }
    } finally {
      signal?.removeEventListener("abort", abort);
      reader.close();
      child.kill();
      const exitCode = await new Promise<number>((resolve) => {
        child.once("close", (code) => resolve(code ?? 0));
      });
      if (!signal?.aborted && exitCode !== 0) {
        throw new HyprlandError(
          "Node IPC helper failed while streaming events.",
          "events",
          stderr,
        );
      }
    }
  }
}
