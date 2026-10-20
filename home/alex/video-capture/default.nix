{
  pkgs,
  obs,
  homeDirectory,
}:
let
  editor = pkgs.writeShellApplication {
    name = "cms-resolve-editor";
    runtimeInputs = [ pkgs.hyprland ];
    text = ''
      unset LD_LIBRARY_PATH LD_PRELOAD
      exec ${pkgs.python3}/bin/python3 ${./resolve-editor.py} "$@"
    '';
  };
  workspaceConfig = ./workspace.lua;
  firefoxSettings = import ./firefox-settings.nix;
  firefoxPrefs = pkgs.writeText "cms-recording-user.js" (
    pkgs.lib.concatStringsSep "\n" (
      pkgs.lib.mapAttrsToList (
        key: value: "user_pref(${builtins.toJSON key}, ${builtins.toJSON value});"
      ) firefoxSettings
    )
    + "\n"
  );
  # Refresh the opt-in profile, but seed the scene only once so OBS can retain capture permissions and source state.
  capture = pkgs.writeShellApplication {
    name = "cms-video-capture";
    runtimeInputs = [
      pkgs.coreutils
      pkgs.gnused
      pkgs.procps
      pkgs.hyprland
      pkgs.jq
      pkgs.pipewire
      pkgs.uwsm
      obs
    ];
    text = ''
      prepare_only=false
      if [[ "''${1:-}" == --prepare-only ]]; then prepare_only=true; shift; fi
      if [[ $# != 1 || ! "$1" =~ ^[a-z0-9][a-z0-9_-]{0,79}$ ]]; then
        echo 'Usage: cms-video-capture [--prepare-only] <video-id>' >&2
        exit 1
      fi
      if pgrep -u "$(id -u)" -x 'obs|\.obs-wrapped.*' >/dev/null; then
        echo 'Close OBS before preparing the managed capture profile.' >&2
        exit 1
      fi
      unset LD_LIBRARY_PATH
      if ! "$prepare_only"; then
        monitor=$(hyprctl -j monitors | jq -ce '.[] | select(.name == "HDMI-A-1" and .disabled != true)') || {
          echo 'The HDMI-A-1 monitor must be connected before opening OBS.' >&2; exit 1;
        }
        monitor_id=$(jq -r '.id' <<< "$monitor")
        workspace=$(jq -r '.activeWorkspace.id' <<< "$monitor")
        pw-dump | jq -e 'any(.[]; .info.props."node.name" == "alsa_input.usb-Generic_Blue_Microphones_LT_2010291845405F390773_111000-00.analog-stereo")' >/dev/null || {
          echo 'Connect the configured Blue microphone before opening OBS.' >&2; exit 1;
        }
      fi
      video_id=$1
      obs_root="''${XDG_CONFIG_HOME:-${homeDirectory}/.config}/obs-studio"
      profile="$obs_root/basic/profiles/CMS_Alex_Desk"
      scene="$obs_root/basic/scenes/CMS_Alex_Desk.json"
      recording_dir="${homeDirectory}/Videos/$video_id/raw/screen"
      mkdir -p "$profile" "$(dirname "$scene")" "$recording_dir"
      # Retain the preceding managed state for recovery; unrelated profiles and scenes are untouched.
      if [[ -f "$profile/basic.ini" ]]; then cp "$profile/basic.ini" "$profile/basic.ini.bak"; fi
      sed "s|@RECORDING_DIR@|$recording_dir|" ${./profile.ini} > "$profile/basic.ini"
      cp ${./recordEncoder.json} "$profile/recordEncoder.json"
      chmod u+w "$profile/recordEncoder.json"
      if [[ ! -f "$scene" ]]; then
        cp ${./scene.json} "$scene"
        chmod u+w "$scene"
      fi
      # One-time migration from the old screen/window picker. Never restore an old personal-browser permission.
      if jq -e '.sources[] | select(.uuid == "c8de229f-f456-43b0-9d19-493eb1e44232" and .id == "pipewire-screen-capture-source")' "$scene" >/dev/null; then
        cp "$scene" "$scene.before-window-capture.bak"
        jq '.sources |= map(if .uuid == "c8de229f-f456-43b0-9d19-493eb1e44232" then .id = "pipewire-window-capture-source" | .versioned_id = "pipewire-window-capture-source" | .settings.RestoreToken = "" else . end)' "$scene" > "$scene.tmp"
        mv "$scene.tmp" "$scene"
      fi
      echo "Prepared CMS Alex Desk: 2560x1440 / 25 fps / 48 kHz PCM. Output: $recording_dir"
      echo 'OBS captures a window. On first use select the CMS Recording Firefox window and allow remembering it.'
      echo 'Check the capture preview and microphone meter before recording.'
      if "$prepare_only"; then exit 0; fi
      uwsm app -t service -- obs --profile 'CMS Alex Desk' --collection 'CMS Alex Desk' --scene Browser
      for ((attempt=0; attempt<300; attempt++)); do
        address=$(hyprctl -j clients | jq -r 'first(.[] | select((.class == "com.obsproject.Studio" or .class == "obs") and (.title | startswith("OBS ")))) | .address // empty')
        if [[ -n "$address" ]]; then
          hyprctl dispatch "hl.dsp.window.move({window=\"address:$address\", workspace=$workspace, follow=false})" >/dev/null
          hyprctl -j clients | jq -e --arg address "$address" --argjson monitor "$monitor_id" '.[] | select(.address == $address) | .monitor == $monitor' >/dev/null || {
            echo 'OBS opened but could not be placed on HDMI-A-1; move it there before recording.' >&2; exit 1;
          }
          echo 'OBS opened on HDMI-A-1. Start and stop recording yourself.'
          exit 0
        fi
        sleep 0.1
      done
      echo 'Timed out waiting for the OBS main window; if it opened, move it to HDMI-A-1 before recording.' >&2
      exit 1
    '';
  };
  browser = pkgs.writeShellApplication {
    name = "cms-video-browser";
    runtimeInputs = [
      pkgs.hyprland
      pkgs.jq
      pkgs.coreutils
      pkgs.firefox
      pkgs.uwsm
    ];
    text = ''
      unset LD_LIBRARY_PATH
      monitor=$(hyprctl -j monitors | jq -ce '.[] | select(.name == "DP-3" and .width == 3440 and .height == 1440 and .scale == 1 and .transform == 0)') || {
        echo 'Expected the DP-3 ultrawide at 3440x1440, scale 1, landscape.' >&2; exit 1;
      }
      hyprctl eval 'dofile("${workspaceConfig}")' >/dev/null
      profile="${homeDirectory}/.mozilla/firefox/cms-recording"
      mkdir -p "$profile"
      # The same source is managed by Home Manager. Seed only this new profile before its first activation.
      if [[ ! -e "$profile/user.js" ]]; then ln -s ${firefoxPrefs} "$profile/user.js"; fi
      count=$(hyprctl -j clients | jq '[.[] | select(.class == "cms-recording")] | length')
      if [[ "$count" != 0 ]]; then
        echo 'The recording Firefox is already open. Super+R switches to its workspace.'
        exit 0
      fi
      before_workspace=$(jq -r '.activeWorkspace.name' <<< "$monitor")
      before_focus=$(hyprctl -j activewindow | jq -r '.address // ""')
      uwsm app -t service -- firefox --new-instance --profile "$profile" --name cms-recording --class cms-recording --new-window about:blank
      browser=""
      for ((attempt=0; attempt<300; attempt++)); do
        candidates=$(hyprctl -j clients | jq -c '[.[] | select(.class == "cms-recording")]')
        count=$(jq 'length' <<< "$candidates")
        if [[ "$count" -gt 1 ]]; then
          echo 'Several recording Firefox windows appeared; close the extra window before recording.' >&2; exit 1
        fi
        if [[ "$count" == 1 ]]; then browser=$(jq -c '.[0]' <<< "$candidates"); break; fi
        sleep 0.1
      done
      if [[ -z "$browser" ]]; then
        echo 'Timed out waiting for the new Firefox window. Existing windows were not changed.' >&2; exit 1
      fi
      monitor_id=$(jq -r '.id' <<< "$monitor")
      x=$(jq '.x + 440' <<< "$monitor")
      y=$(jq '.y' <<< "$monitor")
      if ! jq -e --argjson monitor "$monitor_id" --argjson x "$x" --argjson y "$y" '.workspace.name == "recording" and .size == [2560,1440] and .monitor == $monitor and .at == [$x,$y] and .floating == false' <<< "$browser" >/dev/null; then
        echo 'The recording workspace did not provide the intended 2560x1440 tiled browser; check its layout before recording.' >&2; exit 1
      fi
      if [[ $(hyprctl -j monitors | jq -r '.[] | select(.name == "DP-3") | .activeWorkspace.name') != "$before_workspace" || $(hyprctl -j activewindow | jq -r '.address // ""') != "$before_focus" ]]; then
        echo 'Firefox changed focus/workspace unexpectedly; recording has not started.' >&2; exit 1
      fi
      echo 'Clean CMS Recording Firefox opened silently on the recording workspace. Super+R switches there and back.'
      echo 'Your personal Firefox profile is separate. Select CMS Recording in the OBS window picker on first use.'
    '';
  };
  workspace = pkgs.writeShellApplication {
    name = "cms-video-workspace";
    runtimeInputs = [ pkgs.hyprland ];
    text = ''
      unset LD_LIBRARY_PATH
      hyprctl eval 'dofile("${workspaceConfig}").toggle()' >/dev/null
    '';
  };
in
pkgs.symlinkJoin {
  name = "cms-video-capture-tools";
  paths = [
    capture
    browser
    workspace
    editor
  ];
  passthru = { inherit workspaceConfig firefoxPrefs editor; };
}
