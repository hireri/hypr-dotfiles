hl.config({
    decoration = {
        rounding = 18,
        rounding_power = 2,

        active_opacity = 1.0,
        inactive_opacity = 1.0,

        shadow = {
            enabled = true,
            range = 8,
            render_power = 2,
            color = "rgba(00000055)"
        },

        blur = {
            enabled = true,
            popups = true,
            special = true,
            new_optimizations = true,
            size = 10,
            passes = 3,
            brightness = 1,
            vibrancy = 0.5,
            vibrancy_darkness = 0.5
        }
    }
})

-- ------------------------------------------------------------
-- Curves 
-- ------------------------------------------------------------

hl.curve("easeOutQuint", {
    type = "bezier",
    points = {{0.23, 1}, {0.32, 1}}
})
hl.curve("easeInOutCubic", {
    type = "bezier",
    points = {{0.65, 0.05}, {0.36, 1}}
})
hl.curve("linear", {
    type = "bezier",
    points = {{0, 0}, {1, 1}}
})
hl.curve("almostLinear", {
    type = "bezier",
    points = {{0.5, 0.5}, {0.75, 1}}
})
hl.curve("quick", {
    type = "bezier",
    points = {{0.15, 0}, {0.1, 1}}
})

-- ------------------------------------------------------------
-- Animations
-- ------------------------------------------------------------

hl.animation({
    leaf = "global",
    enabled = true,
    speed = 1.0,
    bezier = "default"
})
hl.animation({
    leaf = "border",
    enabled = true,
    speed = 0.8,
    bezier = "easeOutQuint"
})
hl.animation({
    leaf = "windows",
    enabled = true,
    speed = 4.79,
    bezier = "easeOutQuint"
})
hl.animation({
    leaf = "windowsIn",
    enabled = true,
    speed = 3.5,
    bezier = "easeOutQuint",
    style = "popin 80%"
})
hl.animation({
    leaf = "windowsOut",
    enabled = true,
    speed = 1.5,
    bezier = "easeInOutCubic",
    style = "popin 80%"
})
hl.animation({
    leaf = "fadeIn",
    enabled = true,
    speed = 2.0,
    bezier = "almostLinear"
})
hl.animation({
    leaf = "fadeOut",
    enabled = true,
    speed = 1.5,
    bezier = "almostLinear"
})
hl.animation({
    leaf = "fade",
    enabled = true,
    speed = 3.03,
    bezier = "quick"
})
hl.animation({
    leaf = "layers",
    enabled = true,
    speed = 3.81,
    bezier = "easeOutQuint"
})
hl.animation({
    leaf = "layersIn",
    enabled = true,
    speed = 4.0,
    bezier = "easeOutQuint",
    style = "fade"
})
hl.animation({
    leaf = "layersOut",
    enabled = true,
    speed = 1.5,
    bezier = "linear",
    style = "fade"
})
hl.animation({
    leaf = "fadeLayersIn",
    enabled = true,
    speed = 1.79,
    bezier = "almostLinear"
})
hl.animation({
    leaf = "fadeLayersOut",
    enabled = true,
    speed = 1.39,
    bezier = "almostLinear"
})
hl.animation({
    leaf = "workspacesIn",
    enabled = true,
    speed = 4.0,
    bezier = "easeOutQuint",
    style = "slidevert 100%"
})
hl.animation({
    leaf = "workspacesOut",
    enabled = true,
    speed = 4.0,
    bezier = "easeOutQuint",
    style = "slidevert 100%"
})
hl.animation({
    leaf = "zoomFactor",
    enabled = true,
    speed = 7.0,
    bezier = "quick"
})
