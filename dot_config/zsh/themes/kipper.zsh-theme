# vim:ft=zsh ts=2 sw=2 sts=2
setopt promptsubst

CURRENT_BG='NONE'
SEGMENT_SEPARATOR=''

PROMPT_SYM="❯"
AHEAD_SYM="⇡"
BEHIND_SYM="⇣"
DIVERGED_SYM="⇕"
DIRTY_SYM="⋯ "
NONE_SYM="•"
ITALIC_ON=$'\e[3m'
ITALIC_OFF=$'\e[23m'

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
    echo -n "%{%k%F{$CURRENT_BG}%}$SEGMENT_SEPARATOR"
  else
    echo -n "%{%k%}"
  fi
  echo -n "%{%f%}"
  CURRENT_BG=''
}

# Status:
# - was there an error
prompt_symbol() {
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
  prompt_segment default yellow '%c'
}

# Jobs: any background jobs running
prompt_jobs() {
  local -a symbols

  [[ $(jobs -l | wc -l) -gt 0 ]] && symbols+="%{%F{cyan}%}⚙"

  [[ -n "$symbols" ]] && prompt_segment default cyan "$symbols " || echo -n " "
}

# Git: branch/detached head, dirty status
prompt_git() {
  local ref dirty
  if $(git rev-parse --is-inside-work-tree >/dev/null 2>&1); then
    dirty=$(git status --porcelain --ignore-submodules=dirty 2> /dev/null | tail -n1)
    ref=$(git symbolic-ref HEAD 2> /dev/null) || ref="➦ $(git show-ref --head -s --abbrev | head -n1 2> /dev/null)"
    prompt_segment default white "on "

    local has_worktree
    [[ $(git worktree list | wc -l) -gt 1 ]] && has_worktree="TRUE"
    if [[ -n $has_worktree ]]; then
      local worktree_name=$(basename $(git root))
      if [[ -n ${worktree_name} ]]; then
        prompt_segment default "8m" "${worktree_name}/"
      fi
    fi

    prompt_segment default green "${ref/refs\/heads\//} "

    if [ -n "$dirty" ]; then
      prompt_segment default white "$DIRTY_SYM"
    else
      prompt_segment default white $(git_remote_status)
    fi
    echo -n " "
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

function preexec() {
  timer=$(date +%s%3N)
}

function precmd() {
  if [ $timer ]; then
    local now=$(date +%s%3N)
    local d_ms=$(($now-$timer))
    local d_s=$((d_ms / 1000))
    local ms=$((d_ms % 1000))
    local s=$((d_s % 60))
    local m=$(((d_s / 60) % 60))
    local h=$((d_s / 3600))
    if ((h > 0)); then elapsed=${h}h${m}m
    elif ((m > 0)); then elapsed=${m}m${s}s
    elif ((s >= 10)); then elapsed=${s}.$((ms / 100))s
    elif ((s > 0)); then elapsed=${s}.$((ms / 10))s
    else elapsed=${ms}ms
    fi

    export RPROMPT="%F{cyan}%{$ITALIC_ON%}${elapsed}%{$ITALIC_OFF%}%f"
    unset timer
  fi
}

build_prompt() {
  prompt_context
  prompt_symbol
  prompt_dir
  prompt_jobs
  prompt_git
  prompt_end
}

PROMPT='%{%f%b%k%k%}$(build_prompt)'
