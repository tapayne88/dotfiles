CURRENT_BG='NONE'
SEGMENT_SEPARATOR=''

PROMPT_SYM="❯"
AHEAD="⇡"
BEHIND="⇣"
DIVERGED="⇕"
DIRTY_SYM="⋯ "
NONE="•"

# Begin a segment
# Takes two arguments, background and foreground. Both can be omitted,
# rendering default background/foreground.
prompt_segment() {
  local bg fg
  [[ -n $1 ]] && bg="%K{$1}" || bg="%k"
  [[ -n $2 ]] && fg="%F{$2}" || fg="%f"
  if [[ $CURRENT_BG != 'NONE' && $1 != $CURRENT_BG ]]; then
    echo -n " %{$bg%F{$CURRENT_BG}%}$SEGMENT_SEPARATOR%{$fg%} "
  else
    echo -n "%{$bg%}%{$fg%} "
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

### Prompt components
# Each component will draw itself, and hide itself if no information needs to be shown

# Context: user@hostname (who am I and where am I)
prompt_context() {
  local user=`whoami`

  if [[ "$user" != "$DEFAULT_USER" || -n "$SSH_CLIENT" ]]; then
    prompt_segment default white "$user@%m $PROMPT_SYM"
  fi
}

# Git: branch/detached head, dirty status
prompt_git() {
  local ref dirty
  if $(git rev-parse --is-inside-work-tree >/dev/null 2>&1); then
    dirty=$(git status -s)
    ref=$(git symbolic-ref HEAD 2> /dev/null) || ref="➦ $(git show-ref --head -s --abbrev |head -n1 2> /dev/null)"
    prompt_segment default white "on"
    prompt_segment default green "${ref/refs\/heads\//}"
    if [ -n $dirty ]; then
      prompt_segment default white "$DIRTY_SYM"
    fi
  fi
}

# Dir: current working directory
prompt_dir() {
#  prompt_segment blue black '%~'
  prompt_segment default yellow '%c'
}

# Status:
# - was there an error
# - am I root
# - are there background jobs?
prompt_status() {
  local symbols
  symbols=()

  local BACKGROUND_PROCS="$(jobs -l | wc -l | awk '{$1=$1};1')"

  #[[ $RETVAL -ne 0 ]] && symbols+="%{%F{red}%}✘"
  [[ $UID -eq 0 ]] && symbols+="%{%F{yellow}%}⚡"
  [[ $BACKGROUND_PROCS -gt 0 ]] && symbols+="%{%F{cyan}%}⚙ $BACKGROUND_PROCS"

  [[ -n "$symbols" ]] && prompt_segment black default "$symbols"
}

build_prompt() {
  local -a arr
  arr=()
  local cmd_out=""
  local cmd
  for cmd in ${(P)1}; do
    cmd_out="$(eval "$cmd")"
    if [ -n "$cmd_out" ]; then
      arr+="$cmd_out"
    fi
  done

  printf '%b' "${(j: :)arr}"
}


VALUES=(prompt_context prompt_dir prompt_git prompt_status prompt_end)
PROMPT=$(build_prompt VALUES)

# function fish_prompt
#   local last_command_status=$?
#   local cwd=%c

#   set -l fish     "❯"
#   set -l ahead    "⇡"
#   set -l behind   "⇣"
#   set -l diverged "⇕"
#   set -l dirty    "⋯ "
#   set -l none     "•"

#   set -l normal_color     (set_color normal)
#   set -l success_color    (set_color $fish_pager_color_progress ^/dev/null; or set_color cyan)
#   set -l error_color      (set_color $fish_color_error ^/dev/null; or set_color red --bold)
#   set -l directory_color  (set_color $fish_color_quote ^/dev/null; or set_color yellow)
#   set -l repository_color (set_color $fish_color_cwd ^/dev/null; or set_color green)

#   if test $last_command_status -eq 0
#     echo -n -s $normal_color $fish $normal_color
#   else
#     echo -n -s $error_color $fish $normal_color
#   end

#   if git_is_repo
#     echo -n -s " " $directory_color $cwd $normal_color

#     echo -n -s " on " $repository_color (git_branch_name) $normal_color " "

#     if git_is_touched
#       echo -n -s $dirty
#     else
#       echo -n -s (git_ahead $ahead $behind $diverged $none)
#     end
#   else
#     echo -n -s " " $directory_color $cwd $normal_color
#   end

#   echo -n -s " "
# end
