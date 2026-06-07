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
  Direction,
  FocusArgs,
  GroupActiveArgs,
  Hy3Boolish,
  HyprDomainCommands,
  Hy3Direction,
  Hy3EqualizeOptions,
  Hy3ExpandMode,
  Hy3ExpandOptions,
  Hy3FocusTabArgs,
  Hy3FocusChange,
  Hy3GroupChange,
  Hy3GroupLayout,
  Hy3LockTabMode,
  Hy3MakeGroupOptions,
  Hy3MoveFocusOptions,
  Hy3MoveToWorkspaceOptions,
  Hy3MoveWindowOptions,
  Hy3ToggleFocusLayerOptions,
  GroupLockActiveArgs,
  HyprClient,
  HyprCursorPosition,
  HyprMonitor,
  HyprRootCommands,
  HyprWorkspace,
  MonitorSelector,
  ToggleAction,
  WindowFloatArgs,
  WindowMoveArgs,
  WindowResizeArgs,
  WindowSelector,
  WorkspaceSelector,
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

function formatLuaString(value: string): string {
  return JSON.stringify(value);
}

function formatLuaScalar(value: string | number | boolean): string {
  if (typeof value === "string") {
    return formatLuaString(value);
  }

  return String(value);
}

function formatLuaTable(
  entries: ReadonlyArray<readonly [key: string, value: string | undefined]>,
): string {
  const parts = entries
    .filter(
      (entry): entry is readonly [string, string] => entry[1] !== undefined,
    )
    .map(([key, value]) => `${key} = ${value}`);

  return `{ ${parts.join(", ")} }`;
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

function formatLuaWindowSelector(selector: WindowSelector): string {
  return formatLuaString(formatWindowSelector(selector));
}

function formatLuaOptionalWindowSelector(
  selector: WindowSelector | undefined,
): string | undefined {
  if (selector === undefined) {
    return undefined;
  }

  return formatLuaWindowSelector(selector);
}

function formatLuaMonitorSelector(selector: MonitorSelector): string {
  if (typeof selector === "number") {
    return String(selector);
  }

  return formatLuaString(formatMonitorSelector(selector));
}

function formatLuaWorkspaceSelector(selector: WorkspaceSelector): string {
  if (typeof selector === "number") {
    return String(selector);
  }

  return formatLuaString(String(selector));
}

function formatLuaDirection(direction: Direction): string {
  return formatLuaString(direction);
}

function formatToggleActionValue(action: ToggleAction): string {
  switch (action) {
    case "enable":
      return formatLuaString("enable");
    case "disable":
      return formatLuaString("disable");
    case "toggle":
      return formatLuaString("toggle");
  }
}

function buildFocusExpression(args: FocusArgs): string {
  if ("direction" in args) {
    return `hl.dsp.focus(${formatLuaTable([
      ["direction", formatLuaDirection(args.direction)],
    ])})`;
  }

  if ("monitor" in args) {
    return `hl.dsp.focus(${formatLuaTable([
      ["monitor", formatLuaMonitorSelector(args.monitor)],
    ])})`;
  }

  if ("workspace" in args) {
    return `hl.dsp.focus(${formatLuaTable([
      ["workspace", formatLuaWorkspaceSelector(args.workspace)],
      ["on_current_monitor", args.onCurrentMonitor ? "true" : undefined],
    ])})`;
  }

  if ("window" in args) {
    return `hl.dsp.focus(${formatLuaTable([
      ["window", formatLuaWindowSelector(args.window)],
    ])})`;
  }

  if ("urgentOrLast" in args) {
    return `hl.dsp.focus(${formatLuaTable([["urgent_or_last", "true"]])})`;
  }

  return `hl.dsp.focus(${formatLuaTable([["last", "true"]])})`;
}

function buildWindowFloatExpression(args?: WindowFloatArgs): string {
  if (!args || Object.keys(args).length === 0) {
    return "hl.dsp.window.float()";
  }

  return `hl.dsp.window.float(${formatLuaTable([
    ["action", args.action ? formatToggleActionValue(args.action) : undefined],
    ["window", formatLuaOptionalWindowSelector(args.window)],
  ])})`;
}

function buildWindowMoveExpression(args: WindowMoveArgs): string {
  if ("direction" in args) {
    return `hl.dsp.window.move(${formatLuaTable([
      ["direction", formatLuaDirection(args.direction)],
      ["group_aware", args.groupAware ? "true" : undefined],
      ["window", formatLuaOptionalWindowSelector(args.window)],
    ])})`;
  }

  if ("x" in args && "y" in args) {
    return `hl.dsp.window.move(${formatLuaTable([
      ["x", formatLuaScalar(args.x)],
      ["y", formatLuaScalar(args.y)],
      ["relative", args.relative ? "true" : undefined],
      ["window", formatLuaOptionalWindowSelector(args.window)],
    ])})`;
  }

  if ("workspace" in args) {
    return `hl.dsp.window.move(${formatLuaTable([
      ["workspace", formatLuaWorkspaceSelector(args.workspace)],
      ["follow", args.follow === false ? "false" : undefined],
      ["window", formatLuaOptionalWindowSelector(args.window)],
    ])})`;
  }

  if ("monitor" in args) {
    return `hl.dsp.window.move(${formatLuaTable([
      ["monitor", formatLuaMonitorSelector(args.monitor)],
      ["follow", args.follow === false ? "false" : undefined],
      ["window", formatLuaOptionalWindowSelector(args.window)],
    ])})`;
  }

  if ("intoGroup" in args) {
    return `hl.dsp.window.move(${formatLuaTable([
      ["into_group", formatLuaDirection(args.intoGroup)],
      ["window", formatLuaOptionalWindowSelector(args.window)],
    ])})`;
  }

  if ("intoOrCreateGroup" in args) {
    return `hl.dsp.window.move(${formatLuaTable([
      ["into_or_create_group", formatLuaDirection(args.intoOrCreateGroup)],
      ["window", formatLuaOptionalWindowSelector(args.window)],
    ])})`;
  }

  return `hl.dsp.window.move(${formatLuaTable([
    [
      "out_of_group",
      args.outOfGroup === true ? "true" : formatLuaDirection(args.outOfGroup),
    ],
    ["window", formatLuaOptionalWindowSelector(args.window)],
  ])})`;
}

function buildWindowResizeExpression(args?: WindowResizeArgs): string {
  if (!args) {
    return "hl.dsp.window.resize()";
  }

  return `hl.dsp.window.resize(${formatLuaTable([
    ["x", formatLuaScalar(args.x)],
    ["y", formatLuaScalar(args.y)],
    ["relative", args.relative ? "true" : undefined],
    ["window", formatLuaOptionalWindowSelector(args.window)],
  ])})`;
}

function buildGroupActiveExpression(args: GroupActiveArgs): string {
  return `hl.dsp.group.active(${formatLuaTable([
    ["index", formatLuaScalar(args.index)],
    ["window", formatLuaOptionalWindowSelector(args.window)],
  ])})`;
}

function buildGroupLockActiveExpression(args?: GroupLockActiveArgs): string {
  if (!args || args.action === undefined) {
    return "hl.dsp.group.lock_active()";
  }

  return `hl.dsp.group.lock_active(${formatLuaTable([
    ["action", formatToggleActionValue(args.action)],
  ])})`;
}

function formatLuaBoolish(value: Hy3Boolish | "toggle"): string {
  return typeof value === "boolean" ? String(value) : formatLuaString(value);
}

function buildHy3MakeGroupExpression(
  layout: Hy3GroupLayout,
  options?: Hy3MakeGroupOptions,
): string {
  if (!options) {
    return `hl.plugin.hy3.make_group(${formatLuaString(layout)})`;
  }

  return `hl.plugin.hy3.make_group(${formatLuaString(layout)}, ${formatLuaTable(
    [
      [
        "toggle",
        options.toggle === undefined ? undefined : String(options.toggle),
      ],
      [
        "ephemeral",
        options.ephemeral === undefined
          ? undefined
          : typeof options.ephemeral === "boolean"
            ? String(options.ephemeral)
            : formatLuaString(options.ephemeral),
      ],
    ],
  )})`;
}

function buildHy3MoveFocusExpression(
  direction: Hy3Direction,
  options?: Hy3MoveFocusOptions,
): string {
  if (!options) {
    return `hl.plugin.hy3.move_focus(${formatLuaString(direction)})`;
  }

  return `hl.plugin.hy3.move_focus(${formatLuaString(direction)}, ${formatLuaTable(
    [
      [
        "visible",
        options.visible === undefined ? undefined : String(options.visible),
      ],
      ["warp", options.warp === undefined ? undefined : String(options.warp)],
    ],
  )})`;
}

function buildHy3ToggleFocusLayerExpression(
  options?: Hy3ToggleFocusLayerOptions,
): string {
  if (!options) {
    return "hl.plugin.hy3.toggle_focus_layer()";
  }

  return `hl.plugin.hy3.toggle_focus_layer(${formatLuaTable([
    ["warp", options.warp === undefined ? undefined : String(options.warp)],
  ])})`;
}

function buildHy3MoveWindowExpression(
  direction: Hy3Direction,
  options?: Hy3MoveWindowOptions,
): string {
  if (!options) {
    return `hl.plugin.hy3.move_window(${formatLuaString(direction)})`;
  }

  return `hl.plugin.hy3.move_window(${formatLuaString(direction)}, ${formatLuaTable(
    [
      ["once", options.once === undefined ? undefined : String(options.once)],
      [
        "visible",
        options.visible === undefined ? undefined : String(options.visible),
      ],
    ],
  )})`;
}

function buildHy3MoveToWorkspaceExpression(
  workspace: WorkspaceSelector,
  options?: Hy3MoveToWorkspaceOptions,
): string {
  const workspaceValue = formatLuaWorkspaceSelector(workspace);
  if (!options) {
    return `hl.plugin.hy3.move_to_workspace(${workspaceValue})`;
  }

  return `hl.plugin.hy3.move_to_workspace(${workspaceValue}, ${formatLuaTable([
    [
      "follow",
      options.follow === undefined ? undefined : String(options.follow),
    ],
    ["warp", options.warp === undefined ? undefined : String(options.warp)],
  ])})`;
}

function buildHy3FocusTabExpression(args: Hy3FocusTabArgs): string {
  if ("direction" in args) {
    return `hl.plugin.hy3.focus_tab(${formatLuaTable([
      ["direction", formatLuaString(args.direction)],
      ["mouse", args.mouse ? formatLuaString(args.mouse) : undefined],
      ["wrap", args.wrap === undefined ? undefined : String(args.wrap)],
    ])})`;
  }

  return `hl.plugin.hy3.focus_tab(${formatLuaTable([
    ["index", formatLuaScalar(args.index)],
    ["mouse", args.mouse ? formatLuaString(args.mouse) : undefined],
    ["wrap", args.wrap === undefined ? undefined : String(args.wrap)],
  ])})`;
}

function buildHy3ExpandExpression(
  mode: Hy3ExpandMode,
  options?: Hy3ExpandOptions,
): string {
  if (!options) {
    return `hl.plugin.hy3.expand(${formatLuaString(mode)})`;
  }

  return `hl.plugin.hy3.expand(${formatLuaString(mode)}, ${formatLuaTable([
    [
      "fullscreen",
      options.fullscreen === undefined
        ? undefined
        : formatLuaString(options.fullscreen),
    ],
  ])})`;
}

function buildHy3EqualizeExpression(options?: Hy3EqualizeOptions): string {
  if (!options) {
    return "hl.plugin.hy3.equalize()";
  }

  return `hl.plugin.hy3.equalize(${formatLuaTable([
    [
      "scope",
      options.scope === undefined ? undefined : formatLuaString(options.scope),
    ],
    [
      "workspace",
      options.workspace === undefined ? undefined : String(options.workspace),
    ],
    [
      "recursive",
      options.recursive === undefined ? undefined : String(options.recursive),
    ],
  ])})`;
}

type RootCommand = keyof HyprRootCommands;
type CommandDomain = keyof HyprDomainCommands;
type DomainMethod<D extends CommandDomain> = keyof HyprDomainCommands[D];
type CommandArgs<T> = T extends readonly unknown[] ? T : never;
const ROOT_COMMANDS = new Set<RootCommand>([
  "exec_cmd",
  "exec_raw",
  "event",
  "focus",
]);

function buildLuaRootCommandExpression(
  command: RootCommand,
  args: readonly unknown[],
): string {
  switch (command) {
    case "exec_cmd":
      return `hl.dsp.exec_cmd(${formatLuaString(String(args[0] ?? ""))})`;
    case "exec_raw":
      return `hl.dsp.exec_raw(${formatLuaString(String(args[0] ?? ""))})`;
    case "event":
      return `hl.dsp.event(${formatLuaString(String(args[0] ?? ""))})`;
    case "focus":
      return buildFocusExpression(args[0] as FocusArgs);
  }

  throw new Error(`Unhandled Hyprland root command: ${String(command)}`);
}

function buildLuaDomainCommandExpression<D extends CommandDomain>(
  domain: D,
  method: DomainMethod<D>,
  args: readonly unknown[],
): string {
  if (domain === "window") {
    switch (method) {
      case "float":
        return buildWindowFloatExpression(
          args[0] as WindowFloatArgs | undefined,
        );
      case "move":
        return buildWindowMoveExpression(args[0] as WindowMoveArgs);
      case "resize":
        return buildWindowResizeExpression(
          args[0] as WindowResizeArgs | undefined,
        );
    }
  }

  if (domain === "hy3") {
    switch (method) {
      case "make_group":
        return buildHy3MakeGroupExpression(
          args[0] as Hy3GroupLayout,
          args[1] as Hy3MakeGroupOptions | undefined,
        );
      case "change_group":
        return `hl.plugin.hy3.change_group(${formatLuaString(args[0] as Hy3GroupChange)})`;
      case "set_ephemeral":
        return `hl.plugin.hy3.set_ephemeral(${formatLuaBoolish(args[0] as Hy3Boolish)})`;
      case "move_focus":
        return buildHy3MoveFocusExpression(
          args[0] as Hy3Direction,
          args[1] as Hy3MoveFocusOptions | undefined,
        );
      case "toggle_focus_layer":
        return buildHy3ToggleFocusLayerExpression(
          args[0] as Hy3ToggleFocusLayerOptions | undefined,
        );
      case "warp_cursor":
        return "hl.plugin.hy3.warp_cursor()";
      case "move_window":
        return buildHy3MoveWindowExpression(
          args[0] as Hy3Direction,
          args[1] as Hy3MoveWindowOptions | undefined,
        );
      case "move_to_workspace":
        return buildHy3MoveToWorkspaceExpression(
          args[0] as WorkspaceSelector,
          args[1] as Hy3MoveToWorkspaceOptions | undefined,
        );
      case "change_focus":
        return `hl.plugin.hy3.change_focus(${formatLuaString(args[0] as Hy3FocusChange)})`;
      case "focus_tab":
        return buildHy3FocusTabExpression(args[0] as Hy3FocusTabArgs);
      case "set_swallow":
        return `hl.plugin.hy3.set_swallow(${formatLuaBoolish(args[0] as Hy3Boolish | "toggle")})`;
      case "kill_active":
        return "hl.plugin.hy3.kill_active()";
      case "expand":
        return buildHy3ExpandExpression(
          args[0] as Hy3ExpandMode,
          args[1] as Hy3ExpandOptions | undefined,
        );
      case "lock_tab":
        if (args[0] === undefined) {
          return "hl.plugin.hy3.lock_tab()";
        }
        return `hl.plugin.hy3.lock_tab(${formatLuaString(args[0] as Hy3LockTabMode)})`;
      case "equalize":
        return buildHy3EqualizeExpression(
          args[0] as Hy3EqualizeOptions | undefined,
        );
      case "debug_nodes":
        return "hl.plugin.hy3.debug_nodes()";
    }
  }

  switch (method) {
    case "toggle":
      return "hl.dsp.group.toggle()";
    case "next":
      return "hl.dsp.group.next()";
    case "prev":
      return "hl.dsp.group.prev()";
    case "active":
      return buildGroupActiveExpression(args[0] as GroupActiveArgs);
    case "lock_active":
      return buildGroupLockActiveExpression(
        args[0] as GroupLockActiveArgs | undefined,
      );
  }

  throw new Error(
    `Unhandled Hyprland domain command: ${String(domain)}.${String(method)}`,
  );
}

function buildLuaDispatchExpression(
  commandOrDomain: RootCommand | CommandDomain,
  methodOrArg?: unknown,
  ...restArgs: readonly unknown[]
): string {
  if (ROOT_COMMANDS.has(commandOrDomain as RootCommand)) {
    const rootCommand = commandOrDomain as RootCommand;
    const rootArgs =
      methodOrArg === undefined ? [] : [methodOrArg, ...restArgs];
    return buildLuaRootCommandExpression(rootCommand, rootArgs);
  }

  return buildLuaDomainCommandExpression(
    commandOrDomain as CommandDomain,
    methodOrArg as never,
    restArgs,
  );
}

function buildLuaDispatchCommand(expression: string): string {
  return `eval hl.dispatch(${expression})`;
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
            pending.reject(
              new Error(message.error ?? "Unknown bridge request error."),
            );
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

    const raw = await this.requestRaw(`[[BATCH]]${commands.join(" ; ")}`);
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

  async command<K extends keyof HyprRootCommands>(
    command: K,
    ...args: CommandArgs<HyprRootCommands[K]>
  ): Promise<string>;
  async command<
    D extends keyof HyprDomainCommands,
    M extends keyof HyprDomainCommands[D],
  >(
    domain: D,
    method: M,
    ...args: CommandArgs<HyprDomainCommands[D][M]>
  ): Promise<string>;
  async command(
    commandOrDomain: RootCommand | CommandDomain,
    methodOrArg?: unknown,
    ...restArgs: readonly unknown[]
  ): Promise<string> {
    const expression = buildLuaDispatchExpression(
      commandOrDomain,
      methodOrArg,
      ...restArgs,
    );
    return await this.requestRaw(buildLuaDispatchCommand(expression));
  }

  buildCommand<K extends keyof HyprRootCommands>(
    command: K,
    ...args: CommandArgs<HyprRootCommands[K]>
  ): string;
  buildCommand<
    D extends keyof HyprDomainCommands,
    M extends keyof HyprDomainCommands[D],
  >(
    domain: D,
    method: M,
    ...args: CommandArgs<HyprDomainCommands[D][M]>
  ): string;
  buildCommand(
    commandOrDomain: RootCommand | CommandDomain,
    methodOrArg?: unknown,
    ...restArgs: readonly unknown[]
  ): string {
    const expression = buildLuaDispatchExpression(
      commandOrDomain,
      methodOrArg,
      ...restArgs,
    );
    return buildLuaDispatchCommand(expression);
  }

  async dispatchRaw(dispatcher: string, args?: string): Promise<string> {
    const command =
      args && args !== ""
        ? `dispatch ${dispatcher} ${args}`
        : `dispatch ${dispatcher}`;
    return await this.requestRaw(command);
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
