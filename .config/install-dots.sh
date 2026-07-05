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

_runit=false
_openrc=false
_systemd=false
if [[ -d /etc/runit ]] && command -v sv &>/dev/null; then
    _runit=true
elif command -v rc-service &>/dev/null && [[ -d /etc/init.d ]]; then
    _openrc=true
elif [[ -d /run/systemd/system ]]; then
    _systemd=true
else
    warn "Could not confidently detect init system — assuming systemd"
    _systemd=true
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
    hyprland hyprsunset hypridle hyprpicker hyprlock xdg-desktop-portal-hyprland

    # session / seat management (needed on runit; harmless no-op alongside systemd-logind)
    seatd

    # display manager (drives login -> Hyprland on both init systems)
    greetd

    # dbus (session + system bus, required by quickshell/notifications/polkit/NM)
    dbus

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
if ! git --git-dir="$DOTFILES_DIR" --work-tree="$HOME" checkout 2>/tmp/checkout-err; then
    warn "Conflicts detected — backing up existing files to ~/.dotfiles-backup/"
    mkdir -p "$HOME/.dotfiles-backup"

    grep $'^\t' /tmp/checkout-err \
        | sed 's/^\t//' \
        | while IFS= read -r f; do
            [[ -f "$HOME/$f" ]] || continue
            mkdir -p "$HOME/.dotfiles-backup/$(dirname "$f")"
            mv "$HOME/$f" "$HOME/.dotfiles-backup/$f"
          done
    git --git-dir="$DOTFILES_DIR" --work-tree="$HOME" checkout
fi
rm -f /tmp/checkout-err

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

if [[ "$SHELL" != "$(command -v fish)" ]]; then
    info "Setting fish as default shell..."
    chsh -s "$(command -v fish)"
fi

success "Fish ready"

header "Setting up seat management"

if $_runit || $_openrc; then
    sudo usermod -aG seat "$USER" 2>/dev/null || warn "Could not add $USER to seat group — check manually"
else
    info "systemd detected — seatd is optional (logind handles seat management); installed anyway for consistency"
fi

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
enable_service dbus
$_runit && enable_service seatd

success "Services enabled"

header "Installing tuigreet (fork)"

if ! command -v tuigreet &>/dev/null; then
    info "Installing greetd-tuigreet-fork-bin from AUR..."
    yay -S --noconfirm --needed greetd-tuigreet-fork-bin
fi

success "tuigreet ready"

header "Configuring greetd"

sudo mkdir -p /etc/greetd
GREETD_CONFIG="/etc/greetd/config.toml"

TUIGREET_CMD="tuigreet --time --remember --remember-session --cmd Hyprland"

if [[ -f "$GREETD_CONFIG" ]]; then
    info "Existing $GREETD_CONFIG found — leaving it as-is (back it up manually if you want a clean overwrite)"
else
    sudo tee "$GREETD_CONFIG" >/dev/null <<EOF
[terminal]
vt = 1

[default_session]
command = "$TUIGREET_CMD"
user = "greeter"
EOF
    success "Wrote $GREETD_CONFIG"
fi

header "Setting up login -> Hyprland"

greetd_service_exists=false
if $_systemd; then
    greetd_service_exists=true
elif $_runit && [[ -d /etc/runit/sv/greetd ]]; then
    greetd_service_exists=true
elif $_openrc && [[ -f /etc/init.d/greetd ]]; then
    greetd_service_exists=true
fi

if $greetd_service_exists; then
    enable_service greetd
    success "greetd enabled — tuigreet will prompt for login on boot"
elif $_runit; then
    warn "No /etc/runit/sv/greetd found. The main 'greetd' AUR package does not"
    warn "ship a runit service — you need 'greetd-runit' from the AUR, or a"
    warn "hand-written run script in /etc/runit/sv/greetd/run. Attempting to"
    warn "install greetd-runit now..."
    if yay -S --noconfirm --needed greetd-runit 2>/dev/null && [[ -d /etc/runit/sv/greetd ]]; then
        enable_service greetd
        success "greetd-runit installed and enabled"
    else
        die "greetd-runit not available or install failed. Fix this manually before rebooting, or you will land at a bare TTY with no session launcher. See greetd's own repo for the runit run-script reference: https://git.sr.ht/~kennylevinsen/greetd"
    fi
else
    warn "No greetd service file found for this init system — falling back to TTY autologin"
    info "Add Hyprland launch to fish config, gated to tty1"
    FISH_CONFIG="$HOME/.config/fish/config.fish"
    mkdir -p "$(dirname "$FISH_CONFIG")"
    if ! grep -q "exec Hyprland" "$FISH_CONFIG" 2>/dev/null; then
        cat >> "$FISH_CONFIG" <<'EOF'

if status is-login
    and test (tty) = /dev/tty1
    and not set -q WAYLAND_DISPLAY
    exec Hyprland
end
EOF
        success "Added Hyprland autostart to $FISH_CONFIG"
    else
        info "Hyprland autostart already present in $FISH_CONFIG"
    fi
    warn "You will still need a getty autologin on tty1 for a truly hands-off login."
    warn "Manual step: run 'sudo systemctl edit getty@tty1' (systemd) or configure"
    warn "  /etc/runit/sv/agetty-tty1/conf (runit) to add --autologin $USER"
fi

echo ""
echo -e "${c_green}╭────────────────────────────────────────╮${c_reset}"
echo -e "${c_green}│${c_reset}  All done! Log out and back in, or"
echo -e "${c_green}│${c_reset}  reboot to start Hyprland"
echo -e "${c_green}╰────────────────────────────────────────╯${c_reset}"
echo ""