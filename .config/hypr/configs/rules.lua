-- ------------------------------------------------------------
-- Window Rules
-- ------------------------------------------------------------
-- Tag rules
hl.window_rule({
    match = {
        tag = "multimedia_video*"
    },
    no_blur = true,
    float = true,
    size = {"monitor_w * 0.55", "monitor_h * 0.55"}
})

hl.window_rule({
    match = {
        tag = "settings*"
    },
    float = true,
    size = {"monitor_w * 0.40", "monitor_h * 0.40"}
})

hl.window_rule({
    match = {
        tag = "viewer*"
    },
    float = true
})

-- Class based rules

hl.window_rule({
    match = {
        class = "^(qimgv)$"
    },
    float = true,
    center = true
})

hl.window_rule({
    match = {
        class = "^(kitty)$",
        title = "^(btop)$"
    },
    float = true,
    center = true,
    pin = true
})

hl.window_rule({
    match = {
        class = "^(io.missioncenter.MissionCenter)$"
    },
    float = true,
    size = {"monitor_w * 0.40", "monitor_h * 0.40"}
})

hl.window_rule({
    match = {
        title = "satty"
    },
    float = true,
    size = {"monitor_w * 0.60", "monitor_h * 0.60"}
})

-- Popups & Dialogues
hl.window_rule({
    match = {
        title = "^(Save As|Save a File|Pick Files|Extracting.*)$"
    },
    float = true,
    size = {"monitor_w*.5", "monitor_h*.6"},
    center = true,
    pin = true
})

-- Picture in picture
hl.window_rule({
    match = {
        title = "^([Pp]icture[-\\s]?[Ii]n[-\\s]?[Pp]icture)(.*)$"
    },
    float = true,
    keep_aspect_ratio = true,
    move = {"monitor_w*.73", "monitor_h*.72"},
    size = {"monitor_w*.25", "monitor_h*.25"}
})

hl.window_rule({
    match = {
        initial_title = "(Open Files)"
    },
    float = true,
    size = {"monitor_w*.7", "monitor_h*.6"}
})

-- Share
hl.window_rule({
    match = {
        title = "^(Hyprland Share)$"
    },
    float = true,
    center = true,
    pin = true,
    size = {"monitor_w * 0.25", "monitor_h * 0.3"}
})

hl.window_rule({
    match = {
        class = "xdg-desktop-portal-gtk"
    },
    float = true,
    pin = true
})

-- Fix XWayland dragging issues
hl.window_rule({
    name = "fix-xwayland-drags",
    match = {
        class = "^$",
        title = "^$",
        xwayland = true,
        float = true,
        fullscreen = false,
        pin = false
    },
    no_focus = true
})

-- ------------------------------------------------------------
-- Layer Rules
-- ------------------------------------------------------------

hl.layer_rule({
    match = {
        namespace = "quickshell"
    },
    blur = false
})

hl.layer_rule({
    match = {
        namespace = "^(quickshell-launcher|selection)$"
    },
    no_anim = true
})

hl.layer_rule({
    match = {
        initial_title = "steam_app_2457888594"
    },
    blur = false
})

-- ------------------------------------------------------------
-- Layout Configs
-- ------------------------------------------------------------

hl.config({
    dwindle = {
        preserve_split = true
    },
    master = {
        new_status = "master"
    }
})
