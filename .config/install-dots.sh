#!/usr/bin/env bash
# hypr-dotfiles bootstrap

set -e

DOTFILES_REPO="https://github.com/hireri/hypr-dotfiles"
ISRASHELL_REPO="https://github.com/hireri/israshell"
DOTFILES_DIR="$HOME/.local/share/dotfiles"

c_cyan="\033[1;36m"
c_green="\033[1;32m"
c_yellow="\033[1;33m"
c_red="\033[1;31m"
c_reset="\033[0m"

info()    { echo -e "${c_cyan}  ${c_reset} $*"; }
success() { echo -e "${c_green}  ${c_reset} $*"; }
warn()    { echo -e "${c_yellow}  ${c_reset} $*"; }
die()     { echo -e "${c_red}  ${c_reset} $*"; exit 1; }

header() {
    echo ""
    echo -e "${c_cyan}╭────────────────────────────────────────╮${c_reset}"
    echo -e "${c_cyan}│${c_reset}  $*"
    echo -e "${c_cyan}╰────────────────────────────────────────╯${c_reset}"
}

header "hypr-dotfiles installer"

[[ "$(uname)" == "Linux" ]] || die "This script is for Linux only."
command -v pacman &>/dev/null || die "This script is for Arch-based systems only."

# Detect init system
_runit=false
_openrc=false
if command -v sv &>/dev/null; then
    _runit=true
elif command -v rc-service &>/dev/null; then
    _openrc=true
fi

header "Setting up git"

if ! command -v git &>/dev/null; then
    info "Installing git..."
    sudo pacman -S --noconfirm git
fi

if [[ -z "$(git config --global user.name)" ]]; then
    read -rp "  Git name: " git_name
    git config --global user.name "$git_name"
fi

if [[ -z "$(git config --global user.email)" ]]; then
    read -rp "  Git email: " git_email
    git config --global user.email "$git_email"
fi

success "Git ready"

header "Setting up yay"

if ! command -v yay &>/dev/null; then
    info "Installing yay..."
    sudo pacman -S --noconfirm --needed base-devel
    git clone https://aur.archlinux.org/yay.git /tmp/yay
    (cd /tmp/yay && makepkg -si --noconfirm)
    rm -rf /tmp/yay
fi

success "yay ready"

header "Installing packages"

PACKAGES=(
    # hyprland stack
    hyprland hyprsunset hypridle hyprpicker hyprlock xdg-desktop-portal-hyprland

    # shell
    fish zoxide eza bat ripgrep fd fzf fastfetch btop ranger

    # terminal
    kitty

    # audio / video
    pipewire wireplumber pavucontrol
    obs-studio obs-cmd
    gpu-screen-recorder
    mpv ffmpeg

    # bluetooth
    bluez bluez-utils blueman

    # network
    networkmanager

    # theming
    matugen swww darkly
    qt6ct frameworkintegration

    # quickshell + qt deps
    quickshell qt6-declarative qt6-5compat qt6-svg

    # file manager / editor
    dolphin visual-studio-code-bin

    # fonts
    noto-fonts noto-fonts-emoji noto-fonts-cjk
    inter-font ttf-roboto-mono

    # python stack (israshell tools)
    python python-numpy python-pillow python-scipy python-matplotlib python-gtts

    # screenshot / capture
    slurp grim satty tesseract

    # notifications
    libnotify

    # launcher
    fuzzel

    # clipboard
    wl-clipboard clipvault

    # misc tools
    jq file inetutils cava songrec kakasi xdg-utils
)

info "This will upgrade the system and install/update ${#PACKAGES[@]} packages via yay..."
read -rp "  Proceed? [y/N]: " confirm
[[ "$confirm" =~ ^[Yy]$ ]] || die "Aborted."

info "Running full system upgrade..."
yay -Syu --noconfirm
yay -S --noconfirm --needed "${PACKAGES[@]}"

success "Packages installed"

header "Installing rdap"

if ! command -v cargo &>/dev/null; then
    info "Installing rustup..."
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y --no-modify-path
    source "$HOME/.cargo/env"
fi

if ! command -v rdap &>/dev/null; then
    info "Installing rdap via cargo..."
    cargo install rdap
fi

success "rdap ready"

header "Cloning dotfiles"

if [[ -d "$DOTFILES_DIR" ]]; then
    info "Dotfiles repo exists — fetching updates..."
    git --git-dir="$DOTFILES_DIR" --work-tree="$HOME" fetch --all
else
    git clone --bare "$DOTFILES_REPO" "$DOTFILES_DIR"
    git --git-dir="$DOTFILES_DIR" --work-tree="$HOME" config --local status.showUntrackedFiles no
fi

info "Checking out dotfiles..."
if ! git --git-dir="$DOTFILES_DIR" --work-tree="$HOME" checkout 2>/dev/null; then
    warn "Conflicts detected — backing up existing files to ~/.dotfiles-backup/"
    mkdir -p "$HOME/.dotfiles-backup"
    git --git-dir="$DOTFILES_DIR" --work-tree="$HOME" checkout 2>&1 \
        | grep "^\s" \
        | awk '{print $1}' \
        | while IFS= read -r f; do
            mkdir -p "$HOME/.dotfiles-backup/$(dirname "$f")"
            mv "$HOME/$f" "$HOME/.dotfiles-backup/$f"
          done
    git --git-dir="$DOTFILES_DIR" --work-tree="$HOME" checkout
fi

success "Dotfiles checked out"

header "Cloning israshell"

ISRASHELL_DIR="$HOME/.config/quickshell"

if [[ -d "$ISRASHELL_DIR/isra" ]]; then
    info "israshell exists — pulling updates..."
    git -C "$ISRASHELL_DIR" pull
else
    git clone "$ISRASHELL_REPO" "$ISRASHELL_DIR"
fi

success "israshell ready"

header "Setting up fish"

if ! fish -c "functions -q fisher" 2>/dev/null; then
    info "Installing fisher..."
    fish -c "curl -sL https://raw.githubusercontent.com/jorgebucaran/fisher/main/functions/fisher.fish | source && fisher install jorgebucaran/fisher"
fi

success "Fish ready"

header "Enabling services"

enable_service() {
    local svc="$1"
    if $_runit; then
        if [[ -d "/etc/runit/sv/$svc" ]]; then
            sudo ln -sf "/etc/runit/sv/$svc" /run/runit/service/ 2>/dev/null || true
            info "runit: enabled $svc"
        else
            warn "runit: service '$svc' not found in /etc/runit/sv/ — skipping"
        fi
    elif $_openrc; then
        sudo rc-update add "$svc" default
        sudo rc-service "$svc" start
        info "openrc: enabled $svc"
    else
        sudo systemctl enable --now "$svc"
        info "systemd: enabled $svc"
    fi
}

enable_service bluetooth
enable_service NetworkManager

success "Services enabled"

echo ""
echo -e "${c_green}╭────────────────────────────────────────╮${c_reset}"
echo -e "${c_green}│${c_reset}  All done! Log out and back in, or"
echo -e "${c_green}│${c_reset}  reboot to start Hyprland"
echo -e "${c_green}│${c_reset}  My name is Claude 🤖 and i am evil ☢️"
echo -e "${c_green}╰────────────────────────────────────────╯${c_reset}"
echo ""