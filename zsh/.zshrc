
# Homebrewのパスを先頭に追加
export PATH="/opt/homebrew/bin:$PATH"
PATH="$PATH:"'/bin'
PATH="$PATH:"'/sbin'
PATH="$PATH:"'/usr/bin'
PATH="$PATH:"'/usr/sbin'
PATH="$PATH:"'/usr/local/bin'
PATH="$PATH:"'/Library/Apple/usr/bin'
PATH="$PATH:""$HOME"'/.local/.cargo/bin'
PATH="$PATH:"'/System/Library/PrivateFrameworks/Apple80211.framework/Versions/Current/Resources'
PATH="$PATH:"'/Users/shiraisr/Library/Application Support/Code/User/globalStorage/ms-vscode-remote.remote-containers/cli-bin'
export PATH="$HOME/go/bin:$PATH"
export PATH=$HOME/.nodebrew/current/bin:$PATH


alias -- ve='nvim ~/.config/zsh/.zshenv'
alias -- codee='code ~/.config/zsh/.zshenv'

alias -- vi="nvim"
alias -- soe='source ~/.config/zsh/.zshenv'
alias -- soz='source ${XDG_CONFIG_HOME}/zsh/.zshrc'
alias -- sot='tmux source-file ${XDG_CONFIG_HOME}/tmux/tmux.conf'

alias -- codez='code ${XDG_CONFIG_HOME}/zsh/.zshrc'
alias -- codel='code ${XDG_CONFIG_HOME}/nvim/init.lua'
alias -- codeg='code ${XDG_CONFIG_HOME}/git/config'

alias -- vz='nvim ${XDG_CONFIG_HOME}/zsh/.zshrc'
alias -- vv='nvim ${XDG_CONFIG_HOME}/nvim/init.lua'
alias -- vg='nvim ${XDG_CONFIG_HOME}/git/config'
alias -- vt='nvim ${XDG_CONFIG_HOME}/tmux/tmux.conf'
alias -- vy='nvim ${XDG_CONFIG_HOME}/yazi/yazi.toml'

alias -- which-command='whence'
alias -- ..='cd ..'
alias -- ...='cd ../../'
alias -- ....='cd ../../../'
alias -- ls='eza'
alias -- la='eza -a'
alias -- ll='eza --header --git --time-style=long-iso -agl'
alias -- lt='eza --icons -T -L 2 -a'
alias -- cat='bat'
alias -- ps='procs'
alias -- grep='rg'
alias -- find='fd'
# alias -- top='htop'
alias -- tm='tmux'
alias -- tmc='tmux -CC'
alias -- tmk='tmux kill-server'

alias -- lg='lazygit'
alias -- ld='lazydocker'
alias -- d='docker compose'
alias -- t='terraform'
alias -- lt='tftui'
alias -- crun='cargo run --quiet'
alias -- t='terraform'
alias -- yz='yazi'

alias -- pn='pnpm'

alias chrome="/Applications/Google\ Chrome.app/Contents/MacOS/Google\ Chrome"

function y() {
	local tmp="$(mktemp -t "yazi-cwd.XXXXXX")" cwd
	yazi "$@" --cwd-file="$tmp"
	if cwd="$(command cat -- "$tmp")" && [ -n "$cwd" ] && [ "$cwd" != "$PWD" ]; then
		builtin cd -- "$cwd"
	fi
	rm -f -- "$tmp"
}

plugins=(git)


setopt print_eight_bit
setopt +o nomatch
# 同時に起動した zsh の間でヒストリを共有する
setopt share_history
# 履歴をインクリメンタルに追加
setopt inc_append_history
# pushd したとき、ディレクトリがすでにスタックに含まれていればスタックに追加しない
setopt pushd_ignore_dups

# 色を使用出来るようにする
autoload -Uz colors
colors

