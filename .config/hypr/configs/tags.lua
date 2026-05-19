local grouped_rules = {
    ["+multimedia_video"] = {{
        class = "^([Mm]pv|vlc)$"
    }},

    ["+settings"] = {{
        class = "^(nm-applet|nm-connection-editor|blueman-manager|org.gnome.FileRoller|org.pulseaudio.pavucontrol)$"
    }, {
        class = "^(org.gnome.DiskUtility|wihotspot(-gui)?)$"
    }, {
        title = "^(settings)"
    }, {
        title = "^(Settings)"
    }},

    ["+viewer"] = {{
        class = "^(org.gnome.SystemMonitor)$"
    }, {
        class = "^(org.gnome.Evince)$"
    }, {
        class = "^(eog|org.gnome.Loupe)$"
    }}
}

for tag, matches in pairs(grouped_rules) do
    for _, match in ipairs(matches) do
        hl.window_rule({
            match = match,
            tag = tag
        })
    end
end
