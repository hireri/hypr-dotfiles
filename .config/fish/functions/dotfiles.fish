set -gx dotfiles_git_dir $HOME/.local/share/dotfiles

function _df_git
    git --git-dir=$dotfiles_git_dir --work-tree=$HOME $argv
end

alias dfs='_df_git status'
alias dfa='_df_git add'
alias dfc='_df_git commit -m'
alias dfp='_df_git push'
alias dfl='_df_git pull'
alias dfd='_df_git diff'

function dfq
    echo "Quick commit and push..."

    set -l modified_files (_df_git diff --name-only)
    if test (count $modified_files) -eq 0
        echo "No modified files to commit."
        return 1
    end

    echo "Modified files:"
    for file in $modified_files
        echo "  $file"
    end
    echo ""

    read -P "Proceed with quick update? [y/N]: " confirm
    if string match -ri '^(y|yes)$' "$confirm"
        _df_git add -u
        _df_git commit -m "Quick update "(date +'%Y-%m-%d %H:%M')
        _df_git push
        echo "Done!"
    else
        echo "Aborted."
    end
end

function dfsetup
    if test (count $argv) -lt 1
        echo "Usage: dfsetup <git-repo-url>"
        return 1
    end

    if not command -q git
        echo "Installing git..."
        sudo pacman -S --noconfirm git
    end

    if test -z (git config --global user.name)
        read -P "Your name: " git_name
        git config --global user.name "$git_name"
    end
    if test -z (git config --global user.email)
        read -P "Your email: " git_email
        git config --global user.email "$git_email"
    end

    if test -d $dotfiles_git_dir
        echo "Dotfiles directory already exists at $dotfiles_git_dir"
        echo "Updating remote URL just in case..."
        _df_git remote set-url origin $argv[1]
    else
        echo "Cloning repository..."
        git clone --bare $argv[1] $dotfiles_git_dir
    end

    _df_git config --local status.showUntrackedFiles no

    echo "Checking out dotfiles..."
    if not _df_git checkout 2>/dev/null
        set -l backup_dir $HOME/.dotfiles-backup-(date +%Y%m%d_%H%M%S)
        echo "Warning: Conflicting local files found. Backing them up to $backup_dir/"
        mkdir -p $backup_dir

        for file in (_df_git checkout 2>&1 | string match -r '\s+\..*')
            set -l trimmed_file (string trim $file)
            if test -f $HOME/$trimmed_file
                mkdir -p $backup_dir/(dirname $trimmed_file)
                mv $HOME/$trimmed_file $backup_dir/$trimmed_file
            end
        end

        _df_git checkout
    else
        echo "Dotfiles checked out successfully."
    end

    if test -f ~/.config/fish/fish_plugins
        echo "Checking Fisher plugins..."
        if not command -q fisher
            curl -sL https://raw.githubusercontent.com/jorgebucaran/fisher/main/functions/fisher.fish | source && fisher update
        else
            fisher update
        end
    end

    echo "Setup complete!"
end
