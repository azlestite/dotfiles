#!/usr/bin/env bats

# bats file_tags=ubuntu
@test "[ubuntu] dotfiles" {
  files_exists=(
    "${HOME}/.bashrc"
    "${HOME}/.profile"
    "${HOME}/.config/git/config"
    "${HOME}/.config/git/ignore"
    "${HOME}/.gnupg/gpg-agent.conf"
    "${HOME}/.gnupg/gpg.conf"
    "${HOME}/.ssh/config"
    "${HOME}/.ssh/ssh_config"
  )
  for file in "${files_exists[@]}"; do
    echo "Checking ${file}"
    [ -f "${file}" ]
  done

  directories_exists=(
    "${HOME}/.local"
  )
  for directory in "${directories_exists[@]}"; do
    echo "Checking ${directory}"
    [ -d "${directory}" ]
  done
}
