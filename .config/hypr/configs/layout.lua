hl.config({
    general = {
        gaps_in = 6,
        gaps_out = 12,
        border_size = 1,
        no_focus_fallback = true,
        resize_on_border = true,
        allow_tearing = false,
        layout = "scrolling",

        snap = {
            enabled = true,
            window_gap = 4,
            monitor_gap = 5,
            respect_gaps = true
        }
    },
    scrolling = {
        column_width = 0.5,
        follow_focus = true,
        focus_fit_method = 1,
        wrap_focus = true,
        wrap_swapcol = true,
        direction = "right",
        fullscreen_on_one_column = true
    }
})

hl.config({
    dwindle = {
        preserve_split = true
    },
    master = {
        new_status = "master"
    }
})
