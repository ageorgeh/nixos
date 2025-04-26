// hyprland-ipc.ts
import net from "net";
import { EventEmitter } from "events";
import readline from "readline";

// List all events based on the spec you posted
export interface HyprlandEvents {
  workspace: [workspaceName: string];
  workspacev2: [workspaceId: string, workspaceName: string];
  focusedmon: [monitorName: string, workspaceName: string];
  focusedmonv2: [monitorName: string, workspaceId: string];
  activewindow: [windowClass: string, windowTitle: string];
  activewindowv2: [windowAddress: string];
  fullscreen: [state: "0" | "1"];
  monitorremoved: [monitorName: string];
  monitoradded: [monitorName: string];
  monitoraddedv2: [
    monitorId: string,
    monitorName: string,
    monitorDescription: string
  ];
  createworkspace: [workspaceName: string];
  createworkspacev2: [workspaceId: string, workspaceName: string];
  destroyworkspace: [workspaceName: string];
  destroyworkspacev2: [workspaceId: string, workspaceName: string];
  moveworkspace: [workspaceName: string, monitorName: string];
  moveworkspacev2: [
    workspaceId: string,
    workspaceName: string,
    monitorName: string
  ];
  renameworkspace: [workspaceId: string, newName: string];
  activespecial: [workspaceName: string, monitorName: string];
  activespecialv2: [
    workspaceId: string,
    workspaceName: string,
    monitorName: string
  ];
  activelayout: [keyboardName: string, layoutName: string];
  openwindow: [
    windowAddress: string,
    workspaceName: string,
    windowClass: string,
    windowTitle: string
  ];
  closewindow: [windowAddress: string];
  movewindow: [windowAddress: string, workspaceName: string];
  movewindowv2: [
    windowAddress: string,
    workspaceId: string,
    workspaceName: string
  ];
  openlayer: [namespace: string];
  closelayer: [namespace: string];
  submap: [submapName: string];
  changefloatingmode: [windowAddress: string, floating: "0" | "1"];
  urgent: [windowAddress: string];
  screencast: [state: "0" | "1", owner: "0" | "1"];
  windowtitle: [windowAddress: string];
  windowtitlev2: [windowAddress: string, windowTitle: string];
  togglegroup: [state: "0" | "1", ...windowAddresses: string[]];
  moveintogroup: [windowAddress: string];
  moveoutofgroup: [windowAddress: string];
  ignoregrouplock: ["0" | "1"];
  lockgroups: ["0" | "1"];
  configreloaded: [];
  pin: [windowAddress: string, pinState: "0" | "1"];
  minimized: [windowAddress: string, minimized: "0" | "1"];

  error: [error: Error];
  disconnect: [];
}

type HyprlandEventName = keyof HyprlandEvents;

export class HyprlandIPC extends EventEmitter {
  private socketPath: string;
  private client?: net.Socket;

  constructor(instanceSignature = process.env.HYPRLAND_INSTANCE_SIGNATURE) {
    super();
    if (!instanceSignature)
      throw new Error("HYPRLAND_INSTANCE_SIGNATURE not set");
    if (!process.env.XDG_RUNTIME_DIR)
      throw new Error("XDG_RUNTIME_DIR not set");
    this.socketPath = `${process.env.XDG_RUNTIME_DIR}/hypr/${instanceSignature}/.socket2.sock`;
    this.connect();
  }

  private connect() {
    this.client = net.createConnection(this.socketPath);
    const rl = readline.createInterface({ input: this.client! });

    rl.on("line", (line) => {
      const [evt, payload] = line.split(">>");
      if (!evt) return;
      const args = payload?.trim().split(",") ?? [];
      this.emit(evt as HyprlandEventName, ...args);
    });

    this.client.on("error", (err) => this.emit("error", err));
    this.client.on("close", () => {
      this.emit("disconnect");
      setTimeout(() => this.connect(), 1000);
    });
  }

  public override on<K extends HyprlandEventName>(
    event: K,
    listener: (...args: HyprlandEvents[K]) => void
  ): this {
    return super.on(event, listener);
  }

  public override off<K extends HyprlandEventName>(
    event: K,
    listener: (...args: HyprlandEvents[K]) => void
  ): this {
    return super.off(event, listener);
  }

  public close() {
    this.client?.end();
  }
}
