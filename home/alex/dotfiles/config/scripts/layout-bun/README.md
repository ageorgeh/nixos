# `layout-bun`

Async Bun/TypeScript rewrite of the Hyprland layout script.

It contains:

- a typed Hyprland IPC client for `.socket.sock`
- a typed socket2 event parser for `.socket2.sock`
- a layout runner that:
  - defines managed apps in one place
  - launches missing apps concurrently
  - untabs everything
  - untile/fixes floating state
  - moves windows to target monitors
  - sorts windows into the requested order without the float/unfloat hack
  - creates `hy3` tab groups
  - applies final resizes

## Usage

```bash
bun install
bun run smoke
bun run start
```

## Notes

On this machine, Bun's direct unix-socket transport returned EOF for Hyprland's
request socket, while Node's unix-socket transport worked correctly. The public
Bun API still lives in TypeScript, but low-level socket IO is handled by a tiny
Node helper so the IPC layer can be exercised reliably.

## Sources

- https://wiki.hypr.land/IPC/
- https://wiki.hypr.land/Configuring/Using-hyprctl/
- https://wiki.hypr.land/Configuring/Dispatchers/
- https://raw.githubusercontent.com/hyprwm/Hyprland/main/src/debug/HyprCtl.cpp
