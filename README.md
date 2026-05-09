# dotfiles

Personal dotfiles managed with [chezmoi](https://www.chezmoi.io/).

## Fresh Machine Setup (Recommended)

### WSL2(Ubuntu)
Run the bootstrap script on a completely fresh macOS:

```bash
# One-liner (downloads and runs bootstrap script)
bash -c "$(curl -fsSL https://raw.githubusercontent.com/azlestite/dotfiles/main/setup.sh)"
```

### Windows

```ps
iwr -useb https://raw.githubusercontent.com/azlestite/dotfiles/main/setup.ps1 | iex
```

以降はメモ

```ps
winget install twpayne.chezmoi

chezmoi init --apply azlestite
# OR
chezmoi init --apply --verbose https://github.com/azlestite/dotfiles.git
```


```ps
winget install --id Microsoft.PowerShell --source winget
winget configure --enable

& {$env:DOTFILE_REPO_URL = "https://github.com/azlestite/dotfiles.git" ; iex "&{$(irm 'https://get.chezmoi.io/ps1')} -b '$env:USERPROFILE\.temp\bin' -- init --apply $env:DOTFILE_REPO_URL"}
```

```ps
# 1. chezmoi をインストール
winget install twpayne.chezmoi

# 2. dotfiles を適用
chezmoi init --apply kkamegawa

# 3. Windows DSC で残りのアプリ・設定を適用
winget configure -f "$(chezmoi source-path)\..\reference\windows\configuration.dsc.yaml"

# 4. mise でツールをインストール
gh auth login
mise install

# 5. PowerShell モジュール（Az / Microsoft.Entra / Microsoft.Graph）は
#    winget configure でセットアップ済み

# 6. APM で Copilot CLI 設定を適用
apm install

# 7. Visual Studio の設定をインポート（手動）
#    Tools > Import and Export Settings > Import selected environment settings
#    ファイル: ~/.visualstudio/vscode2026insider.vssettings
```

```ps
# 安装 chezmoi
(irm -useb get.chezmoi.io/ps1) | powershell -c -

# 初始化 chezmoi 仓库
chezmoi init --apply azlestite/dotfiles
```

[dotfiles/.install/bootstrap-windows.ps1 at main · mariomarin/dotfiles](https://github.com/mariomarin/dotfiles/blob/main/.install/bootstrap-windows.ps1)

```ps
iwr -useb https://raw.githubusercontent.com/mariomarin/dotfiles/main/.install/bootstrap-windows.ps1 | iex

```

## Manual Setup

If you prefer manual control:

### 1. Install Prerequisites

```bash
curl -fsSL https://raw.githubusercontent.com/azlestite/dotfiles/main/pre_setup.sh -o /tmp/pre_setup.sh && source /tmp/pre_setup.sh && rm -rf /tmp/pre_setup.sh && echo $BW_SESSION
```

### 2. Configure Bitwarden CLI

```bash
bw login
bw sync
export BW_SESSION="$(bw unlock --raw)"
```

### 3. Apply dotfiles

```bash
chezmoi init --apply mkatanski
```

### 4. Post-Install

```bash
# Restart shell or source config
source ~/.bashrc

# Install Tmux plugins (start tmux, then Ctrl+A, Shift+I)
tmux

# Open Neovim to install plugins automatically
nvim
```
