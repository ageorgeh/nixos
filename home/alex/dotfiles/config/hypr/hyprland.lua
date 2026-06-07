hl.plugin.load("/etc/hypr/plugins/libhy3.so")

local mainMod = "SUPER"
local hy3 = hl.plugin.hy3

local function shell(command)
    return hl.dsp.exec_cmd(command)
end


hl.env("AQ_DRM_DEVICES", "/dev/dri/card1")
hl.env("CLUTTER_BACKEND", "wayland")
hl.env("ELECTRON_OZONE_PLATFORM_HINT", "1")
hl.env("GDK_BACKEND", "wayland, x11")
hl.env("GDK_SCALE", "1")
hl.env("HYPRCURSOR_SIZE", "24")
hl.env("HYPRCURSOR_THEME", "rose-pine-hyprcursor")
hl.env("LIBVA_DRIVER_NAME", "nvidia")
hl.env("MOZ_ENABLE_WAYLAND", "1")
hl.env("NVD_BACKEND", "direct")
hl.env("QT_QPA_PLATFORM", "wayland;xcb")
hl.env("QT_SCALE_FACTOR", "1")
hl.env("QT_WAYLAND_DISABLE_WINDOWDECORATION", "1")
hl.env("SDL_VIDEODRIVER", "wayland")
hl.env("XDG_CURRENT_DESKTOP", "Hyprland")
hl.env("XDG_SESSION_DESKTOP", "Hyprland")
hl.env("XDG_SESSION_TYPE", "wayland")
hl.env("__GLX_VENDOR_LIBRARY_NAME", "nvidia")

hl.config({
    general = {
        layout = "hy3",
        gaps_in = 4,
        gaps_out = 4,
        border_size = 1,
        resize_on_border = true,
        col = {
            active_border = { colors = { "rgb(89b4fa)", "rgb(f5c2e7)" }, angle = 45 },
            inactive_border = "rgb(313244)",
        },
    },

    decoration = {
        rounding = 10,
        blur = {
            enabled = true,
            size = 5,
            passes = 3,
            ignore_opacity = false,
            new_optimizations = true,
        },
        shadow = {
            enabled = true,
            range = 4,
            render_power = 3,
            color = "rgba(1a1a1aee)",
        },
    },

    ecosystem = {
        no_donation_nag = true,
    },

    input = {
        sensitivity = -0.4,
    },

    animations = {
        enabled = true,
    },
})

hl.curve("ease", {
    type = "bezier",
    points = {
        { 0.2, 0.0 },
        { 0.2, 1.0 },
    },
})

hl.animation({ leaf = "windows", enabled = true, speed = 1, bezier = "ease" })
hl.animation({ leaf = "windowsOut", enabled = true, speed = 1, bezier = "ease" })
hl.animation({ leaf = "border", enabled = true, speed = 1, bezier = "ease" })
hl.animation({ leaf = "fade", enabled = true, speed = 1, bezier = "ease" })
hl.animation({ leaf = "workspaces", enabled = true, speed = 1, bezier = "ease" })

hl.on("hyprland.start", function()
    hl.exec_cmd(
        "/run/current-system/sw/bin/dbus-update-activation-environment --systemd --all && systemctl --user stop hyprland-session.target && systemctl --user start hyprland-session.target")
    hl.exec_cmd("hyprpaper")
    hl.exec_cmd("hyprsunset")
    hl.exec_cmd("mako")
    hl.exec_cmd("hyprpolkitagent")
    hl.exec_cmd("clipse --listen")
    --     hl.exec_cmd("sh -lc " .. string.format("%q", [[
    -- sleep 1
    -- hyprctl keyword plugin:hy3:no_gaps_when_only 1
    -- hyprctl keyword plugin:hy3:node_collapse_policy 2
    -- hyprctl keyword plugin:hy3:group_inset 10
    -- hyprctl keyword plugin:hy3:autotile:enable 0
    -- hyprctl keyword plugin:hy3:autotile:trigger_width 800
    -- hyprctl keyword plugin:hy3:autotile:trigger_height 600
    -- ]]))
    hl.exec_cmd(
        [[sh -lc 'sleep 2; bun "$HOME/.config/scripts/layout-bun/layout.ts" > "$HOME/layout.log" 2>&1 && echo "DONE (success)" >> "$HOME/layout.log" || echo "DONE (failed)" >> "$HOME/layout.log"']])
end)

