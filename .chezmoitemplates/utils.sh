# import common settings and utility functions

_set_colors() {
  tput=$(which tput)

  if [ -n "$tput" ]; then
    ncolors=$($tput colors)
  fi

  if [ -t 1 ] && [ -n "$ncolors" ] && [ "$ncolors" -ge 8 ]; then
    RED="$(tput setaf 1)"
    GREEN="$(tput setaf 2)"
    YELLOW="$(tput setaf 3)"
    BLUE="$(tput setaf 4)"
    BOLD="$(tput bold)"
    NORMAL="$(tput sgr0)"
  else
    RED=""
    GREEN=""
    YELLOW=""
    BLUE=""
    BOLD=""
    NORMAL=""
  fi
}

_set_colors

info() {
  printf "${GREEN}INFO  ${NORMAL}"
  echo "$1"
}

warn() {
  printf "${YELLOW}WARN  ${NORMAL}"
  echo "$1"
}

error() {
  printf "${RED}ERROR ${NORMAL}"
  echo "$1"
}

# get OS distribution name
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
    warn "Unkown distribution"
    os_name="unkown"
  fi

  echo ${os_name}
}

# get OS bit(32bit => i686, 64bit => x86_64)
os_bit() {
  echo $(uname -m)
}

# get OS distribution and bit
os_info() {
  echo $(os_type) $(os_bit)
}

# determine if this OS is wsl.
is_wsl() {
  if [[ $(uname -r) =~ Microsoft ]]; then
    echo 0
  else
    echo 1
  fi
}
