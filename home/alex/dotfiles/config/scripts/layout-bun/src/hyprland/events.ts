export type HyprlandEvent =
  | { name: "workspace"; workspaceName: string }
  | { name: "workspacev2"; workspaceId: number; workspaceName: string }
  | { name: "focusedmon"; monitorName: string; workspaceName: string }
  | { name: "focusedmonv2"; monitorName: string; workspaceId: number }
  | { name: "activewindow"; windowClass: string; windowTitle: string }
  | { name: "activewindowv2"; windowAddress: string }
  | { name: "fullscreen"; enabled: boolean }
  | { name: "monitorremoved"; monitorName: string }
  | { name: "monitorremovedv2"; monitorId: number; monitorName: string; monitorDescription: string }
  | { name: "monitoradded"; monitorName: string }
  | { name: "monitoraddedv2"; monitorId: number; monitorName: string; monitorDescription: string }
  | { name: "createworkspace"; workspaceName: string }
  | { name: "createworkspacev2"; workspaceId: number; workspaceName: string }
  | { name: "destroyworkspace"; workspaceName: string }
  | { name: "destroyworkspacev2"; workspaceId: number; workspaceName: string }
  | { name: "moveworkspace"; workspaceName: string; monitorName: string }
  | { name: "moveworkspacev2"; workspaceId: number; workspaceName: string; monitorName: string }
  | { name: "renameworkspace"; workspaceId: number; newName: string }
  | { name: "activespecial"; workspaceName: string; monitorName: string }
  | { name: "activespecialv2"; workspaceId: number | null; workspaceName: string; monitorName: string }
  | { name: "activelayout"; keyboardName: string; layoutName: string }
  | { name: "openwindow"; windowAddress: string; workspaceName: string; windowClass: string; windowTitle: string }
  | { name: "closewindow"; windowAddress: string }
  | { name: "kill"; windowAddress: string }
  | { name: "movewindow"; windowAddress: string; workspaceName: string }
  | { name: "movewindowv2"; windowAddress: string; workspaceId: number; workspaceName: string }
  | { name: "openlayer"; namespace: string }
  | { name: "closelayer"; namespace: string }
  | { name: "submap"; submapName: string }
  | { name: "changefloatingmode"; windowAddress: string; floating: boolean }
  | { name: "urgent"; windowAddress: string }
  | { name: "screencast"; state: boolean; owner: number }
  | { name: "windowtitle"; windowAddress: string }
  | { name: "windowtitlev2"; windowAddress: string; windowTitle: string }
  | { name: "togglegroup"; enabled: boolean; handles: string[] }
  | { name: "moveintogroup"; windowAddress: string }
  | { name: "moveoutofgroup"; windowAddress: string }
  | { name: "ignoregrouplock"; enabled: boolean }
  | { name: "lockgroups"; enabled: boolean }
  | { name: "configreloaded" }
  | { name: "custom"; data: string }
  | { name: "pin"; windowAddress: string; pinned: boolean }
  | { name: "minimized"; windowAddress: string; minimized: boolean }
  | { name: "bell"; windowAddress: string }
  | { name: "unknown"; rawName: string; rawData: string };

function splitPayload(payload: string, expectedParts: number): string[] {
  if (expectedParts <= 1) {
    return [payload.trimEnd()];
  }

  const parts: string[] = [];
  let start = 0;

  for (let index = 0; index < expectedParts - 1; index += 1) {
    const separator = payload.indexOf(",", start);
    if (separator === -1) {
      parts.push(payload.slice(start).trimEnd());
      while (parts.length < expectedParts) {
        parts.push("");
      }
      return parts;
    }

    parts.push(payload.slice(start, separator).trimEnd());
    start = separator + 1;
  }

  parts.push(payload.slice(start).trimEnd());
  return parts;
}

function parseInteger(raw: string): number {
  const value = Number.parseInt(raw, 10);
  if (Number.isNaN(value)) {
    throw new Error(`Invalid integer event field: ${raw}`);
  }

  return value;
}

function parseBit(raw: string): boolean {
  if (raw === "0") {
    return false;
  }

  if (raw === "1") {
    return true;
  }

  throw new Error(`Invalid bit event field: ${raw}`);
}

