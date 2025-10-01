# Path to your oh-my-zsh installation
export ZSH="$HOME/.oh-my-zsh"

# Set theme to empty (we'll use Starship instead)
ZSH_THEME=""

# Plugins
plugins=(
    git
    zsh-autosuggestions
    zsh-syntax-highlighting
    sudo
    vi-mode
    fzf
    thefuck
    zoxide
)

source $ZSH/oh-my-zsh.sh

# Initialize Starship prompt
eval "$(starship init zsh)"

# Initialize zoxide (smarter cd) - only if installed
if command -v zoxide &> /dev/null; then
	eval "$(zoxide init zsh)"
fi

# Initialize thefuck - only if installed
if command -v thefuck &> /dev/null; then
	eval $(thefuck --alias)
fi

# Add cargo bin to PATH
export PATH="$HOME/.cargo/bin:$PATH"

# Add local bin to PATH
export PATH="$HOME/.local/bin:$PATH"

# Modern CLI tool aliases
alias cat='bat'
alias ls='exa --icons'
alias ll='exa -l --icons'
alias la='exa -la --icons'
alias tree='exa --tree --icons'
