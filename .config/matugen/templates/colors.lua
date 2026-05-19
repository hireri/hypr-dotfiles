hl.config({
    general = {
        col = {
            active_border = {
                colors = {"{{colors.primary.default.hex}}", "{{colors.tertiary.default.hex}}"}
            },
            inactive_border = "{{colors.outline_variant.default.hex}}"
        }
    },
    misc = {
        background_color = "rgba({{colors.surface.dark.hex_stripped}}FF)"
    }
})

hl.window_rule({
    match = {
        pin = 1
    },
    border_color = "{{colors.error.default.hex}}"
})
