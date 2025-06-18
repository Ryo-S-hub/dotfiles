# Zsh Configuration

This is a modular Zsh configuration designed for maintainability and performance.

## Structure

```
zsh/
├── .zshrc                    # Main configuration file (loads modules)
├── .zshrc.local             # Local overrides (optional, git-ignored)
├── modules/                 # Modular configuration files
│   ├── environment.zsh      # Environment variables and paths
│   ├── aliases.zsh         # All aliases organized by category
│   ├── functions.zsh       # Custom functions
│   ├── completions.zsh     # Completion system and external completions
│   ├── keybindings.zsh     # Key bindings and ZLE widgets
│   ├── external-tools.zsh  # External tool initialization
│   ├── fzf-git.zsh         # FZF-Git integration
│   └── fzf-functions.zsh   # Extended FZF functions
└── README.md               # This file
```

## Modules Overview

### 1. environment.zsh
- Environment detection (OS, terminal)
- PATH configuration with deduplication
- History configuration
- Development environment variables (Go, Deno, Python UV, etc.)
- FZF configuration and options

### 2. aliases.zsh
- Core aliases (editor shortcuts, navigation)
- Modern CLI tool aliases (eza, bat, rg, fd, etc.)
- Git aliases (including git-delta and tig)
- Development tool aliases (Docker, Node.js, Deno, Bun, Rust)
- System monitoring aliases
- Session management aliases

### 3. functions.zsh
- Core utility functions (yazi integration, chpwd)
- Git functions (GitHub CLI integration)
- Development functions (JSON viewer, script runners)
- System functions (watchman, benchmarking)
- Session management functions

### 4. completions.zsh
- Optimized completion system initialization
- Zoxide integration
- CDR (recent directories) configuration
- External tool completions (Google Cloud SDK, UV)
- Plugin management (zsh-autosuggestions)

### 5. keybindings.zsh
- Basic key bindings (Emacs-style)
- FZF key bindings and widgets
- Custom ZLE widgets for enhanced navigation

### 6. external-tools.zsh
- FZF initialization and loading of FZF modules
- Terminal-specific settings (Ghostty + Zellij)
- Prompt configuration (Starship support)

### 7. fzf-git.zsh
- FZF-Git integration script (from junegunn/fzf-git.sh)
- Git repository navigation with fuzzy search
- Interactive git operations (files, branches, tags, commits, etc.)

### 8. fzf-functions.zsh
- Extended FZF functions and utilities
- Process management, Docker operations
- Advanced file and directory navigation
- Interactive development workflows

## Key Features

### Performance Optimizations
- Zsh file compilation (`zcompile`)
- Optimized completion initialization with caching
- Unique path management with `typeset -U`

### Modern CLI Integration
- **eza**: Modern `ls` replacement with icons and git integration
- **bat**: Syntax-highlighted `cat` replacement
- **ripgrep**: Fast text search
- **fd**: Fast file finder
- **fzf**: Fuzzy finder with extensive integration
- **delta**: Enhanced git diff viewer
- **lazygit/lazydocker**: TUI for git and docker
- **zoxide**: Smart directory navigation
- **procs**: Modern process viewer

### Development Tools
- **Git**: Enhanced with delta, tig, and GitHub CLI
- **Docker**: Aliases and utilities
- **Node.js**: pnpm integration
- **Deno**: Task runner and aliases
- **Bun**: Modern JavaScript runtime
- **Rust**: Cargo shortcuts
- **Terraform**: Workspace management
- **Python**: UV package manager integration

### Interactive Features
- FZF integration for file search, git operations, and history
- GitHub CLI integration for PR and issue management
- Interactive JSON viewing with jnv
- Session management for tmux and zellij
- Smart directory navigation with zoxide

## Customization

### Local Configuration
Create `~/.config/zsh/.zshrc.local` for machine-specific configuration that won't be tracked by git.

### Module Customization
Each module can be customized independently:
- Disable modules by commenting them out in the main `.zshrc`
- Add custom modules by creating new `.zsh` files in the modules directory
- Override specific functions or aliases in `.zshrc.local`

### Environment Variables
Key environment variables for customization:
- `GHQ_ROOT`: Git repository root directory
- `GOPATH`: Go workspace
- `DENO_INSTALL`: Deno installation directory
- `FZF_DEFAULT_OPTS`: FZF appearance and behavior

## Installation

1. Clone or copy this configuration to `~/.config/zsh/`
2. Update your shell to source the new `.zshrc`:
   ```bash
   echo 'source ~/.config/zsh/.zshrc' >> ~/.zshrc
   ```
3. Restart your shell or run `source ~/.config/zsh/.zshrc`

## Dependencies

Install the following tools for full functionality:
```bash
brew install bat eza fd fzf ripgrep git-delta lazygit lazydocker \
  zoxide procs jnv gping oha watchman yazi zellij tmux tig gh \
  starship tre-command zsh-autosuggestions
```

## Troubleshooting

- Run `zsh -xvs` to debug startup issues
- Check module loading with verbose output
- Use `.zshrc.local` for temporary debugging
- Modules can be individually disabled for testing