export type HyprAddress = `0x${string}`;
export type HyprScalar = string | number;
export type MatchPattern = RegExp | string;

export interface HyprWorkspaceRef {
  id: number;
  name: string;
}

export interface HyprMonitor {
  id: number;
  name: string;
  description: string;
  make: string;
  model: string;
  serial: string;
  width: number;
  height: number;
  physicalWidth: number;
  physicalHeight: number;
  refreshRate: number;
  x: number;
  y: number;
  activeWorkspace: HyprWorkspaceRef;
  specialWorkspace: HyprWorkspaceRef;
  reserved: [number, number, number, number];
  scale: number;
  transform: number;
  focused: boolean;
  dpmsStatus: boolean;
  vrr: boolean;
  solitary: string;
  solitaryBlockedBy: string[] | null;
  activelyTearing: boolean;
  tearingBlockedBy: string[] | null;
  directScanoutTo: string;
  directScanoutBlockedBy: string[] | null;
  disabled: boolean;
  currentFormat: string;
  mirrorOf: string;
  availableModes: string[];
  colorManagementPreset: string;
  sdrBrightness: number;
  sdrSaturation: number;
  sdrMinLuminance: number;
  sdrMaxLuminance: number;
}

export interface HyprClient {
  address: HyprAddress;
  mapped: boolean;
  hidden: boolean;
  at: [number, number];
  size: [number, number];
  workspace: HyprWorkspaceRef;
  floating: boolean;
  monitor: number;
  class: string;
  title: string;
  initialClass: string;
  initialTitle: string;
  pid: number;
  xwayland: boolean;
  pinned: boolean;
  fullscreen: number;
  fullscreenClient: number;
  overFullscreen: boolean;
  grouped: HyprAddress[];
  tags: string[];
  swallowing: string;
  focusHistoryID: number;
  inhibitingIdle: boolean;
  xdgTag: string;
  xdgDescription: string;
  contentType: string;
  stableId: string;
}

export interface HyprWorkspace {
  id: number;
  name: string;
  monitor: string;
  monitorID: number;
  windows: number;
  hasfullscreen: boolean;
  lastwindow: HyprAddress;
  lastwindowtitle: string;
  ispersistent: boolean;
  tiledLayout: string;
}

export interface HyprCursorPosition {
  x: number;
  y: number;
}

export interface WindowMatcher {
  title?: MatchPattern;
  initialTitle?: MatchPattern;
  class?: MatchPattern;
  initialClass?: MatchPattern;
  commandName?: MatchPattern;
  xwayland?: boolean;
}

export type WindowSelector =
  | { type: "address"; value: HyprAddress }
  | { type: "pid"; value: number }
  | { type: "class"; value: string }
  | { type: "initialClass"; value: string }
  | { type: "title"; value: string }
  | { type: "initialTitle"; value: string }
  | { type: "tag"; value: string }
  | { type: "activewindow" }
  | { type: "floating" }
  | { type: "tiled" };

export type ActiveWindowSelector = WindowSelector | "active";
export type Direction = "l" | "r" | "u" | "d";
export type MonitorSelector = number | string;
export type PixelOrPercent = number | `${number}%`;

export interface ExactResize {
  mode: "exact";
  width: PixelOrPercent;
  height: PixelOrPercent;
}

export type ResizeSpec = ExactResize;

export interface HyprDispatchers {
  exec: [command: string];
  execr: [command: string];
  focuswindow: [selector: WindowSelector];
  focusmonitor: [monitor: MonitorSelector];
  movewindow: [target: Direction | { monitor: MonitorSelector; silent?: boolean }];
  setfloating: [] | [selector: ActiveWindowSelector];
  settiled: [] | [selector: ActiveWindowSelector];
  resizewindowpixel: [resize: ResizeSpec, selector: WindowSelector];
  togglegroup: [];
  changegroupactive: ["b" | "f" | number];
  lockgroups: ["lock" | "unlock" | "toggle"];
  moveintogroup: [direction: Direction];
  moveoutofgroup: [] | [selector: ActiveWindowSelector];
}
