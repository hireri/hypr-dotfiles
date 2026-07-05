-- -----------------------------------------------------
-- Dwindle Specific Binds
-- -----------------------------------------------------
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

-- Window Movementj
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
