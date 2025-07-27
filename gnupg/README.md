# GPG設定

## セットアップ手順

1. GPG鍵の生成（新しい環境の場合）:
   ```bash
   gpg --full-generate-key
   ```

2. 設定ファイルのコピー:
   ```bash
   cp ~/.config/gnupg/gpg-agent.conf ~/.gnupg/gpg-agent.conf
   chmod 600 ~/.gnupg/gpg-agent.conf
   ```

3. GPG Agentの再起動:
   ```bash
   gpg-connect-agent reloadagent /bye
   ```

4. Git署名設定:
   ```bash
   # GPG鍵IDを確認
   gpg --list-secret-keys --keyid-format LONG
   
   # Gitに設定
   git config --global user.signingkey [YOUR_KEY_ID]
   git config --global commit.gpgsign true
   ```

## 既存の鍵の移行

既存の環境から鍵を移行する場合:

1. 既存環境で鍵をエクスポート:
   ```bash
   gpg --export-secret-keys [KEY_ID] > private.key
   gpg --export [KEY_ID] > public.key
   ```

2. 新環境でインポート:
   ```bash
   gpg --import public.key
   gpg --import private.key
   ```

3. 信頼レベル設定:
   ```bash
   gpg --edit-key [KEY_ID]
   # trust コマンドで信頼レベルを設定
   ```