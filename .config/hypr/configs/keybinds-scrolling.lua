-- -----------------------------------------------------
-- Scrolling Specific Binds
-- -----------------------------------------------------
hl.bind(mainMod .. " + left", hl.dsp.layout("move -col"), {
    repeating = true
})
hl.bind(mainMod .. " + right", hl.dsp.layout("move +col"), {
    repeating = true
})
hl.bind(mainMod .. " + up", hl.dsp.layout("consume_or_expel prev"))
hl.bind(mainMod .. " + down", hl.dsp.layout("consume_or_expel next"))

-- Column swap / promote / expel
hl.bind(mainMod .. " + CTRL + left", hl.dsp.layout("swapcol l"))
hl.bind(mainMod .. " + CTRL + right", hl.dsp.layout("swapcol r"))
hl.bind(mainMod .. " + CTRL + up", hl.dsp.layout("promote"))
hl.bind(mainMod .. " + CTRL + down", hl.dsp.layout("expel"))

-- Column resize
hl.bind(mainMod .. " + SHIFT + left", hl.dsp.layout("colresize -0.05"), {
    repeating = true
})
hl.bind(mainMod .. " + SHIFT + right", hl.dsp.layout("colresize +0.05"), {
    repeating = true
})
hl.bind(mainMod .. " + SHIFT + up", hl.dsp.layout("colresize +conf"))
hl.bind(mainMod .. " + SHIFT + down", hl.dsp.layout("colresize -conf"))
