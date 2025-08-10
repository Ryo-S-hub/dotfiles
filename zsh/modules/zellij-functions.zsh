#!/usr/bin/env zsh
# ~/.config/zsh/modules/zellij-functions.zsh - Zellij session management functions

# ============================================================================
# Core Zellij Functions
# ============================================================================

# 基本的なZellijセッション管理
zj() {
    # TTYチェック
    if [ ! -t 0 ] || [ ! -t 1 ]; then
        echo "❌ エラー: zellij はインタラクティブなターミナル環境でのみ実行できます" >&2
        return 1
    fi
    
    # zellij がインストールされているか確認
    if ! command -v zellij &> /dev/null; then
        echo "❌ エラー: zellij がインストールされていません" >&2
        echo "💡 インストール方法: brew install zellij" >&2
        return 1
    fi
    
    local session_name="${1:-$(basename $(pwd))}"
    
    # セッション名をサニタイズ（特殊文字を除去）
    session_name=$(echo "$session_name" | tr '[:upper:]' '[:lower:]' | sed 's/[^a-z0-9-]/-/g')
    
    # 既存セッションの確認
    if zellij list-sessions 2>/dev/null | grep -q "^$session_name\s"; then
        echo "📎 既存セッション '$session_name' に接続します..."
        zellij attach "$session_name"
    else
        echo "🚀 新規セッション '$session_name' を作成します..."
        zellij attach -c "$session_name"
    fi
}

# 開発環境用zellij セッション（日付付き）
zjdev() {
    local date_suffix=$(date +%Y%m%d)
    local session_name="dev-${date_suffix}"
    
    # 開発用レイアウトの確認
    if [ -f "$HOME/.config/zellij/layouts/dev.kdl" ]; then
        echo "🚀 開発用レイアウトで '$session_name' セッションを作成します..."
        zellij attach -c "$session_name" --layout "$HOME/.config/zellij/layouts/dev.kdl"
    else
        echo "🚀 標準レイアウトで '$session_name' セッションを作成します..."
        zellij attach -c "$session_name"
    fi
}

# 作業内容別zellij セッション
zjwork() {
    local work_type="${1:-general}"
    local session_name="work-$work_type"
    
    echo "🚀 作業セッション '$session_name' を作成/接続します..."
    zellij attach -c "$session_name"
}

# プロジェクトタイプ別tmuxセッション
zjp() {
    local project_name=$(basename $(pwd))
    local project_type=""
    
    # プロジェクトタイプを検出
    if [ -f "package.json" ]; then
        project_type="node"
    elif [ -f "Cargo.toml" ]; then
        project_type="rust"
    elif [ -f "go.mod" ]; then
        project_type="go"
    elif [ -f "requirements.txt" ] || [ -f "pyproject.toml" ]; then
        project_type="python"
    elif [ -f "Gemfile" ]; then
        project_type="ruby"
    elif [ -d ".git" ]; then
        project_type="git"
    else
        project_type="general"
    fi
    
    local session_name="${project_name}-${project_type}"
    
    echo "🔧 プロジェクトタイプ: $project_type"
    echo "📂 セッション名: $session_name"
    
    # プロジェクトタイプ別の初期化
    case "$project_type" in
        "node"|"rust"|"go"|"python"|"ruby")
            # 開発用レイアウトがあれば使用
            if [ -f "$HOME/.config/zellij/layouts/dev.kdl" ]; then
                echo "🚀 開発用レイアウトで '$session_name' を作成します..."
                zellij attach -c "$session_name" --layout "$HOME/.config/zellij/layouts/dev.kdl"
            else
                zellij attach -c "$session_name"
            fi
            ;;
        *)
            # シンプルなレイアウト
            echo "🚀 標準レイアウトで '$session_name' を作成します..."
            zellij attach -c "$session_name"
            ;;
    esac
}

# 古いzellij セッションを削除
zjclean() {
    echo "🧹 古いzellij セッションを削除します..."
    
    # 終了済みセッションをリストアップ
    local old_sessions=$(zellij list-sessions 2>/dev/null | grep 'EXITED' | awk '{print $1}' | sed 's/\x1b\[[0-9;]*m//g')
    
    if [ -z "$old_sessions" ]; then
        echo "削除対象のセッションはありません。"
        return 0
    fi
    
    echo "以下のセッションを削除します:"
    echo "$old_sessions" | sed 's/^/  - /'
    echo
    read -q "REPLY?削除しますか？ [y/N] "
    echo
    
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        echo "$old_sessions" | while read session; do
            echo "削除中: $session"
            zellij delete-session "$session" 2>/dev/null
        done
        echo "✅ 完了しました！"
    else
        echo "❌ キャンセルしました。"
    fi
}

