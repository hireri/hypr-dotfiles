zoxide init fish | source
test -f ~/.config/fish/functions/dotfiles.fish && source ~/.config/fish/functions/dotfiles.fish

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

abbr -a find 'fd'
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
end

function reload
    set -gx FASTFETCH_SKIP 1

    echo (set_color --bold cyan)╭───────────────(set_color normal)
    echo (set_color --bold cyan)│(set_color normal)  Reloading fish config …
    source ~/.config/fish/config.fish
    echo (set_color --bold cyan)│(set_color normal)  Done ✓
    echo (set_color --bold cyan)╰───────────────(set_color normal)
end

function config
    code ~/.config/fish/
end

function weather
    curl -s "wttr.in/$argv?format=3"
end

function fish_prompt
    set -l last_status $status
    
    if test $last_status -ne 0
        echo -n (set_color --bold red)"[$last_status] "(set_color normal)
    end
    
    echo -n (set_color --bold cyan)(whoami)(set_color normal)
    echo -n (set_color white)"@"(set_color normal)
    echo -n (set_color --bold blue)(hostname -s)(set_color normal)
    
    echo -n (set_color --bold magenta)" "(prompt_pwd)(set_color normal)
    
    echo -n (set_color --bold yellow)" ➜ "(set_color normal)
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
    test "$staged" -gt 0; and set -a status_parts (set_color green)" "$staged(set_color normal)
    test "$dirty" -gt 0; and set -a status_parts (set_color yellow)" "$dirty(set_color normal)
    test "$untracked" -gt 0; and set -a status_parts (set_color red)" "$untracked(set_color normal)
    test "$ahead" -gt 0; and set -a status_parts (set_color cyan)" "$ahead(set_color normal)
    test "$behind" -gt 0; and set -a status_parts (set_color magenta)" "$behind(set_color normal)

    echo -n " "
    echo -n (set_color brblack)"on "(set_color normal)
    echo -n (set_color --bold blue)" "$branch(set_color normal)
    
    if test (count $status_parts) -gt 0
        echo -n " "(string join "  " $status_parts)
    end
end

# Created by `pipx` on 2025-08-21 21:25:19
set PATH $PATH $HOME/.local/bin

# Added by LM Studio CLI (lms)
set -gx PATH $PATH /home/aveline/.lmstudio/bin
# End of LM Studio CLI section

# Generated for envman. Do not edit.
test -s ~/.config/envman/load.fish; and source ~/.config/envman/load.fish