setopt hist_ignore_all_dups
setopt hist_reduce_blanks
setopt auto_pushd
chpwd() {
if [[ $(pwd) != $HOME ]]; then;
    eza
fi
}
# Hook to add new entries to the database.
function __zoxide_hook() {
    # shellcheck disable=SC2312
    \command zoxide add -- "$(__zoxide_pwd)"
}

# Initialize hook.
# shellcheck disable=SC2154
if [[ ${precmd_functions[(Ie)__zoxide_hook]:-} -eq 0 ]] && [[ ${chpwd_functions[(Ie)__zoxide_hook]:-} -eq 0 ]]; then
    chpwd_functions+=(__zoxide_hook)
fi

# =============================================================================
# When using zoxide with --no-cmd, alias these internal functions as desired.
#

__zoxide_z_prefix='z#'

# Jump to a directory using only keywords.
function __zoxide_z() {
    # shellcheck disable=SC2199
    if [[ "$#" -eq 0 ]]; then
        __zoxide_cd ~
    elif [[ "$#" -eq 1 ]] && { [[ -d "$1" ]] || [[ "$1" = '-' ]] || [[ "$1" =~ ^[-+][0-9]$ ]]; }; then
        __zoxide_cd "$1"
    elif [[ "$@[-1]" == "${__zoxide_z_prefix}"?* ]]; then
        # shellcheck disable=SC2124
        \builtin local result="${@[-1]}"
        __zoxide_cd "${result:${#__zoxide_z_prefix}}"
    else
        \builtin local result
        # shellcheck disable=SC2312
        result="$(\command zoxide query --exclude "$(__zoxide_pwd)" -- "$@")" &&
            __zoxide_cd "${result}"
    fi
}

# Jump to a directory using interactive search.
function __zoxide_zi() {
    \builtin local result
    result="$(\command zoxide query --interactive -- "$@")" && __zoxide_cd "${result}"
}

# Completions.
if [[ -o zle ]]; then
    function __zoxide_z_complete() {
        # Only show completions when the cursor is at the end of the line.
        # shellcheck disable=SC2154
        [[ "${#words[@]}" -eq "${CURRENT}" ]] || return 0

        if [[ "${#words[@]}" -eq 2 ]]; then
            _files -/
        elif [[ "${words[-1]}" == '' ]] && [[ "${words[-2]}" != "${__zoxide_z_prefix}"?* ]]; then
            \builtin local result
            # shellcheck disable=SC2086,SC2312
            if result="$(\command zoxide query --exclude "$(__zoxide_pwd)" --interactive -- ${words[2,-1]})"; then
                result="${__zoxide_z_prefix}${result}"
                # shellcheck disable=SC2296
                compadd -Q "${(q-)result}"
            fi
            \builtin printf '\e[5n'
        fi
        return 0
    }

    \builtin bindkey '\e[0n' 'reset-prompt'
    [[ "${+functions[compdef]}" -ne 0 ]] && \compdef __zoxide_z_complete __zoxide_z
fi

\builtin alias cd=__zoxide_z
\builtin alias cdi=__zoxide_zi

autoload -Uz compinit
compinit -u

# zoxide after compinit
eval "$(zoxide init zsh)"

# tre-command(tree)
tre() { command tre "$@" -e && source "/tmp/tre_aliases_$USER" 2>/dev/null; }
alias -- tree='tre -a'

# fzfの設定
 source <(fzf --zsh)
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

# cdr自体の設定
if [[ -n $(echo ${^fpath}/chpwd_recent_dirs(N)) && -n $(echo ${^fpath}/cdr(N)) ]]; then
    autoload -Uz chpwd_recent_dirs cdr add-zsh-hook
    add-zsh-hook chpwd chpwd_recent_dirs
    zstyle ':completion:*' recent-dirs-insert both
    zstyle ':chpwd:*' recent-dirs-default true
    zstyle ':chpwd:*' recent-dirs-max 1000
fi

