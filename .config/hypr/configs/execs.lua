local commands = {
    "dbus-update-activation-environment --all",
    "/usr/lib/polkit-kde-authentication-agent-1",
    "awww-daemon",
    "hyprlock",
    "hypridle",
    "qs -c isra",
    "wl-paste --watch clipvault store",
    "rm -f ~/.config/obs-studio/.sentinel",
    "steam -silent",
    "QT_QPA_PLATFORM=wayland obs --startreplaybuffer --minimize-to-tray --scene Replay",
    "hyprctl reload"
}

hl.on("hyprland.start", function()
    for _, cmd in ipairs(commands) do
        hl.exec_cmd(cmd)
    end
end)