hl.bind(mainMod .. " + C", shell("kitty --class clipse -e 'clipse'"))
hl.bind(mainMod .. " + V", shell("code --use-angle=vulkan"))
hl.bind(mainMod .. " + RETURN", shell("kitty"))
hl.bind(mainMod .. " + T", shell("kitty"))
hl.bind(mainMod .. " + F", shell("firefox"))
hl.bind(mainMod .. " + A", shell("tofi-drun --drun-launch=true"))
-- hl.bind(mainMod .. " + Q", hl.dsp.window.close())
hl.bind(mainMod .. " + Q", hl.dsp.window.kill())
hl.bind(mainMod .. " + Print", shell("hyprshot -m section --clipboard-only"))
hl.bind(mainMod .. " + S", shell("~/.config/scripts/quicksettings.sh"))
hl.bind(mainMod .. " + U", shell("~/.config/scripts/layout-bun/layout.ts"))
hl.bind(mainMod .. " + G", hy3.make_group("tab", { toggle = true }))
hl.bind(mainMod .. " + bracketleft", hy3.focus_tab({ direction = "r", wrap = true }))
hl.bind(mainMod .. " + bracketright", hy3.focus_tab({ direction = "l", wrap = true }))

hl.bind(mainMod .. " + SHIFT + F", hl.dsp.window.float({ action = "toggle" }))

hl.bind(mainMod .. " + SHIFT + H", hy3.move_window("l"))
hl.bind(mainMod .. " + SHIFT + L", hy3.move_window("r"))
hl.bind(mainMod .. " + SHIFT + J", hy3.move_window("d"))
hl.bind(mainMod .. " + SHIFT + K", hy3.move_window("u"))

-- hl.bind(mainMod .. " + H", hy3.move_focus("l", { visible = true, warp = true }))
-- hl.bind(mainMod .. " + L", hy3.move_focus("r", { visible = true, warp = true }))
-- hl.bind(mainMod .. " + J", hy3.move_focus("d", { visible = true, warp = true }))
-- hl.bind(mainMod .. " + K", hy3.move_focus("u", { visible = true, warp = true }))

hl.bind(mainMod .. " + H", hl.dsp.focus({ direction = 'l' }))
hl.bind(mainMod .. " + L", hl.dsp.focus({ direction = 'r' }))
hl.bind(mainMod .. " + J", hl.dsp.focus({ direction = 'd' }))
hl.bind(mainMod .. " + K", hl.dsp.focus({ direction = 'u' }))


local zoomIn = shell(
    "hyprctl -q keyword cursor:zoom_factor $(hyprctl getoption cursor:zoom_factor | awk '/^float.*/ {print $2 * 1.1}')")
local zoomOut = shell(
    "hyprctl -q keyword cursor:zoom_factor $(hyprctl getoption cursor:zoom_factor | awk '/^float.*/ {print $2 * 0.9}')")
local zoomReset = shell("hyprctl -q keyword cursor:zoom_factor 1")

hl.bind(mainMod .. " + mouse_down", zoomIn)
hl.bind(mainMod .. " + mouse_up", zoomOut)
hl.bind(mainMod .. " + equal", zoomIn)
hl.bind(mainMod .. " + minus", zoomOut)
hl.bind(mainMod .. " + KP_ADD", zoomIn)
hl.bind(mainMod .. " + KP_SUBTRACT", zoomOut)
hl.bind(mainMod .. " + SHIFT + mouse_up", zoomReset)
hl.bind(mainMod .. " + SHIFT + mouse_down", zoomReset)
hl.bind(mainMod .. " + SHIFT + minus", zoomReset)
hl.bind(mainMod .. " + SHIFT + KP_SUBTRACT", zoomReset)
hl.bind(mainMod .. " + SHIFT + 0", zoomReset)
hl.bind("Print", shell("grimblast copy area"))

for ws = 1, 9 do
    local code = "code:1" .. (ws - 1)
    hl.bind(mainMod .. " + " .. code, hl.dsp.focus({ workspace = ws }))
    hl.bind(mainMod .. " + SHIFT + " .. code, hl.dsp.window.move({ workspace = ws }))
end