# fzf cdr
function fzf-cdr() {
    local selected_dir=$(cdr -l | awk '{ print $2 }' | fzf --reverse)
    if [ -n "$selected_dir" ]; then
        BUFFER="cd ${selected_dir}"
        zle accept-line
    fi
    zle clear-screen
}
zle -N fzf-cdr
setopt noflowcontrol
bindkey '^f' fzf-cdr

function select-history() {
  BUFFER=$(history -n -r 1 | fzf --no-sort +m --query "$LBUFFER" --prompt="History > ")
  CURSOR=$#BUFFER
}
zle -N select-history
bindkey '^r' select-history

fdgit() {
  local top_dir
  top_dir="$(git rev-parse --show-toplevel 2>/dev/null)"
  if [ -z "$top_dir" ]; then
    echo "Not in a Git repository."
    return 1
  fi

  local dir
  dir="$(
    cd "$top_dir" || return 1
    find . -type d -not -path '*/.git/*' 2>/dev/null | fzf
  )"

  [ -z "$dir" ] && return
  cd "$top_dir/$dir"
}
zle -N fdgit
bindkey '^g' fdgit

fbr() {
  local branches branch
  branches=$(git --no-pager branch -vv) &&
  branch=$(echo "$branches" | fzf +m) &&
  git checkout $(echo "$branch" | awk '{print $1}' | sed "s/.* //")
}
zle -N fbr
bindkey '^b' fbr

fbrr() {
  local branches branch
  branches=$(git branch --all | grep -v HEAD) &&
  branch=$(echo "$branches" |
           fzf-tmux -d $(( 2 + $(wc -l <<< "$branches") )) +m) &&
  git checkout $(echo "$branch" | sed "s/.* //" | sed "s#remotes/[^/]*/##")
}
zle -N fbrr
bindkey '^y^' fbrr

autoload history-search-end
zle -N history-beginning-search-backward-end history-search-end
zle -N history-beginning-search-forward-end history-search-end
bindkey "^p" history-beginning-search-backward-end
bindkey "^n" history-beginning-search-forward-end

# for vscode
bindkey -e


# if [[ ! -n $TMUX && $- == *l* ]]; then
#   # get the IDs
#   ID="`tmux list-sessions`"
#   if [[ -z "$ID" ]]; then
#     tmux new-session
#   fi
#   create_new_session="Create New Session"
#   ID="$ID\n${create_new_session}:"
#   ID="`echo $ID | fzf | cut -d: -f1`"
#   if [[ "$ID" = "${create_new_session}" ]]; then
#     tmux new-session
#   elif [[ -n "$ID" ]]; then
#     tmux attach-session -t "$ID"
#   else
#     :  # Start terminal normally
#   fi
# fi

source $(brew --prefix)/share/zsh-autosuggestions/zsh-autosuggestions.zsh
eval "$(uv generate-shell-completion zsh)"
eval "$(starship init zsh)"

# 対話的シェルかどうか確認
if [[ $- == *i* ]]; then

  # ターミナルが Ghostty か確認
  if [[ "$TERM" == "xterm-ghostty" ]]; then
    # zellij 自動起動スクリプトを評価
    eval "$(zellij setup --generate-auto-start zsh)"
  fi
fi

# The next line updates PATH for the Google Cloud SDK.
if [ -f '/Users/shiraisr/google-cloud-sdk/path.zsh.inc' ]; then . '/Users/shiraisr/google-cloud-sdk/path.zsh.inc'; fi

# The next line enables shell command completion for gcloud.
if [ -f '/Users/shiraisr/google-cloud-sdk/completion.zsh.inc' ]; then . '/Users/shiraisr/google-cloud-sdk/completion.zsh.inc'; fi

# The following lines have been added by Docker Desktop to enable Docker CLI completions.
fpath=(/Users/shiraisr/.docker/completions $fpath)
autoload -Uz compinit
compinit
# End of Docker CLI completions
