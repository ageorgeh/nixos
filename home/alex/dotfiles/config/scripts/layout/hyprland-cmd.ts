// hyprland-cmd.ts
import net from "net";

// ──────────────────────────────────────────────────────────────────────────────
// 1.  PARAMETER HELPERS
// ──────────────────────────────────────────────────────────────────────────────
type Direction = "l" | "r" | "u" | "d" | "left" | "right" | "up" | "down";
type Bool01 = "0" | "1";
type Workspace = string; // see the Hyprland workspace grammar
type WindowRef = string; // class:, title:, address:, pid:, …
type MonitorRef = string; // current | name | +1 | -1 | …

// ──────────────────────────────────────────────────────────────────────────────
// 2.  FULL DISPATCH MAP  (every dispatcher from the doc, typed)
//     – Tuples mirror the real CLI order
//     – Where Hyprland allows “anything”, the type is `string` so you can still
//       pass literal syntax like `exact 1280 720`, `state,handle`, etc.
// ──────────────────────────────────────────────────────────────────────────────
export interface DispatchMap {
  exec: [command: string];
  execr: [command: string];
  pass: [window: WindowRef];
  sendshortcut: [mod: string, key: string, window?: WindowRef];
  sendkeystate: [
    mod: string,
    key: string,
    state: "down" | "repeat" | "up",
    window: WindowRef
  ];
  killactive: [];
  forcekillactive: [];
  closewindow: [window: WindowRef];
  killwindow: [window: WindowRef];
  signal: [signal: string];
  signalwindow: [window: WindowRef, signal: string];
  workspace: [workspace: Workspace];
  movetoworkspace:
    | [workspace: Workspace]
    | [workspace: Workspace, window: WindowRef];
  movetoworkspacesilent:
    | [workspace: Workspace]
    | [workspace: Workspace, window: WindowRef];
  togglefloating: [] | ["active"] | [window: WindowRef];
  setfloating: [] | ["active"] | [window: WindowRef];
  settiled: [] | ["active"] | [window: WindowRef];
  fullscreen: [mode: Bool01]; // 0 = fullscreen, 1 = maximise
  fullscreenstate: [
    internal: "-1" | "0" | "1" | "2" | "3",
    client: "-1" | "0" | "1" | "2" | "3"
  ];
  dpms:
    | [state: "on" | "off" | "toggle"]
    | [state: "on" | "off" | "toggle", monitor: MonitorRef];
  pin: [] | ["active"] | [window: WindowRef];
  movefocus: [direction: Direction];
  movewindow:
    | [direction: Direction]
    | [`mon:${MonitorRef}`]
    | [`mon:${MonitorRef}`, "silent"];
  swapwindow: [direction: Direction | "prev"];
  centerwindow: [] | ["1"];
  resizeactive: [params: string, params2?: string];
  moveactive: [params: string, params2?: string];
  resizewindowpixel: [params: string, window: WindowRef];
  movewindowpixel: [params: string, window: WindowRef];
  cyclenext:
    | []
    | ["prev" | "next", ...("tiled" | "floating" | "visible" | "hist")[]];
  swapnext: [] | ["prev" | "next"];
  tagwindow: [tag: string, window?: WindowRef];
  focuswindow: [window: WindowRef];
  focusmonitor: [monitor: MonitorRef];
  splitratio: [delta: string];
  movecursortocorner: [corner: Direction | "0" | "1" | "2" | "3"];
  movecursor: [x: string, y: string];
  renameworkspace: [id: string, name: string];
  exit: [];
  forcerendererreload: [];
  movecurrentworkspacetomonitor: [monitor: MonitorRef];
  focusworkspaceoncurrentmonitor: [workspace: Workspace];
  moveworkspacetomonitor: [workspace: Workspace, monitor: MonitorRef];
  swapactiveworkspaces: [monitorA: MonitorRef, monitorB: MonitorRef];
  alterzorder: ["top" | "bottom", window?: WindowRef];
  togglespecialworkspace: [] | [name: string];
  focusurgentorlast: [];
  togglegroup: [];
  changegroupactive: ["b" | "f" | `${number}`];
  focuscurrentorlast: [];
  lockgroups: ["lock" | "unlock" | "toggle"];
  lockactivegroup: ["lock" | "unlock" | "toggle"];
  moveintogroup: [direction: Direction];
  moveoutofgroup: [] | ["active"] | [window: WindowRef];
  movewindoworgroup: [direction: Direction];
  movegroupwindow: ["b" | "f"];
  denywindowfromgroup: ["on" | "off" | "toggle"];
  setignoregrouplock: ["on" | "off" | "toggle"];
  global: [name: string];
  submap: ["reset" | string];
  event: [data: string]; // emits custom event→socket2
  setprop: [window: WindowRef, property: string, value: string];
  toggleswallow: [];
}

// Convenience alias ----------------------------------------------------------
export type Dispatcher = keyof DispatchMap;

// ──────────────────────────────────────────────────────────────────────────────
// 3. COMMAND SENDER
// ──────────────────────────────────────────────────────────────────────────────
export class HyprlandCmd {
  private socketPath: string;

  constructor(instanceSignature = process.env.HYPRLAND_INSTANCE_SIGNATURE) {
    if (!instanceSignature)
      throw new Error("HYPRLAND_INSTANCE_SIGNATURE not set");
    if (!process.env.XDG_RUNTIME_DIR)
      throw new Error("XDG_RUNTIME_DIR not set");

    this.socketPath = `${process.env.XDG_RUNTIME_DIR}/hypr/${instanceSignature}/.socket.sock`;
  }

  /**
   * Type-safe wrapper around `hyprctl dispatch …`.
   *
   * ```ts
   * await cmd.dispatch('workspace', 'e+1');
   * await cmd.dispatch('movefocus', 'l');
   * ```
   *
   * Returns whatever the socket echoes back (hyprctl usually returns an empty
   * string on success).
   */
  async dispatch<K extends Dispatcher>(
    name: K,
    ...args: DispatchMap[K]
  ): Promise<string> {
    return new Promise((resolve, reject) => {
      const client = net.createConnection(this.socketPath, () => {
        const cmd = `dispatch ${name}${
          args.length ? " " + args.join(" ") : ""
        }\n`;
        console.log(`Sending command: ${cmd}\n`);
        client.write(cmd);
      });

      let data = "";
      client.on("data", (chunk) => {
        console.log("chunk", chunk.toString());
        data += chunk.toString();
      });
      client.on("close", () => {
        console.log("close", data);
        resolve(data.trim());
      });
      client.on("drain", () => {
        console.log("drain", data);
        client.end();
      });
      client.on("error", reject);
    });
  }
}