# FZFベースのzellij セッション切り替え（Ctrl+N/P対応）
zjs() {
    # TTYチェック
    if [ ! -t 0 ] || [ ! -t 1 ]; then
        echo "❌ エラー: この機能はインタラクティブなターミナル環境でのみ使用できます" >&2
        return 1
    fi
    
    # zellij がインストールされているか確認
    if ! command -v zellij &> /dev/null; then
        echo "❌ エラー: zellij がインストールされていません" >&2
        return 1
    fi
    
    # 既存セッション一覧を取得
    local sessions_raw=$(zellij list-sessions 2>/dev/null)
    if [ $? -ne 0 ] || [ -z "$sessions_raw" ]; then
        echo "📋 既存のセッションがありません。新しいセッションを作成しますか？"
        read -q "REPLY?[y/N] "
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            local session_name="default-$(date +%H%M%S)"
            echo "🚀 新規セッション '$session_name' を作成します..."
            zellij attach -c "$session_name"
        fi
        return 0
    fi
    
    # セッション一覧を整形（ANSIエスケープシーケンスを除去）
    local sessions=$(echo "$sessions_raw" | sed 's/\x1b\[[0-9;]*m//g' | grep -v '^$')
    
    if [ -z "$sessions" ]; then
        echo "📋 使用可能なセッションがありません"
        return 1
    fi
    
    # fzf でセッション選択（Ctrl+N/P対応のキーバインド付き）
    local selected_session=$(echo "$sessions" | fzf \
        --height=60% \
        --layout=reverse \
        --border=rounded \
        --prompt="🔗 Zellij Session > " \
        --header="🎯 セッションを選択 | Ctrl+N/P: 上下移動 | Enter: 接続 | Esc: キャンセル" \
        --bind="ctrl-n:down,ctrl-p:up" \
        --bind="ctrl-j:down,ctrl-k:up" \
        --preview="echo '📋 セッション情報:'; echo; echo '{}'  | sed 's/^/  /'" \
        --preview-window="right:40%:wrap")
    
    if [ -z "$selected_session" ]; then
        echo "❌ セッション選択がキャンセルされました"
        return 1
    fi
    
    # セッション名を抽出（最初の単語）
    local session_name=$(echo "$selected_session" | awk '{print $1}')
    
    if [ -n "$session_name" ]; then
        echo "🔗 セッション '$session_name' に接続します..."
        zellij attach "$session_name"
    else
        echo "❌ エラー: セッション名を取得できませんでした"
        return 1
    fi
}

# カスタムセッション作成（テンプレート付き）
zjcreate() {
    local session_name="${1:-}"
    local template="${2:-default}"
    
    if [ -z "$session_name" ]; then
        echo "使用方法: zjcreate <セッション名> [テンプレート]"
        echo
        echo "利用可能なテンプレート:"
        echo "  default  - 標準レイアウト"
        echo "  dev      - 開発用レイアウト（3ペイン）"
        echo "  minimal  - 最小構成"
        return 1
    fi
    
    # セッション名をサニタイズ
    session_name=$(echo "$session_name" | tr '[:upper:]' '[:lower:]' | sed 's/[^a-z0-9-]/-/g')
    
    # 既存セッションをチェック
    if zellij list-sessions 2>/dev/null | grep -q "^$session_name\s"; then
        echo "⚠️  セッション '$session_name' は既に存在します"
        echo "既存セッションに接続しますか？"
        read -q "REPLY?[y/N] "
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            zellij attach "$session_name"
        fi
        return 0
    fi
    
    echo "🚀 テンプレート '$template' でセッション '$session_name' を作成します..."
    
    case "$template" in
        "dev")
            if [ -f "$HOME/.config/zellij/layouts/dev.kdl" ]; then
                zellij attach -c "$session_name" --layout "$HOME/.config/zellij/layouts/dev.kdl"
            else
                echo "⚠️  開発用レイアウトファイルが見つかりません。標準レイアウトを使用します。"
                zellij attach -c "$session_name"
            fi
            ;;
        "minimal"|"min")
            # 最小構成でセッション作成
            zellij attach -c "$session_name"
            ;;
        "default"|*)
            # 標準レイアウト
            zellij attach -c "$session_name"
            ;;
    esac
}