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
    # Hyprland & Wayland Ecosystem
    "hyprland"
    "waybar"
    "mako"
    "fuzzel"
    "uwsm"

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
    "ttf-fira-code-nerd"
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

echo "-> Installing official packages..."
sudo pacman -S --needed --noconfirm "${PACMAN_PACKAGES[@]}"

echo "-> Installing AUR packages..."
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
    source "$HOME/.bash_profile"
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
sudo usermod -aG docker $USER
# installing important dbs for setup
docker pull mysql:8
docker pull redis:7
docker pull postgres:16

# Setup Flatpak flathub repo
flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo

# 6. Install Caelestia Core Dots
echo "-> Installing Caelestia Dots from Git..."
if [ ! -d "$HOME/.local/share/caelestia" ]; then
    git clone https://github.com/caelestia-dots/caelestia.git "$HOME/.local/share/caelestia"
fi
fish "$HOME/.local/share/caelestia/install.fish" --noconfirm --aur-helper yay

# 7. Stow Dotfiles
echo "-> Creating symlinks with GNU Stow..."
if [ -d "$HOME/dotfiles" ]; then
    cd "$HOME/dotfiles" || exit 1
    packages=(kitty wezterm tmux nvim hyprland btop fastfetch fish foot starship.toml cava lazygit lazydocker mpv imv alacritty vlc)
    for pkg in "${packages[@]}"; do
        echo "   Stowing $pkg..."
        conflicts=$(stow --no --verbose=1 "$pkg" 2>&1 | awk '/existing target is not owned by stow: /{print $NF}' | sort -u)
        for conflict in $conflicts; do
            if [ -e "$HOME/$conflict" ]; then
                echo "   Backing up $HOME/$conflict to $HOME/${conflict}_bak"
                mv "$HOME/$conflict" "$HOME/${conflict}_bak"
            fi
        done
        stow "$pkg"
    done
else
    echo "Warning: ~/dotfiles directory not found. Skipping Stow."
fi

cp ./aliasis.bash ~/.config/aliasis.bash

echo 'eval "$(starship init bash)"' >> ~/.bashrc
echo 'eval "$(zoxide init bash)"' >> ~/.bashrc
echo 'source ~/.config/aliasis.bash' >> ~/.bashrc

echo "=========================================="
echo "✅ Setup completely finished!"
echo "System services (Docker) have been enabled."
echo "Please restart your computer or log out for group permissions (like docker) to apply."
echo "You may also want to set your default shell:"
echo "chsh -s $(which fish)"
echo "=========================================="
