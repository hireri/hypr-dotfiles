local commands = {
    "dbus-update-activation-environment --all",
    "/usr/lib/polkit-gnome/polkit-gnome-authentication-agent-1",
    "hypridle",
    "qs -c isra",
    "wl-paste --watch clipvault store",
    "wl-clip-persist --clipboard regular",
    "rm -rf ~/.config/obs-studio/.sentinel",
    "steam -silent",
    "QT_QPA_PLATFORM=wayland obs --startreplaybuffer --minimize-to-tray --scene Replay",
    "runsvdir ~/.runit/runsvdir",
}

hl.on("hyprland.start", function()
    for _, cmd in ipairs(commands) do
        hl.exec_cmd(cmd)
    end
end)