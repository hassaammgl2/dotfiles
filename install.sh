#!/bin/bash

echo "=========================================="
echo "🚀 Starting System Setup for Dotfiles..."
echo "=========================================="

# 1. Ask for sudo password upfront
sudo -v

# Keep sudo alive until script finishes
while true; do sudo -n true; sleep 60; kill -0 "$$" || exit; done 2>/dev/null &

echo "-> Updating system repositories..."
sudo pacman -Syu --noconfirm

echo "-> Installing base dependencies..."
sudo pacman -S --needed --noconfirm base-devel git stow curl wget unzip

# 2. Install YAY (AUR Helper)
if ! command -v yay &> /dev/null; then
    echo "-> Installing yay..."
    git clone https://aur.archlinux.org/yay.git /tmp/yay
    cd /tmp/yay
    makepkg -si --noconfirm
    cd -
    rm -rf /tmp/yay
else
    echo "-> yay is already installed."
fi

# 3. Define packages to install

PACMAN_PACKAGES=(
    "kitty"
    "tmux"
    "neovim"
    "fish"
    "starship"
    "fastfetch"
    "btop"
    "wl-clipboard"
    "unzip"
    "eza"
    "fzf"
    "zoxide"
    "git"
    "bat"
    "ripgrep"
    "fd"
    "ntfs-3g"

    # Hyprland & Wayland Ecosystem
    "hyprland"
    "waybar"
    "mako"
    "fuzzel"
    "uwsm"
    "hyprpaper"
    "xdg-desktop-portal"
    "xdg-desktop-portal-hyprland"
    "polkit-kde-agent"
    "qt5-wayland"
    "qt6-wayland"
    "grim"
    "slurp"

    # Audio
    "pipewire"
    "pipewire-pulse"
    "pipewire-alsa"
    "wireplumber"

    # Browsers
    "firefox"

    # General Software & Tools
    "python"
    "python-pip"
    "uv"
    "lazygit"
    "lazydocker"

    # Fonts
    "ttf-victor-mono-nerd"
    "ttf-jetbrains-mono-nerd"
    "noto-fonts"
    "noto-fonts-emoji"

    # Containerization
    "docker"
    "docker-compose"

    # App Store & Sandboxing
    "flatpak"
    "gnome-software"

    # CLI Utilities & Media
    "vlc"
    "vlc-plugins-all"
    "mpv"
    "imv"
    "cava"
)

AUR_PACKAGES=(
    "swayosd-git"
    "google-chrome"
    "brave-bin"
    "visual-studio-code-bin"
    "antigravity"
    "caelestia-shell"
    "caelestia-cli"
)

sudo mkdir -p /mnt/codes

echo "-> Installing official packages..."
sudo pacman -S --needed --noconfirm "${PACMAN_PACKAGES[@]}"

echo "-> Installing AUR packages..."
# Handle swayosd conflict if it exists
if pacman -Qs swayosd-git > /dev/null; then
    echo "   swayosd-git already installed."
elif pacman -Qs swayosd > /dev/null; then
    echo "   Removing conflicting swayosd package..."
    sudo pacman -Rns --noconfirm swayosd
fi
yay -S --needed --noconfirm "${AUR_PACKAGES[@]}"

# 4. Setup Development Environments (Node, Bun, Rust)
echo "-> Setting up Development Environments..."

