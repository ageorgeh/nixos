"""Invoke normal Resolve Edit-page commands on this Hyprland workstation.

Timeline inspection, In/Out marks and result verification use Resolve's API.
This adapter only supplies the keyboard commands that API does not expose.
"""
import argparse
import json
import os
from pathlib import Path
import subprocess
import time
import xml.etree.ElementTree as ET


def run(action, project):
    env = dict(os.environ)
    # Resolve's FHS libraries are incompatible with host Hyprland binaries.
    env.pop("LD_LIBRARY_PATH", None)
    env.pop("LD_PRELOAD", None)

    def hypr(*args):
        result = subprocess.run(["hyprctl", *args], env=env, capture_output=True,
                                encoding="utf-8", timeout=5, check=True)
        return result.stdout

    instances = json.loads(hypr("instances", "-j"))
    assert len(instances) == 1, "Expected one Hyprland session"
    instance = instances[0]["instance"]

    def ipc(*args):
        return hypr("-i", instance, *args)

    clients = json.loads(ipc("-j", "clients"))
    windows = [w for w in clients if w["class"] == "resolve"]
    assert len(windows) == 1, "Close Resolve dialogs before native editing"
    window = windows[0]
    assert window["title"] == "DaVinci Resolve Studio - " + project, "Resolve project changed"
    address = window["address"]
    preset = Path.home() / ".local/share/DaVinciResolve/configs/keyboard.preset.xml"
    if preset.exists():
        root = ET.parse(preset).getroot()
        assert not (root.findtext("PresetListBA") or "").strip(), \
            "Custom Resolve keyboard presets need explicit shortcut calibration"

    def dispatch(expression):
        assert ipc("dispatch", expression).strip() == "ok", "Hyprland command failed"

    def focused():
        return json.loads(ipc("-j", "activewindow")).get("address") == address

    def key(mods, key):
        assert focused(), "Resolve lost focus; native edit cancelled"
        dispatch("hl.dsp.send_shortcut({mods=" + json.dumps(mods) + ",key=" + json.dumps(key) +
                 ",window=" + json.dumps("address:" + address) + "})")
        time.sleep(.08)

    if action == "prepare":
        dispatch("hl.dsp.focus({window=" + json.dumps("address:" + address) + "})")
        key("CTRL", "4")  # Workspace > Active Panel Selection > Timeline
        key("CTRL SHIFT", "a")  # Edit > Deselect All
    elif action == "ripple-delete":
        key("SHIFT", "BackSpace")  # Edit > Ripple Delete, using the marked range
    elif action == "undo":
        key("CTRL", "z")
    else:
        assert action == "ready", "Unknown editor command"
    return {"available": True, "backend": "hyprland", "project": project,
            "action": action, "window": address}


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("action", choices=("ready", "prepare", "ripple-delete", "undo"))
    parser.add_argument("--project", required=True)
    args = parser.parse_args()
    print(json.dumps(run(args.action, args.project)))
