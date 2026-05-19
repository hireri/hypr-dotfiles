-- -----------------------------------------------------
-- Core Applications
-- -----------------------------------------------------
hl.bind(mainMod .. " + RETURN", hl.dsp.exec_cmd(terminal))
hl.bind(mainMod .. " + SHIFT + RETURN", hl.dsp.exec_cmd(terminal, {
    float = true,
    size = {800, 550},
    center = true
}))
hl.bind(mainMod .. " + E", hl.dsp.exec_cmd(fileManager))
hl.bind(mainMod .. " + SHIFT + E", hl.dsp.exec_cmd("kitty yazi"))
hl.bind(mainMod .. " + B", hl.dsp.exec_cmd('xdg-open "https://"'))
hl.bind(mainMod .. " + C", hl.dsp.exec_cmd("code"))

-- -----------------------------------------------------
-- Window Management
-- -----------------------------------------------------
hl.bind(mainMod .. " + X", hl.dsp.window.close())
hl.bind(mainMod .. " + SHIFT + Q", hl.dsp.exec_cmd("hyprctl kill"))
hl.bind(mainMod .. " + Space", hl.dsp.window.float({
    action = "toggle"
}))
hl.bind(mainMod .. " + F", hl.dsp.window.fullscreen({
    mode = "fullscreen"
}))
hl.bind(mainMod .. " + D", hl.dsp.window.fullscreen({
    mode = "maximized"
}))
hl.bind(mainMod .. " + Page_Up", hl.dsp.window.fullscreen({
    mode = "maximized"
}))
hl.bind(mainMod .. " + P", hl.dsp.window.pin({
    action = "toggle"
}))
hl.bind(mainMod .. " + J", hl.dsp.layout("togglesplit"))

-- Focus Movement
hl.bind(mainMod .. " + left", hl.dsp.focus({
    direction = "l"
}))
hl.bind(mainMod .. " + right", hl.dsp.focus({
    direction = "r"
}))
hl.bind(mainMod .. " + up", hl.dsp.focus({
    direction = "u"
}))
hl.bind(mainMod .. " + down", hl.dsp.focus({
    direction = "d"
}))

-- Tab Cycling
hl.bind("ALT + Tab", function()
    hl.dispatch(hl.dsp.window.cycle_next())
    hl.dispatch(hl.dsp.window.alter_zorder({
        mode = "top"
    }))
end)
hl.bind("ALT + SHIFT + Tab", hl.dsp.window.cycle_next({
    prev = true
}))

-- Window Movement
hl.bind(mainMod .. " + CTRL + left", hl.dsp.window.move({
    direction = "l"
}))
hl.bind(mainMod .. " + CTRL + right", hl.dsp.window.move({
    direction = "r"
}))
hl.bind(mainMod .. " + CTRL + up", hl.dsp.window.move({
    direction = "u"
}))
hl.bind(mainMod .. " + CTRL + down", hl.dsp.window.move({
    direction = "d"
}))

-- Resizing
hl.bind(mainMod .. " + SHIFT + left", hl.dsp.window.resize({
    x = -50,
    y = 0,
    relative = true
}), {
    repeating = true
})
hl.bind(mainMod .. " + SHIFT + right", hl.dsp.window.resize({
    x = 50,
    y = 0,
    relative = true
}), {
    repeating = true
})
hl.bind(mainMod .. " + SHIFT + up", hl.dsp.window.resize({
    x = 0,
    y = -50,
    relative = true
}), {
    repeating = true
})
hl.bind(mainMod .. " + SHIFT + down", hl.dsp.window.resize({
    x = 0,
    y = 50,
    relative = true
}), {
    repeating = true
})

-- -----------------------------------------------------
-- Workspace Management
-- -----------------------------------------------------

-- Switch workspaces
for i = 1, 9 do
    hl.bind(mainMod .. " + " .. i, hl.dsp.focus({
        workspace = i
    }))
end
hl.bind(mainMod .. " + 0", hl.dsp.focus({
    workspace = 10
}))

-- Move active window to workspace
for i = 1, 9 do
    hl.bind(mainMod .. " + SHIFT + " .. i, hl.dsp.window.move({
        workspace = i
    }))
end
hl.bind(mainMod .. " + SHIFT + 0", hl.dsp.window.move({
    workspace = 10
}))

-- Send active window to workspace silently
for i = 1, 9 do
    hl.bind(mainMod .. " + CTRL + " .. i, hl.dsp.window.move({
        workspace = i,
        follow = false
    }))
