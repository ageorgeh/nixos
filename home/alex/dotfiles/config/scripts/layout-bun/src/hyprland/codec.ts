import type {
  HyprClient,
  HyprCursorPosition,
  HyprMonitor,
  HyprWorkspace,
  HyprWorkspaceRef,
} from "./types";

type JsonObject = Record<string, unknown>;

function fail(path: string, expected: string, value: unknown): never {
  throw new Error(`Invalid Hyprland payload at ${path}: expected ${expected}, received ${JSON.stringify(value)}`);
}

function asObject(value: unknown, path: string): JsonObject {
  if (typeof value !== "object" || value === null || Array.isArray(value)) {
    fail(path, "object", value);
  }

  return value as JsonObject;
}

function asString(value: unknown, path: string): string {
  if (typeof value !== "string") {
    fail(path, "string", value);
  }

  return value;
}

function asNumber(value: unknown, path: string): number {
  if (typeof value !== "number" || Number.isNaN(value)) {
    fail(path, "number", value);
  }

  return value;
}

function asBoolean(value: unknown, path: string): boolean {
  if (typeof value !== "boolean") {
    fail(path, "boolean", value);
  }

  return value;
}

function asTuple4(value: unknown, path: string): [number, number, number, number] {
  if (!Array.isArray(value) || value.length !== 4) {
    fail(path, "tuple[4]", value);
  }

  return [
    asNumber(value[0], `${path}[0]`),
    asNumber(value[1], `${path}[1]`),
    asNumber(value[2], `${path}[2]`),
    asNumber(value[3], `${path}[3]`),
  ];
}

function asTuple2(value: unknown, path: string): [number, number] {
  if (!Array.isArray(value) || value.length !== 2) {
    fail(path, "tuple[2]", value);
  }

  return [
    asNumber(value[0], `${path}[0]`),
    asNumber(value[1], `${path}[1]`),
  ];
}

function asStringArray(value: unknown, path: string): string[] {
  if (!Array.isArray(value)) {
    fail(path, "string[]", value);
  }

  return value.map((item, index) => asString(item, `${path}[${index}]`));
}

function asNullableStringArray(value: unknown, path: string): string[] | null {
  if (value === null) {
    return null;
  }

  return asStringArray(value, path);
}

function decodeWorkspaceRef(value: unknown, path: string): HyprWorkspaceRef {
  const object = asObject(value, path);

  return {
    id: asNumber(object.id, `${path}.id`),
    name: asString(object.name, `${path}.name`),
  };
}

function decodeClient(value: unknown, path: string): HyprClient {
  const object = asObject(value, path);

  return {
    address: asString(object.address, `${path}.address`) as HyprClient["address"],
    mapped: asBoolean(object.mapped, `${path}.mapped`),
    hidden: asBoolean(object.hidden, `${path}.hidden`),
    at: asTuple2(object.at, `${path}.at`),
    size: asTuple2(object.size, `${path}.size`),
    workspace: decodeWorkspaceRef(object.workspace, `${path}.workspace`),
    floating: asBoolean(object.floating, `${path}.floating`),
    monitor: asNumber(object.monitor, `${path}.monitor`),
    class: asString(object.class, `${path}.class`),
    title: asString(object.title, `${path}.title`),
    initialClass: asString(object.initialClass, `${path}.initialClass`),
    initialTitle: asString(object.initialTitle, `${path}.initialTitle`),
    pid: asNumber(object.pid, `${path}.pid`),
    xwayland: asBoolean(object.xwayland, `${path}.xwayland`),
    pinned: asBoolean(object.pinned, `${path}.pinned`),
    fullscreen: asNumber(object.fullscreen, `${path}.fullscreen`),
    fullscreenClient: asNumber(object.fullscreenClient, `${path}.fullscreenClient`),
    overFullscreen: asBoolean(object.overFullscreen, `${path}.overFullscreen`),
    grouped: asStringArray(object.grouped, `${path}.grouped`) as HyprClient["grouped"],
    tags: asStringArray(object.tags, `${path}.tags`),
    swallowing: asString(object.swallowing, `${path}.swallowing`),
    focusHistoryID: asNumber(object.focusHistoryID, `${path}.focusHistoryID`),
    inhibitingIdle: asBoolean(object.inhibitingIdle, `${path}.inhibitingIdle`),
    xdgTag: asString(object.xdgTag, `${path}.xdgTag`),
    xdgDescription: asString(object.xdgDescription, `${path}.xdgDescription`),
    contentType: asString(object.contentType, `${path}.contentType`),
    stableId: asString(object.stableId, `${path}.stableId`),
  };
}

