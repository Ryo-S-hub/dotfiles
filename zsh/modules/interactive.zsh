#!/usr/bin/env zsh
# ~/.config/zsh/modules/interactive.zsh - Interactive shell features

# ============================================================================
# SSH Agent
# ============================================================================
# Start SSH agent if not already running (interactive shells only)
if [[ -o interactive ]]; then
    # Check if ssh-agent is running
    if ! pgrep -u "$USER" ssh-agent > /dev/null; then
        ssh-agent -t 1h > "$XDG_RUNTIME_DIR/ssh-agent.env"
    fi
    
    # Source the agent environment
    if [[ ! "$SSH_AUTH_SOCK" ]]; then
        if [[ -f "$XDG_RUNTIME_DIR/ssh-agent.env" ]]; then
            source "$XDG_RUNTIME_DIR/ssh-agent.env" >/dev/null
        fi
    fi
    
    # Add keys to agent if they're not already loaded
    if ! ssh-add -l >/dev/null 2>&1; then
        # On macOS, first try to load from keychain
        if [[ "$OSTYPE" == darwin* ]]; then
            ssh-add --apple-load-keychain 2>/dev/null
            
            # If no keys in keychain, try to add them (will prompt once for passphrase)
            if ! ssh-add -l >/dev/null 2>&1; then
                echo "💡 Adding SSH keys to agent and keychain..."
                if [[ -f ~/.ssh/id_rsa ]]; then
                    ssh-add --apple-use-keychain ~/.ssh/id_rsa
                fi
                if [[ -f ~/.ssh/id_ed25519 ]]; then
                    ssh-add --apple-use-keychain ~/.ssh/id_ed25519
                fi
            fi
        else
            # Non-macOS systems
            if [[ -f ~/.ssh/id_rsa ]]; then
                ssh-add ~/.ssh/id_rsa 2>/dev/null
            fi
            if [[ -f ~/.ssh/id_ed25519 ]]; then
                ssh-add ~/.ssh/id_ed25519 2>/dev/null
            fi
        fi
    fi
fi

# ============================================================================
# GPG Agent
# ============================================================================
# Start GPG agent if installed
if [[ -o interactive ]] && command -v gpg-agent >/dev/null 2>&1; then
    gpgconf --launch gpg-agent 2>/dev/null
fi

# ============================================================================
# Terminal Title
# ============================================================================
# Set terminal title for interactive shells
if [[ -o interactive ]]; then
    case $TERM in
        xterm*|rxvt*|screen*|tmux*)
            # Set title to user@host: directory
            precmd() {
                print -Pn "\e]0;%n@%m: %~\a"
            }
            ;;
    esac
fi

# ============================================================================
# Interactive Development Tools
# ============================================================================
# rbenv initialization (interactive features)
if [[ -o interactive ]] && command -v rbenv >/dev/null 2>&1; then
    eval "$(rbenv init - zsh)"
fi

# pyenv initialization (interactive features)
if [[ -o interactive ]] && command -v pyenv >/dev/null 2>&1; then
    eval "$(pyenv init -)"
fi

# Google Cloud SDK completion
if [[ -o interactive ]] && [[ -f "$HOME/google-cloud-sdk/completion.zsh.inc" ]]; then
    source "$HOME/google-cloud-sdk/completion.zsh.inc"
fi

# Homebrew completion setup
if [[ -o interactive ]] && type brew &>/dev/null; then
    FPATH="$(brew --prefix)/share/zsh/site-functions:${FPATH}"
fi

# ============================================================================
# Welcome Message
# ============================================================================
# Display system information on interactive login
if [[ -o interactive ]] && [[ -o login ]]; then
    if command -v fastfetch >/dev/null 2>&1; then
        fastfetch --config minimal
    elif command -v neofetch >/dev/null 2>&1; then
        neofetch --config minimal
    fi
fi

# ============================================================================
# Directory Colors
# ============================================================================
# Setup LS_COLORS for better directory listing
if [[ -o interactive ]]; then
    if command -v vivid >/dev/null 2>&1; then
        export LS_COLORS="$(vivid generate molokai)"
    elif command -v dircolors >/dev/null 2>&1; then
        eval "$(dircolors -b)"
    fi
fi