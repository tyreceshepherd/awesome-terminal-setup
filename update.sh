#!/bin/bash
# update.sh - Update the awesome terminal setup
# This script pulls the latest changes from GitHub and updates all components
# Runs safely by backing up before making changes

set -euo pipefail  # Exit on error, undefined variables, and pipe failures

# Color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
NC='\033[0m'

print_status() { echo -e "${BLUE}[INFO]${NC} $1"; }
print_success() { echo -e "${GREEN}[SUCCESS]${NC} $1"; }
print_warning() { echo -e "${YELLOW}[WARNING]${NC} $1"; }
print_error() { echo -e "${RED}[ERROR]${NC} $1"; }

print_header() {
    echo -e "${PURPLE}================================${NC}"
    echo -e "${PURPLE}  🔄 Terminal Setup Update 🔄${NC}"
    echo -e "${PURPLE}================================${NC}"
}

# Script directory - where this update script lives
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_DIR="$SCRIPT_DIR/config"

# Update the repository from GitHub
# Pulls the latest changes so you have the newest features and fixes
update_repo() {
    print_status "Updating repository..."
    
    if [ -d "$SCRIPT_DIR/.git" ]; then
        cd "$SCRIPT_DIR"
        git pull origin main || git pull origin master
        print_success "Repository updated"
    else
        print_warning "Not a git repository, skipping git pull"
    fi
}

# Update Oh-My-ZSH framework
update_oh_my_zsh() {
    if [ -d "${HOME}/.oh-my-zsh" ]; then
        print_status "Updating Oh-My-ZSH..."
        cd "${HOME}/.oh-my-zsh"
        git pull
        print_success "Oh-My-ZSH updated"
    fi
}

# Update all ZSH plugins to their latest versions
update_zsh_plugins() {
    print_status "Updating ZSH plugins..."
    local ZSH_CUSTOM="${ZSH_CUSTOM:-${HOME}/.oh-my-zsh/custom}"
    
    # Update auto-suggestions plugin
    if [ -d "${ZSH_CUSTOM}/plugins/zsh-autosuggestions" ]; then
        cd "${ZSH_CUSTOM}/plugins/zsh-autosuggestions"
        git pull
    fi
    
    # Update syntax highlighting plugin
    if [ -d "${ZSH_CUSTOM}/plugins/zsh-syntax-highlighting" ]; then
        cd "${ZSH_CUSTOM}/plugins/zsh-syntax-highlighting"
        git pull
    fi
    
    # Update fast syntax highlighting
    if [ -d "${ZSH_CUSTOM}/plugins/fast-syntax-highlighting" ]; then
        cd "${ZSH_CUSTOM}/plugins/fast-syntax-highlighting"
        git pull
    fi
    
    # Update history substring search
    if [ -d "${ZSH_CUSTOM}/plugins/zsh-history-substring-search" ]; then
        cd "${ZSH_CUSTOM}/plugins/zsh-history-substring-search"
        git pull
    fi
    
    # Update abbrev-alias
    if [ -d "${HOME}/.config/zsh-abbrev-alias" ]; then
        cd "${HOME}/.config/zsh-abbrev-alias"
        git pull
    fi
    
    print_success "ZSH plugins updated"
}

# Update Powerlevel10k theme
update_powerlevel10k() {
    local ZSH_CUSTOM="${ZSH_CUSTOM:-${HOME}/.oh-my-zsh/custom}"
    
    if [ -d "${ZSH_CUSTOM}/themes/powerlevel10k" ]; then
        print_status "Updating Powerlevel10k..."
        cd "${ZSH_CUSTOM}/themes/powerlevel10k"
        git pull
        print_success "Powerlevel10k updated"
    fi
}

# Update Starship prompt to latest version
update_starship() {
    if command -v starship &> /dev/null; then
        print_status "Updating Starship..."
        curl -sS https://starship.rs/install.sh | sh -s -- -y
        print_success "Starship updated"
    fi
}

