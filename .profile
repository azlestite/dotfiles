# ~/.profile: executed by the command interpreter for login shells.
# This file is not read by bash(1), if ~/.bash_profile or ~/.bash_login
# exists.
# see /usr/share/doc/bash/examples/startup-files for examples.
# the files are located in the bash-doc package.

# the default umask is set in /etc/profile; for setting the umask
# for ssh logins, install and configure the libpam-umask package.
umask 022

# set PATH so it includes user's private bin if it exists
if [ -d "$HOME/bin" ] ; then
    PATH="$HOME/bin:$PATH"
fi

# set PATH so it includes user's private bin if it exists
if [ -d "$HOME/.local/bin" ] ; then
    PATH="$HOME/.local/bin:$PATH"
fi

if [ -d "$HOME/local/bin" ] ; then
    PATH="$HOME/local/bin:$PATH"
fi

export PATH="$HOME/.anyenv/bin:$PATH"

export PIPENV_VENV_IN_PROJECT=1

# Go
export GOPATH=$HOME/go
export PATH="$PATH:$GOPATH/bin"
# Yarn
export PATH="$PATH:$HOME/.yarn/bin"

# VcXsrv
export DISPLAY=localhost:0.0
export LIBGL_ALWAYS_INDIRECT=1

# Fcitx
im=fcitx
export XMODIFIERS=@im=$im
export DefaultIMModule=$im
export GTK_IM_MODULE=$im
export QT_IM_MODULE=$im

# Docker for Windows
export DOCKER_HOST="tcp://0.0.0.0:2375"

if [ -n "$BASH_VERSION" ]; then
    # include .bashrc if it exists
    if [ -f "$HOME/.bashrc" ]; then
      source "$HOME/.bashrc"
    fi
fi

# Use Windows application
export PATH="$PATH:/mnt/c/Users/Manager/AppData/Local/Vivaldi/Application"
export BROWSER="vivaldi.exe"
