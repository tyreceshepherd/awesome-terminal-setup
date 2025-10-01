#!/bin/bash
#
#
# scripts/backup-existing.sh - Backup existing terminal configurations before we change anything
# This script creates a timestamped backup of all your current terminal config files
# If something goes wrong, you can restore everything using the restore.sh script it creates
#
set -euo pipefail # Exit immediately if any command fails
			# -e = engine stops immediately if any fault occurs.
			# -u = refuses to run if a sensor is unplugged.
			# -o pipefail = flags an issue if it's hidden mid-pipeline (like a fuel pump in a chain of systems).

# Color codes for pretty terminal output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' 		# No Color - resets to normal

# Helper functions for colored output
print_status() { echo -e "${BLUE}[INFO]${NC} $1"; }
print_success() { echo -e "${GREEN}[SUCCESS]${NC} $1"; }
print_warning() { echo -e "${YELLOW}[WARNING]${NC} $1"; }

# Create a backup directory with current timestamp so we can have multiple backups
# Format: terminal-setup-backup-YYYYMMDD_HHMMSS (example: terminal-setup-backup-20240927_143022)
BACKUP_DIR="$HOME/.config/terminal-setup-backup-$(date +%Y%m%d_%H%M%S)"
mkdir -p "$BACKUP_DIR"

print_status "Creating backup directory: $BACKUP_DIR"

# List of individual config files we want to backup
# These are the main configuration files that our setup will modify
files_to_backup=(
	"$HOME/.zshrc"		# ZSH shell configuration
	"$HOME/.bashrc"		# Bash shell configuration (in case you switch back)
	"$HOME/.bash_profile"	# Bash profile settings
	"$HOME/.profile"	# Generic shell profile
	"$HOME/.vimrc"		# Vim editor configuration
	"$HOME/.tmux.conf"	# Tmux multiplexer configuration
	"$HOME/.gitconfig"	# Git configuration
	"$HOME/.p10k.zsh"	# Powerlevel10k theme config
	"$HOME/.config/starship.toml"	# Starship prompt config
	"$HOME/.fzf.zsh"	# FZF fuzzy finder config
)

# List of directories we want to backup
# These contain plugins, themes, and other important configurations
dirs_to_backup=(
	"$HOME/.oh-my-zsh"			# Oh-My-ZSH framework and plugins
	"$HOME/.config/zsh-abbrev-alias"	# Alias expansion plugin	
	"$HOME/.vim"				# Vim plugins and settings
	"$HOME/.tmux"				# Tmux plugins
)

# Function to backup individual files
backup_files() {
	print_status "Backing up configuration files..."

	# Loop through each file in our backup list
	for file in "${files_to_backup[@]}"; do
		# Check if the file actually exists before trying to back it up
		if [ -f "$file" ]; then
			# Copy the file to backup directory
			cp "$file" "$BACKUP_DIR/"
			print_status "Backed up: $(basename "$file")"
		fi
	done
}

# Function to backup directories
backup_directories() {
	print_status "Backing up configuration directories..."

	# Loop through each directory in our backup list
	for dir in "${dirs_to_backup[@]}"; do
		# Check if the directory exits before backing it up
		if [ -d "$dir" ]; then
			# Recursively copy the entire directory to backup location
			cp -r "$dir" "$BACKUP_DIR/"
			print_status "Backed up: $(basename "$dir")"
		fi
	done
}

# Create a restore script that can undo our changes and restore the backup
# This is your safety net if anything goes wrong
create_restore_script() {
	cat > "$BACKUP_DIR/restore.sh" << 'EOF'

#!/bin/bash
# Restore script - Run this to restore your previous terminal configuration
# This will undo all changes made by awesome-terminal-setup

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "Restoring configurations from backup..."

# Remove current symlinks created by our setup
# This prevents conflicts when we restore the old files
rm -f ~/.zshrc ~/.bashrc ~/.bash_profile ~/.profile ~/.vimrc ~/.tmux.conf
rm -f ~/.gitconfig ~/.p10k.zsh ~/.config/starship.toml ~/.fzf.zsh

# Restore all backed up files to their original locations
for file in "$SCRIPT_DIR"/*; do
	filename=$(basename "$file")
	# Skip the restore script itself and any directiories
	if [ "$filename" != "restore.sh" ] && [ -f "$file" ]; then
		cp "$file" "$HOME/.$filename"
		echo "Restored: $filename"
	fi
done

# Restore backed up directories to their original locations
for dir in "$SCRIPT_DIR"/*; do
	dirname=$(basename "$dir")
	if [ -d "$dir" ] && [ "$dirname" != "." ] && [ "$dirname" != ".." ]; then
		# Map directory names back to their original locations
		if [ "$dirname" = "oh-my-zsh" ]; then
			rm -rf "$HOME/.oh-my-zsh"
			cp -r "$dir" "$HOME/.oh-my-zsh"
		elif [ "$dirname" = "vim" ]; then
			rm -rf "$HOME/.vim"
			cp -r "$dir" "$HOME/.vim"
		elif [ "$dirname" = "tmux" ]; then
			rm -rf "$HOME/.tmux"
			cp -r "$dir" "$HOME/.tmux"
		elif [ "$dirname" = "zsh-abbrev-alias" ]; then
			rm -rf "$HOME/.config/zsh-abbrev-alias"
			cp -r "$dir" "$HOME/.config/zsh-abbrev-alias"
		fi
		echo "Restored directory: $dirname"
	fi
done

echo "Restoration complete!"
echo "Please restart your terminal or run 'source ~/.zshrc' or 'source ~/.bashrc'"
EOF

	# Make the restore script executable so it can be run
	chmod +x "$BACKUP_DIR/restore.sh"
	print_success "Created restore script at: $BACKUP_DIR/restore.sh"
}

# Save information about your current shell environment
# This helps with troubleshooting if something does wrong
save_shell_info() {
	cat > "$BACKUP_DIR/shell_info.txt" << EOF
Current shell: $SHELL
Available shells:
$(cat /etc/shells)

Current PATH:
$PATH

Current environment variables (selected):
TERM: $TERM
EDITOR: ${EDITOR:-not set}
PAGER: ${PAGER:-not set}
EOF
}

# Main function that runs all backup operations in order
main() {
	print_status "Starting backup process..."

	backup_files		# Backup individual config files
	backup_directories	# Backup config directories
	create_restore_script	# Create the restore script
	save_shell_info		# Save current environment info

	print_success "Backup completed successfully!"
	print_success "Backup location: $BACKUP_DIR"
	print_warning "To restore your previous configuration, run $BACKUP_DIR/restore.sh"

	# Save the backup location to a file for easy reference
	echo "$BACKUP_DIR" > "$HOME/.last_terminal_backup"
}

# Run the main backup function
main "$@"


