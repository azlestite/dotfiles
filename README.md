# dotfiles

Personal dotfiles managed with [chezmoi](https://www.chezmoi.io/).

## Fresh Machine Setup (Recommended)

Run the bootstrap script on a completely fresh macOS:

```bash
# One-liner (downloads and runs bootstrap script)

source "$(curl -fsSL https://raw.githubusercontent.com/azlestite/dotfiles/main/pre_setup.sh)"

/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/azlestite/dotfiles/main/setup.sh)"
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
