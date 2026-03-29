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

interface RequestBridgeResponse {
  id: number;
  ok: boolean;
  response?: string;
  error?: string;
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

function formatDispatcherArgs(dispatcher: keyof HyprDispatchers, args: readonly unknown[]): string {
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

class NodeRequestBridge {
  private readonly socketPath: string;
  private child: ReturnType<typeof spawn> | null = null;
  private responseReader: ReturnType<typeof createInterface> | null = null;
  private stderr = "";
  private nextId = 1;
  private readonly pending = new Map<
    number,
    {
      resolve: (value: string) => void;
      reject: (error: unknown) => void;
    }
  >();

  constructor(socketPath: string) {
    this.socketPath = socketPath;
  }

  private ensureStarted(): void {
    if (this.child && this.child.exitCode === null) {
      return;
    }

    const child = spawn(
      NODE_BINARY,
      [NODE_HELPER_PATH, "request-loop", this.socketPath],
      {
        stdio: ["pipe", "pipe", "pipe"],
      },
    );

    if (!child.stdin || !child.stdout || !child.stderr) {
      throw new Error("Node request bridge did not expose stdio.");
    }

    child.stdout.setEncoding("utf8");
    child.stderr.setEncoding("utf8");

    this.stderr = "";
    child.stderr.on("data", (chunk: string) => {
      this.stderr += chunk;
    });

    const responseReader = createInterface({
      input: child.stdout,
      crlfDelay: Infinity,
    });

    void (async () => {
      try {
        for await (const line of responseReader) {
          if (line === "") {
            continue;
          }

          const message = JSON.parse(line) as RequestBridgeResponse;
          const pending = this.pending.get(message.id);
          if (!pending) {
            continue;
          }

          this.pending.delete(message.id);
          if (message.ok) {
            pending.resolve(message.response ?? "");
          } else {
            pending.reject(new Error(message.error ?? "Unknown bridge request error."));
          }
        }
      } catch (error) {
        this.rejectAll(error);
      }
    })();

    child.on("error", (error) => {
      this.rejectAll(error);
    });

    child.on("close", () => {
      const error = new Error(
        this.stderr === ""
          ? "Node request bridge exited unexpectedly."
          : this.stderr.trim(),
      );
      this.rejectAll(error);
      responseReader.close();
      this.responseReader = null;
      this.child = null;
    });

    this.child = child;
    this.responseReader = responseReader;
  }

  private rejectAll(error: unknown): void {
    for (const pending of this.pending.values()) {
      pending.reject(error);
    }
    this.pending.clear();
  }

  async request(payload: string): Promise<string> {
    this.ensureStarted();

    const child = this.child;
    if (!child?.stdin) {
      throw new Error("Node request bridge is not writable.");
    }

    const id = this.nextId;
    this.nextId += 1;

    const stdin = child.stdin;
    return await new Promise<string>((resolve, reject) => {
      this.pending.set(id, { resolve, reject });
      const message = `${JSON.stringify({ id, payload })}\n`;
      stdin.write(message, "utf8", (error) => {
        if (error) {
          this.pending.delete(id);
          reject(error);
        }
      });
    });
  }

  close(): void {
    this.responseReader?.close();
    this.responseReader = null;

    if (this.child?.stdin && !this.child.stdin.destroyed) {
      this.child.stdin.end();
    }
    if (this.child && this.child.exitCode === null) {
      this.child.kill();
    }
    this.child = null;
  }
}

export class HyprlandClient {
  readonly instanceSignature: string;
  readonly runtimeDir: string;
  readonly requestSocketPath: string;
  readonly eventSocketPath: string;
  private readonly requestBridge: NodeRequestBridge;

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
    this.requestBridge = new NodeRequestBridge(this.requestSocketPath);
  }

  async requestRaw(command: string, flags?: RequestFlags): Promise<string> {
    const request = buildRequest(command, flags);
    try {
      return await this.requestBridge.request(request);
    } catch (error) {
      const message = error instanceof Error ? error.message : String(error);
      throw new HyprlandError(
        `Node IPC helper failed for ${request}`,
        request,
        message,
      );
    }
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

  close(): void {
    this.requestBridge.close();
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
