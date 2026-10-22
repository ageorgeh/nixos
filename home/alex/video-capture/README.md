# CMS desk capture on this workstation

The CMS owns `cms/alex-desk` and its shared recording guide. This directory implements that capture intent for Alex's
workstation: DP-3 ultrawide, scale 1, and the explicitly named Blue USB microphone. It supplies a separate **CMS Alex Desk**
OBS profile and scene, a clean **CMS Recording** Firefox profile and a named `recording` Hyprland workspace.

Home Manager installs `cms-video-browser`, `cms-video-workspace`, `cms-video-capture` and `cms-resolve-editor` after the next
normal configuration switch. No system rebuild is required to try them now; run the flake apps directly:

Run these from a terminal in the active Hyprland desktop session so they can access that session's display and audio.

```sh
nix run path:/home/alex/nixos-config#cms-video-browser
nix run path:/home/alex/nixos-config#cms-video-capture -- alex_desk_test_01
```

`cms-video-browser` checks DP-3's geometry and loads `workspace.lua`. It opens Firefox at `about:blank` in a separate
`cms-recording` profile and application instance, with no copied personal bookmarks, history, extensions or accounts.
The bookmarks toolbar, Firefox account integration and welcome/new-tab content are disabled. This is a clean browser,
not an anonymous browsing environment: browsing and sign-ins performed in it persist in that profile.

Hyprland places its distinct `cms-recording` application class directly onto the named **recording** workspace on DP-3,
without switching your workspace or focus. hy3 tiles the window between 440-pixel side gaps, producing a 2560 × 1440
window with its title/navigation chrome onscreen. There is no floating-window positioning. The command checks the final
geometry and unchanged focus; a repeated invocation keeps the existing recording window. Keep one browser window in
this workspace, using tabs for additional pages. Extra windows or manual resizing can change its capture dimensions.

**Super+R** switches DP-3 between recording and its previous workspace; the other monitor keeps its workspace. The same
action is available as `cms-video-workspace`. A brief Hyprland notification on workspace changes lists that monitor's
workspaces, with the current one in brackets. It disappears after 1.5 seconds; no Waybar is installed or enabled.
Set the demonstration page and browser zoom yourself. Start at 100% and check readability at the final 1080p size.

Both applications launch as UWSM-managed user services, independently of the invoking terminal or automation process.
The declarative Home Manager profile registration, Lua configuration and startup hook become persistent after the normal
NixOS switch. Before that, the browser/workspace commands load the same Lua module into the running session and seed
only the new profile's `user.js` symlink from the exact future Home Manager source. A compositor reload before the
switch requires running either command again to restore the shortcut and rules.

`cms-video-capture <id>` requires OBS to be closed. It refreshes the dedicated recording profile, keeps one `.bak` of the
previous profile, creates `~/Videos/<id>/raw/screen/` and opens OBS with that profile, collection and Browser scene.
The scene template is copied only on first use. Later launches preserve the existing writable OBS scene, including
its selected source, portal restore token and manual scene adjustments. The scene template does not overwrite that state.
Before changing files for a normal launch, it checks that HDMI-A-1 and the configured Blue microphone are available.
It identifies the OBS main window and moves it to **HDMI-A-1**, the 1920 × 1080 monitor.
It waits up to 30 seconds for that window and reports failure if it cannot place it. It does not rearrange other windows.
Use `cms-video-capture --prepare-only <id>` to prepare files without opening OBS. Prepare-only mode does not require the
monitors or microphone to be connected. Switch to recording with Super+R before selecting/recording the window.
The first Wayland capture permission must still be granted interactively: select **CMS Recording Firefox** and allow
remembering the selection when offered. OBS's restore token is kept locally, outside Git.
The portal can ask again if permission was revoked or it cannot restore the source; a configuration file cannot grant a
new sharing permission. The source requests windows only. This portal restores windows by application class; the new
recording class distinguishes this instance from personal Firefox. The existing managed scene is migrated once from the
old source, with a `.before-window-capture.bak` backup and its old capture token cleared. Later launches retain the new
permission and scene adjustments. Check the preview before recording and keep the recording workspace visible during
capture; capture while its workspace is hidden is not a supported assumption.

