#!/bin/bash
# uninstall.sh - Uninstall the awesome terminal setup
# This script removes all installed components and optionally restores your previous configuration
# WARNING: This will remove ZSH configurations - make sure you want to do this

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
    echo -e "${PURPLE}  🗑️  Terminal Setup Removal 🗑️${NC}"
    echo -e "${PURPLE}================================${NC}"
}

# Confirm the user really wants to uninstall
# This prevents accidental removal
confirm_uninstall() {
    print_warning "This will remove the awesome terminal setup and restore your previous configuration."
    print_warning "The following will be removed:"
    echo "  - ZSH configurations (.zshrc, .p10k.zsh)"
    echo "  - Oh-My-ZSH and plugins"
    echo "  - Starship configuration"
    echo "  - Custom aliases and functions"
    echo "  - Installed CLI tools (optional)"
    echo ""
    
    read -p "Are you sure you want to continue? (y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        print_status "Uninstall cancelled."
        exit 0
    fi
    
    read -p "Do you want to remove installed CLI tools as well? (y/N): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        export REMOVE_TOOLS=true
    else
        export REMOVE_TOOLS=false
    fi
}

# Try to restore from the most recent backup
restore_backup() {
    print_status "Looking for backups to restore..."
    
    # Find the most recent backup directory
    local backup_dir=$(ls -dt ~/.config/terminal-setup-backup-* 2>/dev/null | head -1)
    
    if [ -n "$backup_dir" ] && [ -d "$backup_dir" ]; then
        print_status "Found backup: $backup_dir"
        read -p "Restore from this backup? (Y/n): " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Nn]$ ]]; then
            print_status "Restoring from backup..."
            "$backup_dir/restore.sh"
            print_success "Backup restored"
            return 0
        fi
    fi
    
    print_warning "No backup found or restore declined"
    return 1
}

# Reset the default shell back to bash
reset_shell() {
    local current_shell=$(echo $SHELL)
    local bash_path=$(which bash)
    
    if [ "$current_shell" != "$bash_path" ]; then
        print_status "Resetting default shell to bash..."
        sudo chsh -s "$bash_path" "$USER"
        print_success "Default shell reset to bash"
        print_warning "You'll need to restart your terminal session for this to take effect"
    fi
}

# Remove ZSH configuration files
remove_zsh_configs() {
    print_status "Removing ZSH configurations..."
    
    # List of config files to remove
    files_to_remove=(
        "${HOME}/.zshrc"
        "${HOME}/.p10k.zsh"
        "${HOME}/.zshrc.local"
        "${HOME}/.zshrc.work"
        "${HOME}/.fzf.zsh"
        "${HOME}/z.sh"
    )
    
    for file in "${files_to_remove[@]}"; do
        if [ -f "$file" ]; then
            rm -f "$file"
            print_status "Removed: $(basename "$file")"
        fi
    done
    
    print_success "ZSH configurations removed"
}

# Remove Oh-My-ZSH framework and all plugins
remove_oh_my_zsh() {
    if [ -d "${HOME}/.oh-my-zsh" ]; then
        print_status "Removing Oh-My-ZSH..."
        rm -rf "${HOME}/.oh-my-zsh"
        print_success "Oh-My-ZSH removed"
    fi
    
    # Remove additional plugin directories
    if [ -d "${HOME}/.config/zsh-abbrev-alias" ]; then
        print_status "Removing zsh-abbrev-alias..."
        rm -rf "${HOME}/.config/zsh-abbrev-alias"
    fi
}

# Remove Starship prompt configuration
remove_starship() {
    if [ -f "${HOME}/.config/starship.toml" ]; then
        print_status "Removing Starship configuration..."
        rm -f "${HOME}/.config/starship.toml"
        print_success "Starship configuration removed"
    fi
}

# Remove navi and its cheat sheets
remove_navi() {
    if [ -d "${HOME}/.local/share/navi" ]; then
        print_status "Removing navi cheat sheets..."
        rm -rf "${HOME}/.local/share/navi"
    fi
    
    if [ -f "${HOME}/.config/navi/config.yaml" ]; then
        rm -f "${HOME}/.config/navi/config.yaml"
        rmdir "${HOME}/.config/navi" 2>/dev/null || true
    fi
}

