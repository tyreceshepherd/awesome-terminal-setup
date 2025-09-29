
#!/bin/bash
# 
# install.sh - One-command setup for awesome terminal
# This is the main installation script that orchestrates the entire setup process
# It calls other scripts in a specific order to build your awesome terminal environment 
#

set -e # Exit immediately if any command fails - this prevents partial installations

# Color codes for making terminal output pretty and easy to read
# These ANSI color codes will makes our messages stand out
RED='\033[0;31m'	# For error messages
GREEN='\033[0;32m'	# For success mssages
YELLOW='\033[1;33m'	# For warning messages
BLUE='\033[0;34m'	# For informational messages
PURPLE='\033[0;35m'	# For headers and titles
CYAN='\033[0;36m'	# For special highlights
NC='\033[0m'		# No Color - resets color back to normal

# Get the absolute path of where this script is located
# This ensures we can find our config and script files regardless of where we run this from
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_DIR="$SCRIPT_DIR/config"		# Where our .zshrc, .vimrc, etc. files live
SCRIPTS_DIR="$SCRIPT_DIR/scripts"	# Where our installation sub-scripts live

# Helper functions to print colored messages - makes output easier to read and understand
print_status() {
	echo -e "${BLUE}[INFO]${NC} $1"		# Blue text for general information
}

print_success() {
	echo -e "${GREEN}[SUCCESS]${NC} $1"	# Green text for successful operations
}

print_warning() {
	echo -e "${YELLOW}[WARNING]${NC} $1"	# Yellow text for warnings
}

print_error() {
	echo -e "${RED}[ERROR]${NC} $1"		# Red text for errors
}

print_header() {
	# Pretty purple header to make it clear what's happening
	echo -e "${PURPLE}================================${NC}"
	echo -e "${PURPLE}=======AWESOME TERMINAL SETUP===${NC}"
	echo -e "${PURPLE}================================${NC}"
}

# Detect if we're running in Windows Subsystem for Linux (WSL)
# This affects some configurations like clipboard integration
check_wsl() {
	if grep -q Microsoft /proc/version; then
		print_status "Detected WSL environment - will configure for Windows integration"
		export IS_WSL=true
	else
		print_status "Detected Linux environment - will use standard Linux configurations"
		export IS_WSL=false
	fi
}

# The main installation orchestrator - this runs everything in the right order
main() {
	print_header

	# First, figure out what environment we're in
	check_wsl

	# Make sure all our helper scripts can be executed
	chmod +x "$SCRIPTS_DIR"/*.sh

	print_status "Starting installation process..."

	# Step 1: Safety first - backup any existing terminal configurations
	# This way you can always go back if something goes wrong
	print_status "Step 1: Backing up existing configurations..."
	"$SCRIPTS_DIR/backup-existing.sh"

	# Step 2: Install all the required packages and dependencies
	# This includes ZSH, Git, modern CLI tools, fonts, etc.
	print_status "Step 2: Installing dependencies..."
	"$SCRIPTS_DIR/install-dependencies.sh"

	# Step 3: Set up ZSH shell with Oh-My-ZSH framework and all the plugins
	# This gives us auto-suggestions, syntax highlighting, themes, etc.
	print_status "Step 3: Setting up ZSH..."
	"$SCRIPTS_DIR/setup-zsh.sh"

	# Step 4: Install modern CLI tools that make terminal work faster and prettier
	# Things like exa (better ls), bat (better cat), ripgrep (better grep), etc.
	print_status "Step 4: Installing additional tools..."
	"$SCRIPTS_DIR/setup-tools.sh"
	
	# Step 5: Link our custom configuration files to their proper locations
	# This activates all our custom settings, aliases, prompt themes, etc
	print_status "Step 5: Applying configurations..."
	apply_configs

	print_success "Installation completed successfully!"
	print_warning "Please restart your terminal or run 'source ~/.zshrc' to apply changes"
	print_status "Run 'p10k configure' to customize your prompt theme"
}

# Create symbolic links from our config files to where the system expects them
# Symlinks are better than copying because updates to our repo automatically apply
apply_configs() {
	# Link ZSH configuration (main shell config with aliases, functions, etc.)
	ln -sf "$CONFIG_DIR/.zshrc" "$HOME/.zshrc"

	# Link Powerlevel10k theme configuration (makes prompt beautiful and informative)
	ln -sf "$CONFIG_DIR/.p10k.zsh" "$HOME/.p10k.zsh"

	# Link Starship prompt configuration (alternative to Powerlevel10k)
	mkdir -p "$HOME/.config" # Make sure .config directory exists
	ln -sf "$CONFIG_DIR/starship.toml" "$HOME/.config/starship.toml"

	#Link Vim configuration (makes vim editor more powerful and user-friendly)
	ln -sf "$CONFIG_DIR/.vimrc" "$HOME/.vimrc"

	# Link Tmux configuration (terminal multiplexer for managing multiple sessions)
	ln -sf "$CONFIG_DIR/.tmux.conf" "$HOME/.tmux.conf"

	print_success "Configuration files linked - your custom settings are now active"
}

# Actually run the main installation function with any arguments passed to this script
main "$@"