# Install NVM and Node.js
if [ ! -d "$HOME/.nvm" ]; then
    echo "Installing NVM & Node.js..."
    curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash
    export NVM_DIR="$HOME/.nvm"
    [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
    nvm install node
    nvm use node
fi

# Install Bun
if [ ! -d "$HOME/.bun" ]; then
    echo "Installing Bun..."
    curl -fsSL https://bun.sh/install | bash
fi

# Install Rust & Cargo
if ! command -v rustc &> /dev/null; then
    echo "Installing Rust & Cargo..."
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
    source "$HOME/.cargo/env"
fi

# installing tree-sitter
cargo install tree-sitter-cli

# 5. Enable System Services
echo "-> Enabling System Services..."
sudo systemctl enable --now docker.service
sudo usermod -aG docker "$USER"
systemctl --user enable --now pipewire pipewire-pulse wireplumber

# pulling images (will not auto-start dbs)
echo "-> Pulling Docker images..."
docker pull mysql:8
docker pull redis:7
docker pull postgres:16
docker pull searxng/searxng:latest

# Setup Flatpak flathub repo
flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo

# 6. Initialize & Auto-start SearXNG
echo "-> Setting up SearXNG..."
mkdir -p "$HOME/searxng"
if [ ! -f "$HOME/searxng/settings.yml" ]; then
    echo "   Creating default SearXNG settings..."
    cat > "$HOME/searxng/settings.yml" << EOF
use_default_settings: true
server:
    port: 8080
    bind_address: "0.0.0.0"
    secret_key: "$(openssl rand -hex 32)"
EOF
fi

# Start SearXNG with auto-restart on boot
if ! docker ps -a --format '{{.Names}}' | grep -q '^searxng$'; then
    echo "   Starting SearXNG container..."
    docker run -d \
        --name searxng \
        --restart always \
        -p 8080:8080 \
        -v "$HOME/searxng:/etc/searxng" \
        searxng/searxng:latest
fi

# 7. Install Caelestia Core Dots
echo "-> Installing Caelestia Dots from Git..."
if [ ! -d "$HOME/.local/share/caelestia" ]; then
    git clone https://github.com/caelestia-dots/caelestia.git "$HOME/.local/share/caelestia"
fi
fish "$HOME/.local/share/caelestia/install.fish" --noconfirm --aur-helper yay

# 8. Stow Dotfiles
echo "-> Creating symlinks with GNU Stow..."
if [ -d "$HOME/dotfiles" ]; then
    cd "$HOME/dotfiles" || exit 1
    packages=(kitty wezterm tmux nvim hyprland btop fastfetch fish foot starship.toml cava lazygit lazydocker mpv imv alacritty vlc)
    for pkg in "${packages[@]}"; do
        echo "   Stowing $pkg..."
        stow --restow "$pkg" 2>/dev/null || {
            echo "   Conflict detected in $pkg — attempting backup and retry..."
            stow --no --verbose=2 "$pkg" 2>&1 | grep 'existing target' | awk '{print $NF}' | while read -r conflict; do
                [ -e "$HOME/$conflict" ] && mv "$HOME/$conflict" "$HOME/${conflict}.bak"
            done
            stow "$pkg"
        }
    done
else
    echo "Warning: ~/dotfiles directory not found. Skipping Stow."
fi

# Copy aliases and fix bad fzf paths inside it
mkdir -p ~/.config
cp ./aliasis.bash ~/.config/aliasis.bash
sed -i 's|source /usr/share/fzf/key-bindings.bash||' ~/.config/aliasis.bash
sed -i 's|source /usr/share/fzf/completion.bash||' ~/.config/aliasis.bash

# Fix fzf to use actual install location (git or pacman)
cat > ~/.fzf.bash << 'EOF'
if [ -d "$HOME/.fzf" ]; then
    export PATH="$HOME/.fzf/bin:$PATH"
    [[ -f "$HOME/.fzf/shell/key-bindings.bash" ]] && source "$HOME/.fzf/shell/key-bindings.bash"
    [[ -f "$HOME/.fzf/shell/completion.bash" ]] && source "$HOME/.fzf/shell/completion.bash"
elif [ -d "/usr/share/fzf" ]; then
    [[ -f "/usr/share/fzf/key-bindings.bash" ]] && source "/usr/share/fzf/key-bindings.bash"
    [[ -f "/usr/share/fzf/completion.bash" ]] && source "/usr/share/fzf/completion.bash"
fi
EOF

# Append to .bashrc idempotently
add_to_bashrc() {
    grep -qxF "$1" ~/.bashrc || echo "$1" >> ~/.bashrc
}
add_to_bashrc 'eval "$(starship init bash)"'
add_to_bashrc 'eval "$(zoxide init bash)"'
add_to_bashrc 'source ~/.config/aliasis.bash'
add_to_bashrc '[ -f ~/.fzf.bash ] && source ~/.fzf.bash'

echo "=========================================="
echo "✅ Setup completely finished!"
echo ""
echo "Next steps:"
echo "  1. Restart your system (required for docker group + pipewire)"
echo "  2. Set default shell: chsh -s \$(which fish)"
echo "  3. If Hyprland breaks: journalctl --user -b | grep -i hypr"
echo "  4. SearXNG is now AUTO-STARTING at http://localhost:8080"
echo "=========================================="
