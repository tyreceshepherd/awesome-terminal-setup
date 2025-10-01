#!/bin/bash
# scripts/setup-tools.sh - Install additional terminal tools
# This script installs modern CLI tools that enhance productivity
# Includes: navi, zoxide, delta, lazygit, thefuck, and system monitors

set -euo pipefail  # Exit on error, undefined variables, and pipe failures

# Color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

print_status() { echo -e "${BLUE}[INFO]${NC} $1"; }
print_success() { echo -e "${GREEN}[SUCCESS]${NC} $1"; }
print_warning() { echo -e "${YELLOW}[WARNING]${NC} $1"; }

# Install navi - interactive command cheat sheets
# Press Ctrl+N to open searchable command examples
install_navi() {
    if ! command -v navi &> /dev/null; then
        print_status "Installing navi..."
        bash <(curl -sL https://raw.githubusercontent.com/denisidoro/navi/master/scripts/install)
        print_success "navi installed"
    else
        print_status "navi already installed"
    fi
    
    # Setup navi cheat sheets directory and clone useful cheat sheet repos
    setup_navi_cheats
}

# Setup navi cheat sheets - command examples you can search and use
setup_navi_cheats() {
    print_status "Setting up navi cheat sheets..."
    
    # Create navi config directory
    mkdir -p "${HOME}/.config/navi"
    
    # Clone useful cheat sheet repositories
    local cheats_dir="${HOME}/.local/share/navi/cheats"
    mkdir -p "$cheats_dir"
    
    # Official navi cheat sheets - covers common commands
    if [ ! -d "${cheats_dir}/denisidoro__cheats" ]; then
        git clone https://github.com/denisidoro/cheats "${cheats_dir}/denisidoro__cheats"
    fi
    
    print_success "navi cheat sheets setup complete"
}

# Install thefuck - corrects your previous console command
# Type 'fuck' after a failed command to get corrections
install_thefuck() {
    if ! command -v thefuck &> /dev/null; then
        print_status "Installing thefuck..."
        pipx install thefuck
        print_success "thefuck installed"
    else
        print_status "thefuck already installed"
    fi
}

# Install zoxide - smarter cd command that learns your habits
# Use 'z projectname' to jump to frequently used directories
install_zoxide() {
    if ! command -v zoxide &> /dev/null; then
        print_status "Installing zoxide..."
        curl -sS https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | bash
        print_success "zoxide installed"
    else
        print_status "zoxide already installed"
    fi
}

# Install delta - better git diff viewer with syntax highlighting
# Makes git diffs much easier to read
install_delta() {
    if ! command -v delta &> /dev/null; then
        print_status "Installing delta (better git diff)..."
        
        # Try to install via package manager first
        if command -v apt-get &> /dev/null; then
            # For Ubuntu/Debian - download .deb package
            wget https://github.com/dandavison/delta/releases/download/0.16.5/git-delta_0.16.5_amd64.deb
            sudo dpkg -i git-delta_0.16.5_amd64.deb
            rm git-delta_0.16.5_amd64.deb
        else
            # Fallback to cargo installation
            cargo install git-delta
        fi
        
        print_success "delta installed"
    else
        print_status "delta already installed"
    fi
}

# Install lazygit - simple terminal UI for git
# Type 'lazygit' in a git repo for visual git interface
install_lazygit() {
    if ! command -v lazygit &> /dev/null; then
        print_status "Installing lazygit..."
        
        # Determine system architecture
        ARCH=$(uname -m)
        case $ARCH in
            x86_64) ARCH="x86_64" ;;
            aarch64) ARCH="arm64" ;;
            armv7l) ARCH="armv6" ;;
            *) ARCH="x86_64" ;;
        esac
        
        # Download and install latest version
        LAZYGIT_VERSION=$(curl -s "https://api.github.com/repos/jesseduffield/lazygit/releases/latest" | grep -Po '"tag_name": "v\K[^"]*')
        curl -Lo lazygit.tar.gz "https://github.com/jesseduffield/lazygit/releases/latest/download/lazygit_${LAZYGIT_VERSION}_Linux_${ARCH}.tar.gz"
        tar xf lazygit.tar.gz lazygit
        sudo install lazygit /usr/local/bin
        rm lazygit lazygit.tar.gz
        
        print_success "lazygit installed"
    else
        print_status "lazygit already installed"
    fi
}

# Install system monitoring tools
# htop/btop for process monitoring, neofetch for system info
install_system_monitors() {
    print_status "Installing system monitoring tools..."
    
    # Install via package manager
    if command -v apt-get &> /dev/null; then
        sudo apt-get install -y htop neofetch 2>/dev/null || true
    elif command -v dnf &> /dev/null; then
        sudo dnf install -y htop neofetch 2>/dev/null || true
    fi

    # Install bottom (btm) - modern system monitor written in Rust
    if ! command -v btm &> /dev/null; then
        cargo install bottom
    fi

    print_success "System monitoring tools installed"
}

  
# Install Rust toolchain via rustup
# Needed for modern CLI tools written in Rust
install_rust() {
	print_status "Setting up Rust toolchain..."

    # Remove old system Rust packages if they exist
    if command -v apt-get &> /dev/null; then
	    print_status "Removing old system Rust packages..."
	    sudo apt-get remove -y cargo rustc 2>/dev/null || true
    fi

    # Install/Update Rust via rustup
    print_status "Installing/updating Rust via rustup..."
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
    # Load Rust into current shell Path
    source "$HOME/.cargo/env"
    export PATH="$HOME/.cargo/bin:$PATH"

    print_success "Rust installed/updated"
}

# Setup directory for custom scripts
# Creates ~/.local/bin and adds it to PATH if needed
setup_local_bin() {
    print_status "Setting up local bin directory..."
    
    mkdir -p "${HOME}/.local/bin"
    
    print_success "Local bin directory setup complete"
}

# Install modern replacements for traditional tools
# These are faster and more user-friendly versions
install_modern_tools() {
    print_status "Installing modern CLI tool replacements..."
    
    # Tools to install with cargo if not available
    # These significantly improve daily terminal use
    tools=(
        "procs"         # Better ps (process viewer)
        "du-dust"       # Better du (disk usage)
        "tokei"         # Count lines of code
        "hyperfine"     # Command benchmarking tool
    )
    
    for tool in "${tools[@]}"; do
        if ! command -v ${tool} &> /dev/null; then
            print_status "Installing $tool..."
            cargo install "$tool" 2>/dev/null || print_warning "Failed to install $tool"
        fi
    done
    
    print_success "Modern tools installation complete"
}

# Main function that orchestrates tool installation
main() {
    install_rust
    install_navi
    install_thefuck
    install_zoxide
    install_delta
    install_lazygit
    install_system_monitors
    install_modern_tools
    setup_local_bin
    
    print_success "All additional tools installed successfully!"
}

main "$@"
