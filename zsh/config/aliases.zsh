# Good aliases
alias ls='ls --color=auto'
alias ll='ls -alhF'
alias la='ls -A'
alias l='ls -CF'

# Make some possibly destructive commands more interactive
alias rm='rm -i'
alias mv='mv -i'
alias cp='cp -i'

alias grep='grep -n --color=auto'
alias ..='cd ..'

alias define='~/git/scripts/define.sh'

# For reviewing merge before commit
# Review flow below:
#   - git mg --no-ff --no-commit <branch>
#   - vimmg <any file currently staged>
#   - :Gdiff ~1 (vim - compare staged copy with repo version)
#   - swap back to Gstatus pane
#   - move cursor to new file and press <Enter> (opens file below status)
alias vimmg='vim -c Gstatus'
