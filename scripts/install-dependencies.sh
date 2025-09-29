#!/bin/bash
# scripts/install-dependencies.sh - Install all required packages and dependencies
# This script detects your package manager and installs everything needed for the terminal setup
# Includes: ZSH, Git, modern CLI tools, Rust toolchain, Node.js, and Nerd Fonts

set -euo pipeline  # Exit on any error, undefined variables, and pipe failures

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Helper functions
print_status() { echo -e "${BLUE}[INFO]${NC} $1"; }
print_success() { echo -e "${GREEN}[SUCCESS]${NC} $1"; }
print_error() { echo -e "${RED}[ERROR]${NC} $1"; }

# Detect which package manager the system uses
# Different Linux distributions use different package managers
detect_package_manager() {
    if command -v apt-get &> /dev/null; then
        # Debian/Ubuntu use apt-get
        export PKG_MANAGER="apt"
        export INSTALL_CMD="sudo apt-get update && sudo apt-get install -y"
    elif command -v dnf &> /dev/null; then
        # Fedora/RHEL 8+ use dnf
        export PKG_MANAGER="dnf"
        export INSTALL_CMD="sudo dnf install -y"
    elif command -v yum &> /dev/null; then
        # Older RHEL/CentOS use yum
        export PKG_MANAGER="yum"
        export INSTALL_CMD="sudo yum install -y"
    elif command -v pacman &> /dev/null; then
        # Arch Linux uses pacman
        export PKG_MANAGER="pacman"
        export INSTALL_CMD="sudo pacman -S --noconfirm"
    else
        print_error "No supported package manager found!"
        exit 1
    fi
    
    print_status "Detected package manager: $PKG_MANAGER"
}

# Install basic dependencies that are essential for everything else
# These are the foundation tools needed before we can install anything fancy
install_basic_deps() {
    print_status "Installing basic dependencies..."
    
    case $PKG_MANAGER in
        "apt")
            # Ubuntu/Debian package names
            $INSTALL_CMD zsh git curl wget build-essential software-properties-common \
                        apt-transport-https ca-certificates gnupg lsb-release \
                        util-linux-user fzf ripgrep fd-find bat exa tmux vim
            ;;
        "dnf")
            # Fedora package names
            $INSTALL_CMD zsh git curl wget @development-tools \
                        util-linux-user fzf ripgrep fd-find bat exa tmux vim
            ;;
        "yum")
            # CentOS/RHEL package names
            $INSTALL_CMD zsh git curl wget gcc gcc-c++ make \
                        util-linux-user tmux vim
            ;;
        "pacman")
            # Arch Linux package names
            $INSTALL_CMD zsh git curl wget base-devel \
                        fzf ripgrep fd bat exa tmux vim
            ;;
    esac
    
    print_success "Basic dependencies installed"
}

# Install Node.js for tools that need JavaScript runtime
# Some terminal tools and plugins require Node.js
install_nodejs() {
    if ! command -v node &> /dev/null; then
        print_status "Installing Node.js..."
        curl -fsSL https://deb.nodesource.com/setup_lts.x | sudo -E bash -
        sudo apt-get install -y nodejs
        print_success "Node.js installed"
    else
        print_status "Node.js already installed"
    fi
}

# Install Rust programming language and cargo package manager
# Many modern CLI tools are written in Rust for speed and safety
install_rust_tools() {
    if ! command -v cargo &> /dev/null; then
        print_status "Installing Rust..."
        curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
        source ~/.cargo/env
        print_success "Rust installed"
    fi
    
    print_status "Installing Rust-based tools..."
    
    # List of tools to install if they're not available via package manager
    # These are much faster than their traditional counterparts
    tools_to_install=()
    
    if ! command -v bat &> /dev/null; then
        tools_to_install+=("bat")  # Better cat with syntax highlighting
    fi
    
    if ! command -v exa &> /dev/null; then
        tools_to_install+=("exa")  # Better ls with colors and icons
    fi
    
    if ! command -v rg &> /dev/null; then
        tools_to_install+=("ripgrep")  # Faster grep
    fi
    
    if ! command -v fd &> /dev/null; then
        tools_to_install+=("fd-find")  # Faster find
    fi
    
    # Install any tools that weren't available via package manager
    if [ ${#tools_to_install[@]} -gt 0 ]; then
        cargo install "${tools_to_install[@]}"
        print_success "Rust tools installed"
    fi
}

# Install Nerd Fonts which include icons and symbols for a prettier terminal
# These fonts display git icons, folder icons, file type icons, etc.
install_fonts() {
    print_status "Installing Nerd Fonts..."
    
    # Create fonts directory if it doesn't exist
    mkdir -p ~/.local/share/fonts
    
    # Download and install FiraCode Nerd Font (popular monospace font with ligatures)
    cd /tmp
    wget https://github.com/ryanoasis/nerd-fonts/releases/download/v3.0.2/FiraCode.zip
    unzip -o FiraCode.zip -d ~/.local/share/fonts/
    rm FiraCode.zip
    
    # Update font cache so the system knows about our new fonts
    fc-cache -fv
    
    print_success "Nerd Fonts installed"
}

# Main installation function that calls everything in order
main() {
    detect_package_manager
    install_basic_deps
    
    # Install Node.js on Ubuntu/Debian systems
    if [ "$PKG_MANAGER" = "apt" ]; then
        install_nodejs
    fi
    
    install_rust_tools
    install_fonts
    
    print_success "All dependencies installed successfully!"
}

main "$@"
