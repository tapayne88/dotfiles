CURRENT_BG='NONE'
SEGMENT_SEPARATOR=''

PROMPT_SYM="❯"
AHEAD_SYM="⇡"
BEHIND_SYM="⇣"
DIVERGED_SYM="⇕"
DIRTY_SYM="⋯ "
NONE_SYM="•"

# Begin a segment
# Takes two arguments, background and foreground. Both can be omitted,
# rendering default background/foreground.
prompt_segment() {
  local bg fg
  [[ -n $1 ]] && bg="%K{$1}" || bg="%k"
  [[ -n $2 ]] && fg="%F{$2}" || fg="%f"
  if [[ $CURRENT_BG != 'NONE' && $1 != $CURRENT_BG ]]; then
    echo -n " %{$bg%F{$CURRENT_BG}%}$SEGMENT_SEPARATOR%{$fg%}"
  else
    echo -n "%{$bg%}%{$fg%}"
  fi
  CURRENT_BG=$1
  [[ -n $3 ]] && echo -n $3
}

# End the prompt, closing any open segments
prompt_end() {
  if [[ -n $CURRENT_BG ]]; then
    echo -n " %{%k%F{$CURRENT_BG}%}$SEGMENT_SEPARATOR"
  else
    echo -n "%{%k%}"
  fi
  echo -n "%{%f%}"
  CURRENT_BG=''
}

# Status:
# - was there an error
prompt_status() {
  echo -n "%(?.%F{white}.%F{red})$PROMPT_SYM%f "
}

# Context: user@hostname (who am I and where am I)
prompt_context() {
  local user=`whoami`

  if [[ "$user" != "$DEFAULT_USER" || -n "$SSH_CLIENT" ]]; then
    prompt_segment default white "$user@%m "
  fi
}

# Dir: current working directory
prompt_dir() {
  prompt_segment default yellow '%c '
}

# Git: branch/detached head, dirty status
prompt_git() {
  local ref dirty
  if $(git rev-parse --is-inside-work-tree >/dev/null 2>&1); then
    dirty=$(git status --porcelain --ignore-submodules=dirty 2> /dev/null | tail -n1)
    ref=$(git symbolic-ref HEAD 2> /dev/null) || ref="➦ $(git show-ref --head -s --abbrev |head -n1 2> /dev/null)"
    prompt_segment default white "on "
    prompt_segment default green "${ref/refs\/heads\//} "
    if [ -n "$dirty" ]; then
      prompt_segment default white "$DIRTY_SYM"
    else
      prompt_segment default white $(git_remote_status)
    fi
  fi
}

# Gets the difference between the local and remote branches
function git_remote_status() {
  local remote ahead behind git_remote_status
  remote=${$(git rev-parse --verify ${hook_com[branch]}@{upstream} --symbolic-full-name 2>/dev/null)/refs\/remotes\/}
  if [[ -n ${remote} ]]; then
    ahead=$(git rev-list ${hook_com[branch]}@{upstream}..HEAD 2>/dev/null | wc -l)
    behind=$(git rev-list HEAD..${hook_com[branch]}@{upstream} 2>/dev/null | wc -l)

    if [[ $ahead -eq 0 ]] && [[ $behind -eq 0 ]]; then
      git_remote_status="$NONE_SYM"
    elif [[ $ahead -gt 0 ]] && [[ $behind -eq 0 ]]; then
      git_remote_status="$AHEAD_SYM"
    elif [[ $behind -gt 0 ]] && [[ $ahead -eq 0 ]]; then
      git_remote_status="$BEHIND_SYM"
    elif [[ $ahead -gt 0 ]] && [[ $behind -gt 0 ]]; then
      git_remote_status="$DIVERGED_SYM"
    fi

    echo $git_remote_status
  fi
}

PROMPT="$(prompt_context)$(prompt_status)$(prompt_dir)$(prompt_git)$(prompt_end)"
