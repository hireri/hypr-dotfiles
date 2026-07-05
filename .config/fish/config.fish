zoxide init fish | source
test -f ~/.config/fish/functions/dotfiles.fish && source ~/.config/fish/functions/dotfiles.fish
test -f ~/.config/fish/functions/turbo.fish && source ~/.config/fish/functions/turbo.fish

alias g='git'
alias ga='git add'
alias gc='git commit -v'
alias gp='git push'
alias gst='git status -sb'
alias cd='z'
alias ..='z ..'
alias ...='cd ../..'
alias tree='eza --tree --icons'
alias ls='eza --icons'
alias ll='eza -la --icons'
alias la='eza -a  --icons'
alias cat='bat --style=plain --paging=never'
alias grep='rg'
alias cp='rclone copy --progress --multi-thread-streams=8 --transfers=8'
alias mv='rclone move --progress --multi-thread-streams=8 --transfers=8'
alias sync='rclone sync --progress --multi-thread-streams=8 --transfers=8'
alias ff='fastfetch'
alias py13='python3.13'
alias py='python3.12'
alias htop='btop'
alias files='ranger'

alias niggabob='kitten icat --align left /home/aveline/Downloads/niggabob.jpg'

abbr -a find fd
abbr -a up 'yay -Syu'
abbr -a i 'yay -S'
abbr -a r 'yay -Rs'
abbr -a yc 'yay -Sc'
abbr -a yo 'yay -Qtdq'
abbr -a yor 'yay -Rns $(yay -Qtdq)'

set fish_greeting

if not string match -q 'vscode*' -- $TERM_PROGRAM \
        && test "$FASTFETCH_SKIP" != 1

    fastfetch

    echo ""

    set _kern (uname -r)
    set _arch (uname -m)
    echo "Linux $_kern $_arch"

    if set -q HYPRLAND_INSTANCE_SIGNATURE
        set _wm Hyprland
        set _display $WAYLAND_DISPLAY
        set _wmver (hyprctl version 2>/dev/null | string match -r 'v[\d.]+' | head -1)
        echo "$_wm $_wmver, wayland display on :$_display"
    else if set -q SWAYSOCK
        set _display $WAYLAND_DISPLAY
        echo "Sway, wayland display on :$_display"
    else if set -q DISPLAY
        echo "display $DISPLAY"
    end

    set _up_s (string split ' ' (cat /proc/uptime))[1]
    set _up_s (math -s0 $_up_s)
    set _up_h (math -s0 "$_up_s / 3600")
    set _up_m (math -s0 "($_up_s % 3600) / 60")
    set _users (who 2>/dev/null | wc -l | string trim)
    echo "uptime $_up_h:$(printf '%02d' $_up_m), $_users user"

    if command -sq pacman
        set _pkgs (pacman -Qq 2>/dev/null | wc -l | string trim)
        echo "pacman: $_pkgs packages"
    else if command -sq dpkg
        set _pkgs (dpkg -l 2>/dev/null | grep -c '^ii' | string trim)
        echo "dpkg: $_pkgs packages"
    end

    set _iface (ip -o -4 addr show 2>/dev/null | grep -v '127.0.0.1' | head -1)
    if test -n "$_iface"
        set _ifname (echo $_iface | awk '{print $2}')
        set _ifip (echo $_iface | awk '{print $4}' | string replace -r '/.*' '')
        echo "$_ifname: $_ifip"
    else
        echo "network: no interface"
    end

    date '+%Y-%m-%d %H:%M:%S'

    echo ""

end

function reload
    set -gx FASTFETCH_SKIP 1

    echo (set_color --bold cyan)╭───────────────(set_color normal)
    echo (set_color --bold cyan)│(set_color normal) Reloading fish config …
    source ~/.config/fish/config.fish
    echo (set_color --bold cyan)│(set_color normal) Done ✓
    echo (set_color --bold cyan)╰───────────────(set_color normal)

    set -gx FASTFETCH_SKIP 0
end

function config
    code ~/.config/fish/
end

function weather
    curl -s "wttr.in/$argv?format=3"
end

function my_postexec --on-event fish_postexec
    if not string match -q 'vscode*' -- $TERM_PROGRAM \
            && test "$FASTFETCH_SKIP" != 1
        mommy -1 -s $status
    end
end

function fish_prompt
    set -l last_status $status

    if test $last_status -ne 0
        echo -n (set_color red)"exit $last_status  "(set_color normal)
    end

    echo -n (whoami)"@"(hostname -s)
    echo -n " "(prompt_pwd)
    echo -n " % "
end

function fish_right_prompt
    command git rev-parse --git-dir >/dev/null 2>&1 || return

    set -l branch (git branch --show-current 2>/dev/null)
    test -z "$branch"; and set branch (git rev-parse --short HEAD 2>/dev/null)

    set -l git_status (git --no-optional-locks status --porcelain 2>/dev/null)
    set -l staged (string match -r '^[AMD]' $git_status | count)
    set -l dirty (string match -r '^.M|^.D' $git_status | count)
    set -l untracked (string match -r '^\?\?' $git_status | count)
    set -l ahead (git rev-list --count @{u}..HEAD 2>/dev/null; or echo 0)
    set -l behind (git rev-list --count HEAD..@{u} 2>/dev/null; or echo 0)

    set -l status_parts

    test "$staged" -gt 0; and set -a status_parts "+$staged"
    test "$dirty" -gt 0; and set -a status_parts "~$dirty"
    test "$untracked" -gt 0; and set -a status_parts "?$untracked"
    test "$ahead" -gt 0; and set -a status_parts "^$ahead"
    test "$behind" -gt 0; and set -a status_parts "v$behind"

    echo -n "  $branch"

    if test (count $status_parts) -gt 0
        echo -n " ["(string join " " $status_parts)"]"
    end
end

set PATH $PATH $HOME/go/bin

# Created by `pipx` on 2025-08-21 21:25:19
set PATH $PATH $HOME/.local/bin

# Added by LM Studio CLI (lms)
set -gx PATH $PATH /home/aveline/.lmstudio/bin
# End of LM Studio CLI section

# Generated for envman. Do not edit.
test -s ~/.config/envman/load.fish; and source ~/.config/envman/load.fish