The installed OBS [PipeWire implementation](https://github.com/obsproject/obs-studio/blob/32.2.2/plugins/linux-pipewire/screencast-portal.c)
requests persistent permission and saves the returned token. The installed Hyprland portal
[restores remembered sources](https://github.com/hyprwm/xdg-desktop-portal-hyprland/blob/v1.4.1/src/portals/Screencopy.cpp)
when it can match them. The launcher previously discarded this state on every run; it now leaves the scene intact.

The profile records 2560 × 1440 at 25 fps, NV12, Rec.709/partial range, with 48 kHz stereo PCM on recording track 1 in MKV.
The explicit Blue microphone is the only audio source; no desktop sound or plugin chain is added. H.264 uses x264 CRF 18,
veryfast, as an initial portable capture setting. Review OBS rendering/encoding lag on the test recording before treating
performance as proven; hardware encoding can be calibrated later without changing the capture geometry/colour contract.
These are source recording settings, independent of the much smaller handoff delivery preset.

OBS's native Advanced Output keys and PCM encoder ID are based on the installed 32.2.2 implementation:
[output configuration](https://github.com/obsproject/obs-studio/blob/32.2.2/frontend/utility/AdvancedOutput.cpp),
[PCM audio encoder](https://github.com/obsproject/obs-studio/blob/32.2.2/plugins/obs-ffmpeg/obs-ffmpeg-audio-encoders.c).
The profile uses `RecAudioEncoder=ffmpeg_pcm_s16le`; the container holds PCM rather than a separate WAV. Whether Resolve
imports that MKV directly is still a media-preparation concern; do not alter the source recording to work around it.

The launch tools clear inherited `LD_LIBRARY_PATH` for their child processes because the Codex shell's library path
otherwise breaks the installed Hyprland client. They do not change the session environment or the existing Resolve MCP
wrapper's FHS/lifecycle fix.

The browser arrangement has been checked with a screen recording. A camera-plus-screen session still needs an operator
check for the complete capture setup.

## Native Resolve editing adapter

`cms-resolve-editor` supplies the Edit-page keyboard commands absent from the Resolve scripting API. It does not read
or reconstruct a timeline, copy settings, change keyboard mappings or alter the MCP server. The CMS reads actual
timeline state, sets native In/Out marks and checks the edit through Resolve MCP.

The adapter discovers the single Hyprland session and the main Resolve window for the requested project. It targets
that exact window with background shortcuts, selects its timeline panel with Ctrl+4 and deselects clips with Ctrl+Shift+A.
It does not activate Resolve, switch workspaces or restore focus afterwards. It invokes Shift+Backspace
for native marked-range Ripple Delete, or Ctrl+Z for Undo if the CMS detects an incorrect ripple. It expects the
calibrated default Resolve shortcuts and reports custom keyboard presets rather than guessing. Run it while no one is
typing in Resolve. You can continue working in other applications while it edits.

The Hyprland configuration also sets `focus_on_activate = false` for Resolve windows: Resolve can request activation
when receiving these shortcuts. Both parts are needed; blocking activation does not block an explicit focus command.
Generic `resolve` progress windows also have `no_initial_focus = true`, because a slow native save creates one briefly.
This rule does not match normally titled dialogs.
Verified with native ripple deletion, Undo and saving while Kitty retained focus. Hyprland's event socket recorded
the save progress window opening and closing with no focus or workspace events. Test cuts were undone and timeline
coverage restored. Repeated preparation also produced no focus or workspace events.

The package is also available without a system switch:

```sh
nix run path:/home/alex/nixos-config#cms-resolve-editor -- ready --project example_01
nix build path:/home/alex/nixos-config#cms-resolve-editor --out-link ./resolve-editor
```

Pass the built `./resolve-editor/bin/cms-resolve-editor` path as `cms video review --editor-command` until the normal
NixOS switch installs the command. Resolve's FHS library variables are cleared only for the child command, and an
explicit Hyprland instance is selected so MCP does not need additional environment variables.
