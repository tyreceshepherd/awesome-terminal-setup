# Awesome Terminal Setup

A comprehensive, portable terminal setup that transforms your WSL/Linux terminal into a powerful, KodeKloud-like CLI experience with autocompletion, syntax highlighting, command suggestions, and modern tools.

## Features

### Beautiful Prompts
- **Starship** or **Powerlevel10k** themes with rich information display
- Git status, execution time, directory shortcuts
- Multi-line prompts with visual separators

### Enhanced Shell Experience
- **ZSH** with Oh-My-ZSH framework
- **Auto-suggestions** from command history
- **Syntax highlighting** for commands and paths
- **Command correction** with thefuck
- **Case-insensitive** path completion
- **Vi-mode** for Vim-like editing

### Smart Search & Navigation
- **FZF** for fuzzy finding files and history (Ctrl+R, Ctrl+T)
- **Zoxide** for smart directory jumping
- **Navi** for searchable command cheat sheets (Ctrl+N)
- Enhanced history with substring search

### Modern CLI Tools
- **bat** - Better cat with syntax highlighting
- **exa** - Better ls with colors and icons
- **ripgrep** - Faster grep replacement
- **fd** - Better find command
- **delta** - Better git diff viewer
- **lazygit** - Terminal Git UI

## ⚡ Quick Installation
```bash

# Clone the repository
git clone https://github.com/tyreceshepherd/awesome-terminal-setup.git

cd awesome-terminal-setup

# Run the installer
chmod +x install.sh
./install.sh

# Restart your terminal
exec zsh
```

## 🎯 Requirements 
- **OS**: WSL2, Ubuntu, Debian, or most Linux distributions
- **Terminal**: Windows Terminal, iTerm2, or any modern terminal emulator
- **Fonts**: Nerd Font compatible (FireCode Nerd Font recommended)
- **Permissions**: sudo access for package installation

## 📦 What Gets Installed

### Shell Configuration
```
~/.zshrc                    # Main ZSH configuration
~/.oh-my-zsh/               # Oh-My-ZSH framework
~/.config/starship.toml     # Starship prompt settings
~/.p10k.zsh                 # Powerlevel10k settings (optional)
```

### Tools & Utilities
- Package manager tools (apt/dnf/brew)
- ZSH plugins and extensions
- Modern CLI replacements
- Git enhancements

**Automatic Backups**: Your existing configurations are backed up to `~/.config-backup-{timestamp}/`

## 🔧 Customization

### Switch Between Prompt Themes

**Starship** (default - fast and minimal):
```bash
# Already active, no changes needed

**Powerlevel10k** (feature-rich with extensive customization):
```bash
# Edit ~/.zshrc
vim ~/.zshrc

# Find and comment out Starship:
# eval "$(starship init zsh)"

# Find and uncomment Powerlevel10k:
ZSH_THEME="powerlevel10k/powerlevel10k"

# Save and reload
source ~/.zshrc

# Run the configuration wizard
p10k configure
```

### Customize Starship Prompt 

Edit the Starship configuration:
```bash
vim ~/.config/starship.toml
```
See [Starship documentation](https://starship.rs/config/) for available options.

### Add Your Own Aliases

Add custom aliases to your `.zshrc`:
```bash
# Open your config
vim ~/.zshrc

# Add your aliases at the bottom
alias myproject="cd ~/projects/my-project"
alias gp="git push"
alias gs="git status"

# Save and reload
source ~/.zshrc
```

### Modify ZSH Plugins 

Edit the plugins array in `~/.zshrc`:
```bash
plugins=(
    git
    zsh-autosuggestions
    zsh-syntax-highlighting
    sudo
    vi-mode
    # Add your own plugins here
)
```

## 🔄 Updating

Keep your terminal setup up to date:
```bash
cd ~/awesome-terminal-setup
git pull origin main
./update.sh
```
This will:
- Pull the latest changes from GitHub
- Update Oh-My-ZSH and plugins
- Update CLI tools (if applicable)
- Preserve your custom configurations

## 🗑️ Uninstallation

To completely remove the setup and restore backups:
```bash
cd ~/awesome-terminal-setup
./uninstall.sh
```
This will:
- Remove all installed configurations
- Restore your original backups
- Optionally remove installed packages
- Switch back to your previous shell

## 🆘 Troubleshooting

### Fonts Display Incorrectly (�� or boxes)

**Solution**: Install a Nerd Font in your terminal emulator.

**Windows Terminal**:
1. Download [FiraCode Nerd Font](https://www.nerdfonts.com/font-downloads)
2. Install the font in Windows
3. Open Windows Terminal Settings
4. Go to: Profiles → Defaults → Appearance
5. Set Font Face to "FiraCode Nerd Font"

**Other terminals**: Check your terminal's font settings and select a Nerd Font.

### ZSH Not Set as Default Shell
```bash
# Set ZSH as default
chsh -s $(which zsh)

