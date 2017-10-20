set -g theme_short_path yes

# Base16 Shell
if status --is-interactive
    eval sh $HOME/.config/base16-shell/scripts/base16-materia.sh
end

export VISUAL=nvim
export EDITOR=nvim

# executable search path
set PATH $HOME/.local/bin /usr/local/bin $PATH

set fish_function_path $OMF_CONFIG/functions $fish_function_path

# Make some possibly destructive commands more interactive
alias rm='rm -i'
alias mv='mv -i'
alias cp='cp -i'

alias grep='grep -n --color=auto'
alias ..='cd ..'

alias fem='cd $HOME/dev/stash.skybet.net/skybetdev/tiny/Mbet/React/FootballEventMarkets'
alias fsc='cd $HOME/dev/stash.skybet.net/skybetdev/tiny/Mbet/React/ScoreCentre'
alias uil='cd $HOME/dev/stash.skybet.net/@skybet/ui-library'
alias sbd='cd $HOME/dev/stash.skybet.net/skybetdev'

# fzf defaults
set -U FZF_LEGACY_KEYBINDINGS 0
set -x FZF_DEFAULT_OPTS '--height 40% --reverse'
set -x FZF_DEFAULT_COMMAND 'ag --nocolor -g ""'

set -x AWS_ACCESS_KEY_ID AKIAIM4BTY5VWBKK566Q
set -x AWS_SECRET_ACCESS_KEY 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
set -x AWS_REGION eu-west-1

# For reviewing merge before commit
# Review flow below:
#   - git mg --no-ff --no-commit <branch>
#   - vimmg <any file currently staged>
#   - :Gdiff ~1 (vim - compare staged copy with repo version)
#   - swap back to Gstatus pane
#   - move cursor to new file and press <Enter> (opens file below status)
alias vimmg='vim -c Gstatus'

# Setup special theme for ssh session, no special characters
if test -z "$SSH_CLIENT" -a -z "$SSH_TTY" -a "$TERM_PROGRAM" = "iTerm.app"
    set MYTMUX (which tmux)
    # Start tmux at start of each session (only when local and tmux exists)
    if test -n "$MYTMUX" -a $TERM != "screen" -a -z "$TMUX"
        tmux > /dev/null 2>&1
    end
end
