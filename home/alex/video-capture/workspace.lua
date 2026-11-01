-- This module is also loaded by the browser command, so the setup can be used before the next NixOS switch.
local source = debug.getinfo(1, "S").source
if _G.cms_video and _G.cms_video.source == source then
    return _G.cms_video
end
if _G.cms_video then
    _G.cms_video.subscription:remove()
    if _G.cms_video.notice then _G.cms_video.notice:dismiss() end
end

local state = { source = source, previous = "2" }

hl.workspace_rule({
    workspace = "name:recording",
    monitor = "DP-3",
    persistent = true,
    layout = "hy3",
    gaps_in = 0,
    gaps_out = { top = 0, right = 440, bottom = 0, left = 440 },
    no_border = true,
    no_rounding = true,
    no_shadow = true,
})

-- Match the separate Firefox instance before mapping it: no visible open-then-move or focus change.
hl.window_rule({
    name = "cms-recording-firefox",
    match = { class = "^cms-recording$" },
    workspace = "name:recording silent",
    monitor = "DP-3 silent",
    no_initial_focus = true,
    focus_on_activate = false,
})

local function selector(name)
    if tonumber(name) then return name end
    return "name:" .. name
end

function state.toggle()
    local monitor = hl.get_monitor("DP-3")
    if not monitor then return end
    local current = monitor.active_workspace
    local target
    if current and current.name == "recording" then
        target = selector(state.previous)
    else
        if current then state.previous = current.name end
        target = "name:recording"
    end
    hl.dispatch(hl.dsp.focus({ workspace = target }))
end

hl.unbind("SUPER + R")
hl.bind("SUPER + R", state.toggle, { description = "Toggle recording workspace on ultrawide" })

state.subscription = hl.on("workspace.active", function(workspace)
    if not workspace or not workspace.monitor then return end
    local monitor = workspace.monitor
    if monitor.name == "DP-3" and workspace.name ~= "recording" then state.previous = workspace.name end
    local names = {}
    for _, available in ipairs(hl.get_workspaces()) do
        if not available.special and available.monitor and available.monitor.name == monitor.name then
            table.insert(names, available.name == workspace.name and ("[" .. available.name .. "]") or available.name)
        end
    end
    table.sort(names)
    if state.notice then state.notice:dismiss() end
    state.notice = hl.notification.create({
        text = monitor.name .. "  •  " .. workspace.name .. "     Workspaces: " .. table.concat(names, ", "),
        timeout = 1500,
        icon = "none",
        color = "rgb(89b4fa)",
        font_size = 13,
    })
end)

_G.cms_video = state
return state
