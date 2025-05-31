#デフォルトの pager を less から lv に設定
export PAGER='lv -c'
#文字コードの指定
# export LANG=ja_JP.UTF-8
# https://onk.hatenablog.jp/entry/2025/05/22/023048
export LANG=C

export XDG_CONFIG_HOME="$HOME/.config"
export XDG_CACHE_HOME="$HOME/.cache"
export XDG_STATE_HOME="$HOME/.local/state"
export FZF_BASE="/opt/homebrew/bin/fzf"
export FZF_DEFAULT_COMMAND='fd --type file --color=always'
export FZF_DEFAULT_OPTS='--ansi'
export FZF_CTRL_DEFAULT_COMMAND="'rg --files --hidden --follow --glob "!.git/*"'"
# CTRL-Y to copy the command into clipboard using pbcopy
export FZF_CTRL_R_OPTS="
  --bind 'ctrl-y:execute-silent(echo -n {2..} | pbcopy)+abort'
  --color header:italic
  --header 'Press CTRL-Y to copy command into clipboard'"
export FZF_CTRL_T_OPTS="
  --walker-skip .git,node_modules,target
  --preview 'bat -n --color=always {}'
  --bind 'ctrl-/:change-preview-window(down|hidden|)'"
# Print tree structure in the preview window
export FZF_ALT_C_OPTS="
  --walker-skip .git,node_modules,target
  --preview 'tree -C {}'"
export FZF_TMUX=1
export FZF_TMUX_OPTS="-p 50%"
export _ZO_DATA_DIR="/Users/shiraisr/.cache/zoxide"
export RUST_BACKTRACE="1"
export HISTFILE="/Users/shiraisr/.local/state/.zsh_history"
export SAVEHIST="100000"
export WORDCHARS="'*?_-.[]~=!@#$%^(){}<>'"
export CARGO_HOME="/Users/shiraisr/.local/.cargo/bin"
export RUSTUP_HOME="/Users/shiraisr/.local/.rustup"
# export VOLTA_HOME="/Users/shiraisr/.local/.volta"
# export VOLTA_CACHE="/Users/shiraisr/.cache/.volta"
# export VOLTA_FEATURE_PNPM="1"

export YAZI_CONFIG_HOME="/Users/shiraisr/.config/yazi"

export LESSKEY="/Users/shiraisr/.config/less"
export LESSHISTFILE="/Users/shiraisr/.local/state/less/lesshist"

export NPM_CONFIG_USERCONFIG="/Users/shiraisr/.config/npm/.npmrc"

export TIGRC_USER="Users/shiraisr/.config/tig"

export ZDOTDIR="$XDG_CONFIG_HOME/zsh"

# for Yazi
export EDITOR="/opt/homebrew/bin/nvim"

# https://knowledge.sakura.ad.jp/38985/
export OPENSSL_X509_TEA_DISABLE=1

export IDEAVIMRC="/Users/shiraisr/.config/.ideavimrc"

export GOOGLE_APPLICATION_CREDENTIALS="/Users/shiraisr/kiiromamert-430d54897a92.json"

# Added by Toolbox App
export PATH="$PATH:/Users/shiraisr/Library/Application Support/JetBrains/Toolbox/scripts"
