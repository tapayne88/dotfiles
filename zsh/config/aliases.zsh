# Make some possibly destructive commands more interactive
alias rm='rm -i'
alias mv='mv -i'
alias cp='cp -i'

# Override oh_my_zsh alias if we are using GNU tools
if test $HAS_BREW_COREUTILS; then
    alias ll='ls -lh --color'
fi

alias grep='grep -n --color=auto'
alias ..='cd ..'

# For reviewing merge before commit
# Review flow below:
#   - git mg --no-ff --no-commit <branch>
#   - vimmg <any file currently staged>
#   - :Gdiff ~1 (vim - compare staged copy with repo version)
#   - swap back to Gstatus pane
#   - move cursor to new file and press <Enter> (opens file below status)
alias vimmg='vim -c Gstatus'
