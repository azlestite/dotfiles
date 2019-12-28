#!/bin/bash
#
# Setup script

set -Ceu -o pipefail

script_dir=$(cd $(dirname ${BASH_SOURCE}) && pwd)

source ${script_dir}/util/include.sh

########################################
#### Start setup script
########################################

dotfiles_logo="
██████╗  ██████╗ ████████╗███████╗██╗██╗   ███████╗███████╗
██╔══██╗██╔═══██╗╚══██╔══╝██╔════╝██║██║   ██╔════╝██╔════╝
██║  ██║██║   ██║   ██║   █████╗  ██║██║   █████╗  ███████╗
██║  ██║██║   ██║   ██║   ██╔══╝  ██║██║   ██╔══╝  ╚════██║
██████╔╝╚██████╔╝   ██║   ██║     ██║█████╗███████╗███████║
╚═════╝  ╚═════╝    ╚═╝   ╚═╝     ╚═╝╚════╝╚══════╝╚══════╝
**** WHAT DOES THIS SCRIPT DO? ****
1. Download my dotfiles from https://github.com/azlestite/dotfiles
2. Run setup script according to OS type
3. Create symbolic links
"

printf "${BOLD}"
echo "$dotfiles_logo"
printf "${NORMAL}"

log "*** ATTENTION ***"
log "This script changes the current setup status."
log "Please read this script before start script."
echo ""

read -p "$(warn 'Are you sure you want to install it? [y/N] ')" -n 1 -r

if [[ ! $REPLY =~ ^[Yy] ]]; then
  echo ""
  error "Installation cancelled. Nothing changed."
  exit 1
fi

echo ""
info "Start installing dotfiles."

if [ ! -d "$dot_dir" ]; then
  info "Installing dotfiles for the first time..."
  git clone git@github.com:azlestite/dotfiles.git "$dot_dir"
#else
#  info "The dotfiles already exists!!!"
#  info "Please delete dotfiles and run this script again."
#  exit 1
fi

# Setup OS packages
echo ""
declare -a info=($(os_info))
case ${info[0]} in
ubuntu)
  info "Setup for Ubuntu..."

  if [[ ${info[1]} == "x86_64" ]]; then
    echo x86_64
  fi

  source $script_dir/setup_ubuntu.sh
  ;;
*)
  echo "Unsupported OS. Please install packages manually."
  ;;
esac

# Deploy
source $script_dir/link.sh

echo ""
info "Installation completed."