end
hl.bind(mainMod .. " + CTRL + 0", hl.dsp.window.move({
    workspace = 10,
    follow = false
}))

-- -----------------------------------------------------
-- System & Session
-- -----------------------------------------------------
hl.bind(mainMod .. " + L", hl.dsp.exec_cmd("hyprlock"))
hl.bind("CTRL + ALT + Delete", hl.dsp.exec_cmd("hyprctl dispatch exit 0"))
hl.bind(mainMod .. " + Escape", hl.dsp.exec_cmd("flatpak run io.missioncenter.MissionCenter"))

-- Quickshell
hl.bind(mainMod .. " + S", hl.dsp.global("quickshell:openQuickSettings"))
hl.bind(mainMod .. " + M", hl.dsp.global("quickshell:openPowerMenu"))
hl.bind(mainMod .. " + W", hl.dsp.global("quickshell:openWallpaperPicker"))

hl.bind(mainMod .. " + SUPER_L", hl.dsp.exec_cmd("qs -c isra ipc call launcher toggle"), {
    release = true
})

hl.bind(mainMod .. " + V", hl.dsp.exec_cmd('qs -c isra ipc call launcher openWith ";"'))
hl.bind(mainMod .. " + Period", hl.dsp.exec_cmd('qs -c isra ipc call launcher openWith ":"'))

hl.bind(mainMod .. " + SHIFT + N", hl.dsp.exec_cmd("qs -c isra ipc call media next"))
hl.bind(mainMod .. " + SHIFT + P", hl.dsp.exec_cmd("qs -c isra ipc call media togglePlaying"))
hl.bind(mainMod .. " + SHIFT + B", hl.dsp.exec_cmd("qs -c isra ipc call media previous"))

hl.bind(mainMod .. " + I", hl.dsp.exec_cmd("qs -c isra ipc call settings open overview"))
hl.bind(mainMod .. " + SHIFT + S", hl.dsp.exec_cmd("qs -c isra ipc call screenshot activate"))

-- -----------------------------------------------------
-- Utilities & Tools
-- -----------------------------------------------------

-- Screenshots & OCR
hl.bind(mainMod .. " + SHIFT + T", hl.dsp.exec_cmd("qs -c isra ipc call screenshot ocr"))
hl.bind(mainMod .. " + SHIFT + G", hl.dsp.exec_cmd("qs -c isra ipc call screenshot cts"))
hl.bind(mainMod .. " + SHIFT + R", hl.dsp.exec_cmd("qs -c isra ipc call screenshot record"))
hl.bind(mainMod .. " + SHIFT + C", hl.dsp.exec_cmd("hyprpicker --autocopy"))

-- Recording
hl.bind("ALT + C", hl.dsp.exec_cmd("obs-cmd replay save"))

-- -----------------------------------------------------
-- Appearance & UI
-- -----------------------------------------------------
hl.bind(mainMod .. " + G", hl.dsp.exec_cmd("qs -c isra ipc call gamemode toggle"))

-- -----------------------------------------------------
-- Hardware & Multimedia
-- -----------------------------------------------------

-- Volume & Brightness 
hl.bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd("wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+"), {
    repeating = true
})
hl.bind("XF86AudioLowerVolume", hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"), {
    repeating = true
})
hl.bind("XF86AudioMute", hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"), {
    locked = true
})
hl.bind("XF86AudioMicMute", hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"), {
    locked = true
})
hl.bind("XF86MonBrightnessUp", hl.dsp.exec_cmd("brightnessctl -e4 -n2 set 5%+"), {
    repeating = true
})
hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd("brightnessctl -e4 -n2 set 5%-"), {
    repeating = true
})

-- Media Control 
hl.bind("XF86AudioNext", hl.dsp.exec_cmd("playerctl next"), {
    locked = true
})
hl.bind("XF86AudioPause", hl.dsp.exec_cmd("playerctl play-pause"), {
    locked = true
})
hl.bind("XF86AudioPlay", hl.dsp.exec_cmd("playerctl play-pause"), {
    locked = true
})
hl.bind("XF86AudioPrev", hl.dsp.exec_cmd("playerctl previous"), {
    locked = true
})

-- Media Control 
hl.bind(mainMod .. " + SHIFT + M", hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"))

-- -----------------------------------------------------
-- Mouse Binds
-- -----------------------------------------------------
hl.bind(mainMod .. " + mouse:272", hl.dsp.window.drag(), {
    mouse = true
})
hl.bind(mainMod .. " + mouse:273", hl.dsp.window.resize(), {
    mouse = true
})
