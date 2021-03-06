# use colors on terminal
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

info() {
  printf "${GREEN}  info  ${NORMAL}"
  echo "$1"
}

error() {
  printf "${RED}  error ${NORMAL}"
  echo "$1"
}

warn() {
  printf "${YELLOW}  warn  ${NORMAL}"
  echo "$1"
}

log() {
  echo "  $1"
}
