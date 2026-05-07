#!/usr/bin/env bash
#
# fzf configuration.
#
# shellcheck disable=SC2089,SC2090

# Search files that include hidden files and symbolic links, but exclude those in .gitignore
__fzf_fd_files_cmd="fd --type f --strip-cwd-prefix --hidden --follow"
# Search directories using the same criteria as above
__fzf_fd_dirs_cmd="fd --type d --strip-cwd-prefix --hidden --follow"
# Search all files (.git and node_modules included)
__fzf_fd_all_files_cmd="${__fzf_fd_files_cmd} --no-ignore"
# Search all directories (.git and node_modules included)
__fzf_fd_all_dirs_cmd="${__fzf_fd_dirs_cmd} --no-ignore"
# Excluded files and directories
__fzf_fd_exclude="--exclude '.git' --exclude 'node_modules'"

FZF_DEFAULT_COMMAND="${__fzf_fd_files_cmd}"
FZF_CTRL_T_COMMAND="${__fzf_fd_files_cmd} ${__fzf_fd_exclude}"
FZF_ALT_C_COMMAND="${__fzf_fd_dirs_cmd} ${__fzf_fd_exclude}"

FZF_DEFAULT_OPTS="
  --height 50% \
  --layout reverse \
  --border \
  --preview-window 'right:50%' \
  --bind 'ctrl-/:change-preview-window(80%|hidden|)' \
  --bind 'ctrl-u:preview-half-page-up,ctrl-d:preview-half-page-down'
"

FZF_CTRL_R_OPTS="
  --preview 'echo {} | bat --color=always --language=sh --style=plain' \
  --preview-window 'down,40%,wrap' \
  --prompt 'command history > ' \
  --header '?: toggle preview, Ctrl-R: toggle sort, Ctrl-Y: copy command' \
  --bind '?:toggle-preview' \
  --bind 'ctrl-y:execute-silent(echo -n {2..} | xsel -bi)+abort'
"

FZF_CTRL_T_OPTS="
  --select-1 \
  --exit-0 \
  --preview 'bat --color=always --style=full --line-range :100 {}' \
  --prompt 'files > ' \
  --header 'Press Ctrl-A: all files, Ctrl-Z: default' \
  --bind 'ctrl-a:change-prompt(all files > )+reload($__fzf_fd_all_files_cmd)' \
  --bind 'ctrl-z:change-prompt(files > )+reload($FZF_CTRL_T_COMMAND)'
"

FZF_ALT_C_OPTS="
  --select-1 \
  --exit-0 \
  --preview 'eza -a -F=auto -I='.git' -I='node_modules' --color=always --icon=always --group-dirs=first --depth=3 --tree {} | head -n 100' \
  --prompt 'dirs > ' \
  --header 'Press Ctrl-A: all dirs, Ctrl-Z: default' \
  --bind 'ctrl-a:change-prompt(all dirs > )+reload($__fzf_fd_all_dirs_cmd)' \
  --bind 'ctrl-z:change-prompt(dirs > )+reload($FZF_ALT_C_COMMAND)'
"

export FZF_DEFAULT_COMMAND
export FZF_DEFAULT_OPTS
export FZF_CTRL_R_OPTS
export FZF_CTRL_T_COMMAND
export FZF_CTRL_T_OPTS
export FZF_ALT_C_COMMAND
export FZF_ALT_C_OPTS

# fzf-tmux
export FZF_TMUX=1
export FZF_TMUX_OPTS="-p 90%"

if command -v "ghq" >/dev/null 2>&1; then
  # Change directory of a git repository managed by ghq using fzf
  function change-git-repository-with-fzf() {
    local repo_dir
    repo_dir=$(ghq list -p | fzf --preview "onefetch --no-art --no-color-palette {}")
    [ -z "$repo_dir" ] && return
    cd "$repo_dir" || exit
  }
fi
