#!/bin/bash
#
# Create symbolic links

set -Ceu -o pipefail

source ${script_dir:-$(cd $(dirname ${BASH_SOURCE}) && pwd)}/util/include.sh

echo ""
info "Create symbolic links..."
echo ""

cd $dot_dir

array=(".config" ".gnupg" ".ssh" ".tmux")

for f in .??*
do
  [[ "$f" == ".git" ]] && continue

  for str in "${array[@]}"
  do
    [[ "$f" == "${str}" ]] && continue 2
  done

  symlink "$dot_dir/$f" "$HOME/$f"
  #echo "$f"

  #if [ $? -eq 0 ]; then
  #  printf "  %-25s -> %s\n" "\$HOME/$f" "\$dotfiles/$f"
  #fi
done

for d in "${array[@]}"
do
  sym_dot_dir "$d"
done