function decodeMonitor(value: unknown, path: string): HyprMonitor {
  const object = asObject(value, path);

  return {
    id: asNumber(object.id, `${path}.id`),
    name: asString(object.name, `${path}.name`),
    description: asString(object.description, `${path}.description`),
    make: asString(object.make, `${path}.make`),
    model: asString(object.model, `${path}.model`),
    serial: asString(object.serial, `${path}.serial`),
    width: asNumber(object.width, `${path}.width`),
    height: asNumber(object.height, `${path}.height`),
    physicalWidth: asNumber(object.physicalWidth, `${path}.physicalWidth`),
    physicalHeight: asNumber(object.physicalHeight, `${path}.physicalHeight`),
    refreshRate: asNumber(object.refreshRate, `${path}.refreshRate`),
    x: asNumber(object.x, `${path}.x`),
    y: asNumber(object.y, `${path}.y`),
    activeWorkspace: decodeWorkspaceRef(object.activeWorkspace, `${path}.activeWorkspace`),
    specialWorkspace: decodeWorkspaceRef(object.specialWorkspace, `${path}.specialWorkspace`),
    reserved: asTuple4(object.reserved, `${path}.reserved`),
    scale: asNumber(object.scale, `${path}.scale`),
    transform: asNumber(object.transform, `${path}.transform`),
    focused: asBoolean(object.focused, `${path}.focused`),
    dpmsStatus: asBoolean(object.dpmsStatus, `${path}.dpmsStatus`),
    vrr: asBoolean(object.vrr, `${path}.vrr`),
    solitary: asString(object.solitary, `${path}.solitary`),
    solitaryBlockedBy: asNullableStringArray(object.solitaryBlockedBy, `${path}.solitaryBlockedBy`),
    activelyTearing: asBoolean(object.activelyTearing, `${path}.activelyTearing`),
    tearingBlockedBy: asNullableStringArray(object.tearingBlockedBy, `${path}.tearingBlockedBy`),
    directScanoutTo: asString(object.directScanoutTo, `${path}.directScanoutTo`),
    directScanoutBlockedBy: asNullableStringArray(object.directScanoutBlockedBy, `${path}.directScanoutBlockedBy`),
    disabled: asBoolean(object.disabled, `${path}.disabled`),
    currentFormat: asString(object.currentFormat, `${path}.currentFormat`),
    mirrorOf: asString(object.mirrorOf, `${path}.mirrorOf`),
    availableModes: asStringArray(object.availableModes, `${path}.availableModes`),
    colorManagementPreset: asString(object.colorManagementPreset, `${path}.colorManagementPreset`),
    sdrBrightness: asNumber(object.sdrBrightness, `${path}.sdrBrightness`),
    sdrSaturation: asNumber(object.sdrSaturation, `${path}.sdrSaturation`),
    sdrMinLuminance: asNumber(object.sdrMinLuminance, `${path}.sdrMinLuminance`),
    sdrMaxLuminance: asNumber(object.sdrMaxLuminance, `${path}.sdrMaxLuminance`),
  };
}

function decodeWorkspace(value: unknown, path: string): HyprWorkspace {
  const object = asObject(value, path);

  return {
    id: asNumber(object.id, `${path}.id`),
    name: asString(object.name, `${path}.name`),
    monitor: asString(object.monitor, `${path}.monitor`),
    monitorID: asNumber(object.monitorID, `${path}.monitorID`),
    windows: asNumber(object.windows, `${path}.windows`),
    hasfullscreen: asBoolean(object.hasfullscreen, `${path}.hasfullscreen`),
    lastwindow: asString(object.lastwindow, `${path}.lastwindow`) as HyprWorkspace["lastwindow"],
    lastwindowtitle: asString(object.lastwindowtitle, `${path}.lastwindowtitle`),
    ispersistent: asBoolean(object.ispersistent, `${path}.ispersistent`),
    tiledLayout: asString(object.tiledLayout, `${path}.tiledLayout`),
  };
}

export function decodeHyprMonitorList(value: unknown): HyprMonitor[] {
  if (!Array.isArray(value)) {
    fail("monitors", "HyprMonitor[]", value);
  }

  return value.map((item, index) => decodeMonitor(item, `monitors[${index}]`));
}

export function decodeHyprClientList(value: unknown): HyprClient[] {
  if (!Array.isArray(value)) {
    fail("clients", "HyprClient[]", value);
  }

  return value.map((item, index) => decodeClient(item, `clients[${index}]`));
}

export function decodeHyprClientOrNull(value: unknown): HyprClient | null {
  if (typeof value === "object" && value !== null && !Array.isArray(value) && Object.keys(value).length === 0) {
    return null;
  }

  return decodeClient(value, "activewindow");
}

export function decodeHyprWorkspaceList(value: unknown): HyprWorkspace[] {
  if (!Array.isArray(value)) {
    fail("workspaces", "HyprWorkspace[]", value);
  }

  return value.map((item, index) => decodeWorkspace(item, `workspaces[${index}]`));
}

export function decodeHyprWorkspace(value: unknown): HyprWorkspace {
  return decodeWorkspace(value, "workspace");
}

export function decodeHyprCursorPosition(value: unknown): HyprCursorPosition {
  const object = asObject(value, "cursorpos");

  return {
    x: asNumber(object.x, "cursorpos.x"),
    y: asNumber(object.y, "cursorpos.y"),
  };
}