# Update Rust-based CLI tools via cargo
update_rust_tools() {
    if command -v cargo &> /dev/null; then
        print_status "Updating Rust-based tools..."
        
        # List of tools to update
        tools=("bat" "exa" "ripgrep" "fd-find" "zoxide" "delta" "procs" "dust" "tokei")
        
        for tool in "${tools[@]}"; do
            # Check if tool is installed via cargo
            if command -v ${tool} &> /dev/null || command -v ${tool//-*/} &> /dev/null; then
                print_status "Updating $tool..."
                cargo install "$tool" --force || print_warning "Failed to update $tool"
            fi
        done
        
        print_success "Rust tools updated"
    fi
}

# Update navi cheat sheets to get latest command examples
update_navi_cheats() {
    if command -v navi &> /dev/null; then
        print_status "Updating navi cheat sheets..."
        
        local cheats_dir="${HOME}/.local/share/navi/cheats"
        
        # Update official cheat sheets
        if [ -d "${cheats_dir}/denisidoro__cheats" ]; then
            cd "${cheats_dir}/denisidoro__cheats"
            git pull
        fi
        
        print_success "Navi cheat sheets updated"
    fi
}

# Update configuration files from repository
# Only updates if the repo version is newer than your current version
update_configs() {
    print_status "Checking for configuration updates..."
    
    # Backup current configs before updating
    backup_dir="${HOME}/.config/terminal-update-backup-$(date +%Y%m%d_%H%M%S)"
    mkdir -p "$backup_dir"
    
    # Backup existing config files
    configs=(.zshrc .p10k.zsh .vimrc .tmux.conf)
    for config in "${configs[@]}"; do
        if [ -f "${HOME}/$config" ]; then
            cp "${HOME}/$config" "$backup_dir/"
        fi
    done
    
    if [ -f "${HOME}/.config/starship.toml" ]; then
        cp "${HOME}/.config/starship.toml" "$backup_dir/"
    fi
    
    # Update configurations by relinking to repository versions
    ln -sf "${CONFIG_DIR}/.zshrc" "${HOME}/.zshrc"
    ln -sf "${CONFIG_DIR}/.p10k.zsh" "${HOME}/.p10k.zsh"
    mkdir -p "${HOME}/.config"
    ln -sf "${CONFIG_DIR}/starship.toml" "${HOME}/.config/starship.toml"
    ln -sf "${CONFIG_DIR}/.vimrc" "${HOME}/.vimrc"
    ln -sf "${CONFIG_DIR}/.tmux.conf" "${HOME}/.tmux.conf"
    
    print_success "Configuration files updated"
    print_status "Backup created at: $backup_dir"
}

# Update system packages via package manager
update_system_packages() {
    print_status "Updating system packages..."
    
    if command -v apt-get &> /dev/null; then
        sudo apt-get update
        sudo apt-get upgrade -y fzf ripgrep fd-find bat exa tmux vim 2>/dev/null || true
    elif command -v dnf &> /dev/null; then
        sudo dnf update -y fzf ripgrep fd-find bat exa tmux vim 2>/dev/null || true
    elif command -v pacman &> /dev/null; then
        sudo pacman -Syu --noconfirm fzf ripgrep fd bat exa tmux vim 2>/dev/null || true
    fi
    
    print_success "System packages updated"
}

# Clean up old backup directories (keep only last 5)
cleanup() {
    print_status "Cleaning up old backups..."
    
    # Find and remove old backup directories, keeping the 5 most recent
    local backup_dirs=($(ls -dt ~/.config/terminal-*-backup-* 2>/dev/null | tail -n +6))
    if [ ${#backup_dirs[@]} -gt 0 ]; then
        for dir in "${backup_dirs[@]}"; do
            print_status "Removing old backup: $dir"
            rm -rf "$dir"
        done
    fi
    
    print_success "Cleanup completed"
}

# Main update function that runs everything in order
main() {
    print_header
    
    # Check if we're in the repository directory
    if [ ! -f "$SCRIPT_DIR/install.sh" ]; then
        print_error "Please run this script from the awesome-terminal-setup directory"
        exit 1
    fi
    
    update_repo
    update_oh_my_zsh
    update_zsh_plugins
    update_powerlevel10k
    update_starship
    update_rust_tools
    update_navi_cheats
    update_configs
    update_system_packages
    cleanup
    
    print_success "Update completed successfully!"
    print_warning "Please restart your terminal or run 'source ~/.zshrc' to apply changes"
}

main "$@"
