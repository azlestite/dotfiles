# iwr -useb https://raw.githubusercontent.com/azlestite/dotfiles/main/setup.ps1 | iex
# 日本語を含む場合
# iwr -useb https://raw.githubusercontent.com/azlestite/dotfiles/main/setup.ps1 | Select-Object -ExpandProperty Content | iex
# iex ((iwr -useb https://raw.githubusercontent.com/azlestite/dotfiles/main/setup.ps1).Content)
# irm https://raw.githubusercontent.com/azlestite/dotfiles/main/setup.ps1 | iex

$ErrorActionPreference = "Stop"

Write-Host "--- Dotfiles Setup Started ---" -ForegroundColor Cyan

# Check for Administrative Privileges
$currentPrincipal = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
if (-not $currentPrincipal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Warning "Some installations may require Administrator privileges. If it fails, please run PowerShell as Admin."
}

# Check for Winget
if (-not (Get-Command winget -ErrorAction SilentlyContinue)) {
    throw "Winget not found. Please update Windows App Installer."
}

# Install PowerShell(pwsh) if not exists
if (-not (Get-Command pwsh -ErrorAction SilentlyContinue)) {
    Write-Host "Installing PowerShell via Winget..." -ForegroundColor Yellow
    winget install --id Microsoft.PowerShell --source winget --silent
}

# Install Git if not exists
if (-not (Get-Command git -ErrorAction SilentlyContinue)) {
    Write-Host "Installing Git via Winget..." -ForegroundColor Yellow
    winget install --id Git.Git --source winget --silent
}

# Install Gpg4win if not exists
if (-not (Get-Command gpg -ErrorAction SilentlyContinue)) {
    Write-Host "Installing Gpg4win via Winget..." -ForegroundColor Yellow
    winget install --id GnuPG.Gpg4win --source winget --silent
    [System.Environment]::SetEnvironmentVariable("GNUPGHOME", "${env:USERPROFILE}\.gnupg", "User")
    [System.Environment]::SetEnvironmentVariable("SSH_AUTH_SOCK", "\\.\pipe\openssh-ssh-agent", "User")
}

# Install chezmoi if not exists
if (-not (Get-Command chezmoi -ErrorAction SilentlyContinue)) {
    Write-Host "Installing chezmoi via Winget..." -ForegroundColor Yellow
    winget install --id twpayne.chezmoi --source winget --silent
    # Refresh Path for the current session
    $env:Path += ";$env:USERPROFILE\AppData\Local\Microsoft\WinGet\Links"
}

# Install Bitwarden CLI (bw) if not exists
if (-not (Get-Command bw -ErrorAction SilentlyContinue)) {
    Write-Host "Installing Bitwarden CLI via Winget..." -ForegroundColor Yellow
    winget install --id Bitwarden.CLI --source winget --silent
}

# Bitwarden Login & Session Setup
if (-not $env:BW_SESSION) {
    Write-Host "Checking Bitwarden authentication..." -ForegroundColor Cyan
    $status = bw status | ConvertFrom-Json
    if ($status.status -eq "unauthenticated") {
        Write-Host "Please login to Bitwarden:" -ForegroundColor White
        bw login
    }

    Write-Host "Unlocking vault to set BW_SESSION..." -ForegroundColor Cyan
    $sessionKey = bw unlock --raw
    if ($sessionKey) {
        $env:BW_SESSION = $sessionKey
        Write-Host "BW_SESSION has been set for the current session." -ForegroundColor Green
    } else {
        Write-Error "Failed to retrieve Bitwarden session key."
    }
}

# chezmoi init & apply
Write-Host "Initializing chezmoi with builtin-git..." -ForegroundColor Yellow
$repoUrl = "https://github.com/azlestite/dotfiles.git"

# Initializing with --use-builtin-git as originally requested
chezmoi init $repoUrl #--apply --dry-run --verbose

Write-Host "--- Setup Complete! ---" -ForegroundColor Green