# Restart your terminal or logout/login
```

### Commands Not Found After Installation
```bash
# Reload your configuration
source ~/.zshrc

# If that doesn't work, restart your terminal
exec zsh
```

### Slow Terminal Startup
```bash
# Open your config
vim ~/.zshrc

# Disable unused plugins in the plugins=() array
# Comment out plugins you don't use with #

# Save and test
source ~/.zshrc
```

### Auto-suggestions Not Working
```bash
# Ensure the plugin is installed
cd ~/.oh-my-zsh/custom/plugins/zsh-autosuggestions
git pull

# Reload configuration
source ~/.zshrc
```

## 📂 Repository Structure
```
awesome-terminal-setup/
├── install.sh                      # Main installation script
├── update.sh                       # Update script
├── uninstall.sh                    # Uninstallation script
├── README.md                       # This file
│
├── config/                         # Configuration files
│   ├── .zshrc                      # ZSH configuration
│   ├── .p10k.zsh                   # Powerlevel10k theme
│   ├── starship.toml               # Starship prompt config
│   ├── .vimrc                      # Vim configuration
│   └── .tmux.conf                  # Tmux configuration
│
├── scripts/                        # Installation modules
│   ├── install-dependencies.sh     # System packages
│   ├── setup-zsh.sh                # ZSH setup
│   ├── setup-tools.sh              # CLI tools
│   └── backup-existing.sh          # Backup utility
│
└── docs/                           # Documentation
    ├── FEATURES.md                 # Detailed features
    ├── CUSTOMIZATION.md            # Customization guide
    └── TROUBLESHOOTING.md          # Extended troubleshooting
```

## 🤝 Contributing


Contributions are welcome! Here's how you can help:

1. **Fork** the repository
2. **Create** a feature branch: `git checkout -b feature/amazing-feature`
3. **Make** your changes
4. **Test** thoroughly on a clean system
5. **Commit** with clear messages: `git commit -m 'Add amazing feature'`
6. **Push** to your branch: `git push origin feature/amazing-feature`
7. **Open** a Pull Request


### Guidelines


- Test on multiple Linux distributions if possible
- Update documentation for new features
- Follow existing code style and conventions
- Add comments to explain complex logic


## 📝 License

MIT License

Copyright (c) 2025 Tyrece Shepherd

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.


## 🙏 Acknowledgments

This project is built on the shoulders of amazing open-source tools and their maintainers:

- [Oh-My-ZSH](https://ohmyz.sh/) - Delightful ZSH framework
- [Starship](https://starship.rs/) - Minimal, blazing-fast prompt
- [Powerlevel10k](https://github.com/romkatv/powerlevel10k) - Flexible ZSH theme
- [FZF](https://github.com/junegunn/fzf) - Command-line fuzzy finder
- [zsh-autosuggestions](https://github.com/zsh-users/zsh-autosuggestions) - Fish-like suggestions
- [zsh-syntax-highlighting](https://github.com/zsh-users/zsh-syntax-highlighting) - Syntax highlighting
- Modern Rust CLI tools: bat, exa, ripgrep, fd, delta, and more

Special thanks to [Kevin Knapp's shell setup guide](https://kbknapp.dev/shell-setup/) for inspiration.


## 🔗 Resources

- **Documentation**: [docs/](docs/)
- **Issues**: [GitHub Issues](https://github.com/tyreceshepherd/awesome-terminal-setup/issues)
- **Discussions**: [GitHub Discussions](https://github.com/tyreceshepherd/awesome-terminal-setup/discussions)

---

**⭐ If this setup makes your terminal awesome, give it a star!**

**💡 Questions or suggestions? Open an issue or discussion!**