export function parseHyprlandEventLine(line: string): HyprlandEvent {
  const separator = line.indexOf(">>");
  if (separator === -1) {
    return { name: "unknown", rawName: "unknown", rawData: line };
  }

  const rawName = line.slice(0, separator);
  const rawData = line.slice(separator + 2).trimEnd();

  switch (rawName) {
    case "workspace":
      return { name: rawName, workspaceName: rawData };
    case "workspacev2": {
      const [workspaceId = "", workspaceName = ""] = splitPayload(rawData, 2);
      return { name: rawName, workspaceId: parseInteger(workspaceId), workspaceName };
    }
    case "focusedmon": {
      const [monitorName = "", workspaceName = ""] = splitPayload(rawData, 2);
      return { name: rawName, monitorName, workspaceName };
    }
    case "focusedmonv2": {
      const [monitorName = "", workspaceId = ""] = splitPayload(rawData, 2);
      return { name: rawName, monitorName, workspaceId: parseInteger(workspaceId) };
    }
    case "activewindow": {
      const [windowClass = "", windowTitle = ""] = splitPayload(rawData, 2);
      return { name: rawName, windowClass, windowTitle };
    }
    case "activewindowv2":
    case "closewindow":
    case "kill":
    case "urgent":
    case "windowtitle":
    case "moveintogroup":
    case "moveoutofgroup":
      return { name: rawName, windowAddress: rawData };
    case "fullscreen":
    case "ignoregrouplock":
    case "lockgroups":
      return { name: rawName, enabled: parseBit(rawData) };
    case "monitorremoved":
    case "monitoradded":
      return { name: rawName, monitorName: rawData };
    case "monitorremovedv2":
    case "monitoraddedv2": {
      const [monitorId = "", monitorName = "", monitorDescription = ""] = splitPayload(rawData, 3);
      return {
        name: rawName,
        monitorId: parseInteger(monitorId),
        monitorName,
        monitorDescription,
      };
    }
    case "createworkspace":
    case "destroyworkspace":
      return { name: rawName, workspaceName: rawData };
    case "createworkspacev2":
    case "destroyworkspacev2": {
      const [workspaceId = "", workspaceName = ""] = splitPayload(rawData, 2);
      return { name: rawName, workspaceId: parseInteger(workspaceId), workspaceName };
    }
    case "moveworkspace": {
      const [workspaceName = "", monitorName = ""] = splitPayload(rawData, 2);
      return { name: rawName, workspaceName, monitorName };
    }
    case "moveworkspacev2": {
      const [workspaceId = "", workspaceName = "", monitorName = ""] = splitPayload(rawData, 3);
      return { name: rawName, workspaceId: parseInteger(workspaceId), workspaceName, monitorName };
    }
    case "renameworkspace": {
      const [workspaceId = "", newName = ""] = splitPayload(rawData, 2);
      return { name: rawName, workspaceId: parseInteger(workspaceId), newName };
    }
    case "activespecial": {
      const [workspaceName = "", monitorName = ""] = splitPayload(rawData, 2);
      return { name: rawName, workspaceName, monitorName };
    }
    case "activespecialv2": {
      const [workspaceId = "", workspaceName = "", monitorName = ""] = splitPayload(rawData, 3);
      return {
        name: rawName,
        workspaceId: workspaceId === "" ? null : parseInteger(workspaceId),
        workspaceName,
        monitorName,
      };
    }
    case "activelayout": {
      const [keyboardName = "", layoutName = ""] = splitPayload(rawData, 2);
      return { name: rawName, keyboardName, layoutName };
    }
    case "openwindow": {
      const [windowAddress = "", workspaceName = "", windowClass = "", windowTitle = ""] = splitPayload(rawData, 4);
      return { name: rawName, windowAddress, workspaceName, windowClass, windowTitle };
    }
    case "movewindow": {
      const [windowAddress = "", workspaceName = ""] = splitPayload(rawData, 2);
      return { name: rawName, windowAddress, workspaceName };
    }
    case "movewindowv2": {
      const [windowAddress = "", workspaceId = "", workspaceName = ""] = splitPayload(rawData, 3);
      return {
        name: rawName,
        windowAddress,
        workspaceId: parseInteger(workspaceId),
        workspaceName,
      };
    }
    case "openlayer":
    case "closelayer":
      return { name: rawName, namespace: rawData };
    case "submap":
      return { name: rawName, submapName: rawData };
    case "changefloatingmode": {
      const [windowAddress = "", floating = ""] = splitPayload(rawData, 2);
      return { name: rawName, windowAddress, floating: parseBit(floating) };
    }
    case "screencast": {
      const [state = "", owner = ""] = splitPayload(rawData, 2);
      return { name: rawName, state: parseBit(state), owner: parseInteger(owner) };
    }
    case "windowtitlev2": {
      const [windowAddress = "", windowTitle = ""] = splitPayload(rawData, 2);
      return { name: rawName, windowAddress, windowTitle };
    }
    case "togglegroup": {
      const [enabled = "", ...handles] = splitPayload(rawData, Math.max(2, rawData.split(",").length));
      return { name: rawName, enabled: parseBit(enabled), handles: handles.filter(Boolean) };
    }
    case "configreloaded":
      return { name: rawName };
    case "custom":
      return { name: rawName, data: rawData };
    case "pin": {
      const [windowAddress = "", pinned = ""] = splitPayload(rawData, 2);
      return { name: rawName, windowAddress, pinned: parseBit(pinned) };
    }
    case "minimized": {
      const [windowAddress = "", minimized = ""] = splitPayload(rawData, 2);
      return { name: rawName, windowAddress, minimized: parseBit(minimized) };
    }
    case "bell":
      return { name: rawName, windowAddress: rawData };
    default:
      return { name: "unknown", rawName, rawData };
  }
}
