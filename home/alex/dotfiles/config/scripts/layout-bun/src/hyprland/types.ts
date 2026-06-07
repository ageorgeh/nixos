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

export type Direction = "l" | "r" | "u" | "d";
export type Hy3Direction = Direction;
export type MonitorSelector = number | string;
export type WorkspaceSelector = number | string;
export type PixelOrPercent = number | `${number}%`;
export type ToggleAction = "toggle" | "enable" | "disable";
export type Hy3Boolish = boolean | "true" | "false";

export interface ExactResize {
  mode: "exact";
  width: PixelOrPercent;
  height: PixelOrPercent;
}

export type ResizeSpec = ExactResize;

export type FocusArgs =
  | { direction: Direction }
  | { monitor: MonitorSelector }
  | { workspace: WorkspaceSelector; onCurrentMonitor?: boolean }
  | { window: WindowSelector }
  | { urgentOrLast: true }
  | { last: true };

export interface WindowFloatArgs {
  action?: ToggleAction;
  window?: WindowSelector;
}

export type WindowMoveArgs =
  | { direction: Direction; groupAware?: boolean; window?: WindowSelector }
  | { x: number; y: number; relative?: boolean; window?: WindowSelector }
  | { workspace: WorkspaceSelector; follow?: boolean; window?: WindowSelector }
  | { monitor: MonitorSelector; follow?: boolean; window?: WindowSelector }
  | { intoGroup: Direction; window?: WindowSelector }
  | { intoOrCreateGroup: Direction; window?: WindowSelector }
  | { outOfGroup: true | Direction; window?: WindowSelector };

export interface WindowResizeArgs {
  x: number;
  y: number;
  relative?: boolean;
  window?: WindowSelector;
}

export interface GroupActiveArgs {
  index: number;
  window?: WindowSelector;
}

export interface GroupLockActiveArgs {
  action?: ToggleAction;
}

export type Hy3GroupLayout = "h" | "v" | "tab" | "opposite";
export type Hy3GroupChange =
  | "h"
  | "v"
  | "tab"
  | "untab"
  | "toggletab"
  | "opposite";
export type Hy3FocusChange =
  | "top"
  | "bottom"
  | "raise"
  | "lower"
  | "tab"
  | "tabnode";
export type Hy3FocusTabMouseMode =
  | "ignore"
  | "prioritize_hovered"
  | "require_hovered";
export type Hy3ExpandMode =
  | "expand"
  | "shrink"
  | "base"
  | "maximize"
  | "fullscreen";
export type Hy3ExpandFullscreenMode =
  | ""
  | "intermediate_maximize"
  | "fullscreen_maximize"
  | "maximize_only";
export type Hy3LockTabMode = "" | "toggle" | "lock" | "unlock";
export type Hy3EqualizeScope = "" | "group" | "workspace";

export interface Hy3MakeGroupOptions {
  toggle?: boolean;
  ephemeral?: boolean | "force";
}

export interface Hy3MoveFocusOptions {
  visible?: boolean;
  warp?: boolean;
}

export interface Hy3ToggleFocusLayerOptions {
  warp?: boolean;
}

export interface Hy3MoveWindowOptions {
  once?: boolean;
  visible?: boolean;
}

export interface Hy3MoveToWorkspaceOptions {
  follow?: boolean;
  warp?: boolean;
}

export type Hy3FocusTabArgs =
  | {
      direction: "l" | "r" | "left" | "right";
      mouse?: Hy3FocusTabMouseMode;
      wrap?: boolean;
    }
  | {
      index: number;
      mouse?: Hy3FocusTabMouseMode;
      wrap?: boolean;
    };

export interface Hy3ExpandOptions {
  fullscreen?: Hy3ExpandFullscreenMode;
}

export interface Hy3EqualizeOptions {
  scope?: Hy3EqualizeScope;
  workspace?: boolean;
  recursive?: boolean;
}

export interface HyprRootCommands {
  exec_cmd: [command: string];
  exec_raw: [command: string];
  event: [name: string];
  focus: [args: FocusArgs];
}

export interface HyprDomainCommands {
  window: {
    float: [] | [args: WindowFloatArgs];
    move: [args: WindowMoveArgs];
    resize: [] | [args: WindowResizeArgs];
  };
  group: {
    toggle: [];
    next: [];
    prev: [];
    active: [args: GroupActiveArgs];
    lock_active: [] | [args: GroupLockActiveArgs];
  };
  hy3: {
    make_group:
      | [layout: Hy3GroupLayout]
      | [layout: Hy3GroupLayout, options: Hy3MakeGroupOptions];
    change_group: [layout: Hy3GroupChange];
    set_ephemeral: [value: Hy3Boolish];
    move_focus:
      | [direction: Hy3Direction]
      | [direction: Hy3Direction, options: Hy3MoveFocusOptions];
    toggle_focus_layer: [] | [options: Hy3ToggleFocusLayerOptions];
    warp_cursor: [];
    move_window:
      | [direction: Hy3Direction]
      | [direction: Hy3Direction, options: Hy3MoveWindowOptions];
    move_to_workspace:
      | [workspace: WorkspaceSelector]
      | [workspace: WorkspaceSelector, options: Hy3MoveToWorkspaceOptions];
    change_focus: [target: Hy3FocusChange];
    focus_tab: [args: Hy3FocusTabArgs];
    set_swallow: [value: Hy3Boolish | "toggle"];
    kill_active: [];
    expand:
      | [mode: Hy3ExpandMode]
      | [mode: Hy3ExpandMode, options: Hy3ExpandOptions];
    lock_tab: [] | [mode: Hy3LockTabMode];
    equalize: [] | [options: Hy3EqualizeOptions];
    debug_nodes: [];
  };
}
