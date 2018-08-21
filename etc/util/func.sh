dot_dir=$HOME/dotfiles

# Check command
has() {
  type "$1" >/dev/null 2>&1
}

# Create symboloc link
symlink() {
  # [ -e "$2" ] || ln -snfv "$1" "$2"
  ln -snfv "$1" "$2"
}

sym_dot_dir() {
  cd ${dot_dir}/$1
  files=$(\find . -maxdepth 4 -type f)
  echo $files | xargs dirname | uniq | sed 's%\./%%' | xargs -i mkdir -p $HOME/$1/{}

  for file in $files
  do
    symlink "$dot_dir/$1/${file:2}" "$HOME/$1/${file:2}"
  done
}

# Get Linux distribution name
os_type() {
  if [[ $(uname) = "Linux" ]]; then
    # Debian
    if [ -f /etc/debian_version ] || [ -f /etc/debian_release ]; then
      if [ -f /etc/lsb-release ]; then
        if cat /etc/lsb-release | grep -q "Linux Mint"; then
          os_name="mint" # Linux Mint
        fi
        os_name="ubuntu" # Ubuntu
      else
        os_name="debian" # Debian
      fi
    elif [ -f /etc/fedora-release ]; then
      os_name="fedora" # Fedra
    # Red Hat
    elif [ -f /etc/redhat-release ]; then
      if [ -f /etc/oracle-release ]; then
        os_name="oracle" # Oracle Linux
      elif cat /etc/redhat-release | grep -q "CentOS"; then
        os_name="centos" # CentOS
      else
        os_name="redhat" # Red Hat Enterprise Linux
      fi
    elif [ -f /etc/system-release ]; then
      os_name="amazon" # Amazon Linux
    elif [ -f /etc/arch-release ]; then
      os_name="arch" # Arch Linux
    elif [ -f /etc/turbolinux-release ]; then
      os_name="turbol" # Turbolinux
    elif [ -f /etc/SuSE-release ]; then
      os_name="suse" # SuSE Linux
    elif [ -f /etc/mandriva-release ]; then
      os_name="mandriva" # Mandriva Linux
    elif [ -f /etc/vine-release ]; then
      os_name="vine" # Vine Linux
    elif [ -f /etc/gentoo-release ]; then
      os_name="gentoo" # Gentoo Linux
    fi
  # MacOS
  elif [[ $(uname) = "Darwin" ]]; then
    :
  # Windows
  elif [[ $(uname -s) = "MINGW" ]]; then
    :
  # Android
  elif [[ $(uname -o) = "Android" ]]; then
    :
  else
    # Other
    echo "Unkown distribution"
    os_name="unkown"
  fi

  echo ${os_name}
}

# 32bit => i686 & 64bit => x86_64
os_bit() {
  echo $(uname -m)
}

# Get distribution and bit
os_info() {
  echo $(os_type) $(os_bit)
}

wsl() {
  if [[ $(uname -r) =~ Microsoft ]]; then
    echo 0
  else
    echo 1
  fi
}

# fix sed command diff between GNU and BSD
if sed --version 2>/dev/null | grep -q GNU; then
  alias sedi='sed -i '
else
  alias sedi='sed -i "" '
fi
