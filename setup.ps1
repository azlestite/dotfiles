
$ErrorActionPreference = "Stop"

[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$OutputEncoding = [System.Text.Encoding]::UTF8

# setup.ps1
# 実行ポリシーの一時的な変更（ネットワーク越しに実行する場合の安全策）
# --- 文字化け対策 ---

write-host "--- Dotfiles Setup Started ---" -ForegroundColor Cyan

# 1. 管理者権限のチェック（Wingetインストール等で必要な場合があるため）
$currentPrincipal = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
if (-not $currentPrincipal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Warning "一部のインストールには管理者権限が必要な場合があります。失敗した場合は管理者として実行してください。"
}

# 2. Winget (Package Manager) の確認
if (-not (Get-Command winget -ErrorAction SilentlyContinue)) {
    throw "Wingetが見つかりません。Windows App Installerを更新してください。"
}

# 3. chezmoi のインストール確認
if (-not (Get-Command chezmoi -ErrorAction SilentlyContinue)) {
    Write-Host "Installing chezmoi..." -ForegroundColor Yellow
    winget install --id twpayne.chezmoi --source winget --silent
    # パスを反映させるためにセッションを更新するか、直接パスを指定
    $env:Path += ";$env:USERPROFILE\AppData\Local\Microsoft\WinGet\Links"
}

# 4. Bitwarden CLI (bw) のインストール確認
if (-not (Get-Command bw -ErrorAction SilentlyContinue)) {
    Write-Host "Installing Bitwarden CLI..." -ForegroundColor Yellow
    winget install --id Bitwarden.CLI --source winget --silent
}

# 5. Bitwarden ログイン & セッション設定
if (-not $env:BW_SESSION) {
    Write-Host "Bitwardenにログインしてセッションキーを取得します..." -ForegroundColor Cyan
    # 既にログイン済みか確認
    $status = bw status | ConvertFrom-Json
    if ($status.status -eq "unauthenticated") {
        bw login
    }

    # アンロックしてセッションキーを環境変数にセット
    $sessionKey = bw unlock --raw
    if ($sessionKey) {
        $env:BW_SESSION = $sessionKey
        Write-Host "BW_SESSION を現在のセッションに設定しました。" -ForegroundColor Green
    }
}

# 6. chezmoi init & apply
Write-Host "Initializing chezmoi with builtin-git..." -ForegroundColor Yellow
# あなたのリポジトリURLに合わせて変更してください
$repoUrl = "https://github.com/azlestite/dotfiles.git"

# --use-builtin-git を使用して初期化
chezmoi init $repoUrl #--apply

Write-Host "--- Setup Complete! ---" -ForegroundColor Green
