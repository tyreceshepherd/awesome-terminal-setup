#!/bin/bash
# scripts/setup-zsh.sh - Setup ZSH with Oh-My-ZSH and plugins
# This script installs and configures ZSH as your default shell
# Includes: Oh-My-ZSH framework, auto-suggestions, syntax highlighting, themes

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
print_error() { echo -e "${RED}[ERROR]${NC} $1"; }

# Install Oh-My-ZSH framework which provides structure for themes and plugins
# This is the foundation that makes ZSH easy to customize
install_oh_my_zsh() {
    if [ ! -d "${HOME}/.oh-my-zsh" ]; then
        print_status "Installing Oh-My-ZSH..."
        sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
        print_success "Oh-My-ZSH installed"
    else
        print_status "Oh-My-ZSH already installed"
    fi
}

# Install ZSH plugins that enhance functionality
# These plugins make the shell smarter and more user-friendly
install_zsh_plugins() {
    local ZSH_CUSTOM="${ZSH_CUSTOM:-${HOME}/.oh-my-zsh/custom}"
    
    # Auto-suggestions: suggests commands as you type based on history
    # Press → (right arrow) to accept suggestions
    if [ ! -d "${ZSH_CUSTOM}/plugins/zsh-autosuggestions" ]; then
        print_status "Installing zsh-autosuggestions..."
        git clone https://github.com/zsh-users/zsh-autosuggestions \
            "${ZSH_CUSTOM}/plugins/zsh-autosuggestions"
        print_success "zsh-autosuggestions installed"
    fi
    
    # Syntax highlighting: colors commands green (valid) or red (invalid)
    # Helps catch typos before running commands
    if [ ! -d "${ZSH_CUSTOM}/plugins/zsh-syntax-highlighting" ]; then
        print_status "Installing zsh-syntax-highlighting..."
        git clone https://github.com/zsh-users/zsh-syntax-highlighting.git \
            "${ZSH_CUSTOM}/plugins/zsh-syntax-highlighting"
        print_success "zsh-syntax-highlighting installed"
    fi
    
    # Abbrev-alias: expands aliases so you see and learn the full commands
    # Helps prevent alias amnesia when you work on different systems
    if [ ! -d "${HOME}/.config/zsh-abbrev-alias" ]; then
        print_status "Installing zsh-abbrev-alias..."
        git clone https://github.com/momo-lab/zsh-abbrev-alias \
            "${HOME}/.config/zsh-abbrev-alias/"
        print_success "zsh-abbrev-alias installed"
    fi
    
    # Fast syntax highlighting: alternative/additional syntax highlighter
    # Faster than the standard one, can be used alongside it
    if [ ! -d "${ZSH_CUSTOM}/plugins/fast-syntax-highlighting" ]; then
        print_status "Installing fast-syntax-highlighting..."
        git clone https://github.com/zdharma-continuum/fast-syntax-highlighting.git \
            "${ZSH_CUSTOM}/plugins/fast-syntax-highlighting"
        print_success "fast-syntax-highlighting installed"
    fi
    
    # History substring search: use ↑/↓ to search history by what you've typed
    # Much better than repeatedly pressing up arrow
    if [ ! -d "${ZSH_CUSTOM}/plugins/zsh-history-substring-search" ]; then
        print_status "Installing zsh-history-substring-search..."
        git clone https://github.com/zsh-users/zsh-history-substring-search \
            "${ZSH_CUSTOM}/plugins/zsh-history-substring-search"
        print_success "zsh-history-substring-search installed"
    fi
}

# Install Powerlevel10k theme - makes your prompt beautiful and informative
# Shows git status, directory, execution time, exit codes, and more
install_powerlevel10k() {
    local ZSH_CUSTOM="${ZSH_CUSTOM:-${HOME}/.oh-my-zsh/custom}"
    
    if [ ! -d "${ZSH_CUSTOM}/themes/powerlevel10k" ]; then
        print_status "Installing Powerlevel10k theme..."
        git clone --depth=1 https://github.com/romkatv/powerlevel10k.git \
            "${ZSH_CUSTOM}/themes/powerlevel10k"
        print_success "Powerlevel10k installed"
    else
        print_status "Powerlevel10k already installed"
    fi
}

# Install Starship prompt - alternative to Powerlevel10k
# Fast, minimal, and works with any shell (not just ZSH)
install_starship() {
    if ! command -v starship &> /dev/null; then
        print_status "Installing Starship prompt..."
        curl -sS https://starship.rs/install.sh | sh -s -- -y
        print_success "Starship installed"
    else
        print_status "Starship already installed"
    fi
    
    # Create starship config directory
    mkdir -p "${HOME}/.config"
}

# Set ZSH as the default shell
# This makes ZSH load automatically when you open a terminal
set_default_shell() {
    local current_shell=$(echo $SHELL)
    local zsh_path=$(which zsh)
    
    if [ "$current_shell" != "$zsh_path" ]; then
        print_status "Setting ZSH as default shell..."
        
        # Add zsh to /etc/shells if not already there
        # This file lists all valid login shells
        if ! grep -q "$zsh_path" /etc/shells; then
            echo "$zsh_path" | sudo tee -a /etc/shells
        fi
        
        # Change default shell for current user
        sudo chsh -s "$zsh_path" "$USER"
        print_success "ZSH set as default shell"
        print_warning "You'll need to restart your terminal session for this to take effect"
    else
        print_status "ZSH is already the default shell"
    fi
}

# Setup FZF (fuzzy finder) key bindings for ZSH
# Enables Ctrl+R for history search, Ctrl+T for file search, etc.
setup_fzf() {
    if command -v fzf &> /dev/null; then
        print_status "Setting up FZF integration..."
        
        # Install fzf key bindings and fuzzy completion
        if [ ! -f "${HOME}/.fzf.zsh" ]; then
            if [ -f "/usr/share/fzf/shell/key-bindings.zsh" ]; then
                # Ubuntu/Debian path
                ln -sf /usr/share/fzf/shell/key-bindings.zsh "${HOME}/.fzf.zsh"
            elif [ -f "/usr/share/fzf/key-bindings.zsh" ]; then
                # Alternative path
                ln -sf /usr/share/fzf/key-bindings.zsh "${HOME}/.fzf.zsh"
            else
                # Install from git if package manager version doesn't have shell integration
                git clone --depth 1 https://github.com/junegunn/fzf.git "${HOME}/.fzf"
                "${HOME}/.fzf/install" --all
            fi
        fi
        
        print_success "FZF integration setup complete"
    fi
}

# Main function that orchestrates the ZSH setup
main() {
    install_oh_my_zsh
    install_zsh_plugins
    install_powerlevel10k
    install_starship
    setup_fzf
    set_default_shell
    
    print_success "ZSH setup completed!"
}

main "$@"