# Remove installed CLI tools (optional - only if user confirmed)
remove_tools() {
    if [ "$REMOVE_TOOLS" != "true" ]; then
        print_status "Skipping removal of CLI tools"
        return
    fi
    
    print_status "Removing installed CLI tools..."
    
    # Remove Rust tools via cargo uninstall
    if command -v cargo &> /dev/null; then
        local rust_tools=("bat" "exa" "ripgrep" "fd-find" "zoxide" "delta" "procs" "dust" "tokei" "hyperfine")
        for tool in "${rust_tools[@]}"; do
            if command -v ${tool} &> /dev/null || command -v ${tool//-*/} &> /dev/null; then
                print_status "Removing $tool..."
                cargo uninstall "$tool" 2>/dev/null || true
            fi
        done
    fi
    
    # Remove Starship binary
    if command -v starship &> /dev/null; then
        print_status "Removing Starship..."
        sudo rm -f "$(which starship)"
    fi
    
    # Remove navi binary
    if command -v navi &> /dev/null; then
        print_status "Removing navi..."
        sudo rm -f "$(which navi)"
    fi
    
    # Remove lazygit binary
    if command -v lazygit &> /dev/null; then
        print_status "Removing lazygit..."
        sudo rm -f "$(which lazygit)"
    fi
    
    # Remove thefuck
    if command -v thefuck &> /dev/null; then
        print_status "Removing thefuck..."
        pip3 uninstall -y thefuck 2>/dev/null || true
    fi
    
    # Remove zoxide binary
    if command -v zoxide &> /dev/null; then
        print_status "Removing zoxide..."
        sudo rm -f "$(which zoxide)"
    fi
    
    print_success "CLI tools removed"
}

# Clean up cache and temporary directories
cleanup_directories() {
    print_status "Cleaning up directories..."
    
    # Remove cache directories related to our tools
    dirs_to_clean=(
        "${HOME}/.cache/starship"
        "${HOME}/.cache/navi"
        "${HOME}/.cache/exa"
        "${HOME}/.cache/bat"
    )
    
    for dir in "${dirs_to_clean[@]}"; do
        if [ -d "$dir" ]; then
            rm -rf "$dir"
        fi
    done
    
    print_success "Directories cleaned"
}

# Remove Nerd Fonts (optional)
remove_fonts() {
    read -p "Remove installed Nerd Fonts? (y/N): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        print_status "Removing Nerd Fonts..."
        rm -f "${HOME}/.local/share/fonts/FiraCode"*
        fc-cache -fv
        print_success "Nerd Fonts removed"
    fi
}

# Create a log file documenting what was uninstalled
create_uninstall_log() {
    local log_file="${HOME}/.config/terminal-setup-uninstall-$(date +%Y%m%d_%H%M%S).log"
    mkdir -p "$(dirname "$log_file")"
    
    cat > "$log_file" << EOF
Awesome Terminal Setup - Uninstall Log
Date: $(date)
User: $USER
Hostname: $(hostname)

Files removed:
- ~/.zshrc
- ~/.p10k.zsh
- ~/.config/starship.toml
- ~/.oh-my-zsh/ (directory)
- ~/.config/zsh-abbrev-alias/ (directory)
- ~/.local/share/navi/ (directory)

Tools removed: $REMOVE_TOOLS

Shell reset to: $(which bash)

To reinstall, run:
git clone https://github.com/tyreceshepherd/awesome-terminal-setup.git
cd awesome-terminal-setup
./install.sh
EOF
    
    print_status "Uninstall log created: $log_file"
}

# Main uninstall function
main() {
    print_header
    
    confirm_uninstall
    
    # Try to restore from backup first
    if ! restore_backup; then
        print_status "Proceeding with manual cleanup..."
        
        remove_zsh_configs
        remove_oh_my_zsh
        remove_starship
        remove_navi
        remove_tools
        cleanup_directories
        remove_fonts
        reset_shell
    fi
    
    create_uninstall_log
    
    print_success "Uninstall completed!"
    print_warning "Please restart your terminal to complete the process"
    print_status "Your terminal has been restored to its previous state"
}

main "$@"
