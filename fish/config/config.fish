set -g theme_short_path yes

# Base16 Shell
if status --is-interactive
    eval sh $HOME/.config/base16-shell/scripts/base16-materia.sh
end

export VISUAL=nvim
export EDITOR=nvim

set -x TERM xterm-256color

# executable search path
set paths /usr/local/bin $HOME/.local/bin
for p in $paths;
    if test -d $p
        set PATH $p $PATH
    end
end

# Make some possibly destructive commands more interactive
alias rm='rm -i'
alias mv='mv -i'
alias cp='cp -i'

alias grep='grep -n --color=auto'

# fzf defaults
set -x FZF_DEFAULT_OPTS '--height 40% --reverse'
set -x FZF_DEFAULT_COMMAND "ag --nocolor -g ''"
set -x FZF_CTRL_T_COMMAND $FZF_DEFAULT_COMMAND
set -x FZF_ALT_C_COMMAND $FZF_DEFAULT_COMMAND
set -x FZF_TMUX 1

set -x FPP_DISABLE_SPLIT 1

# For reviewing merge before commit
# Review flow below:
#   - git mg --no-ff --no-commit <branch>
#   - vimmg <any file currently staged>
#   - :Gdiff ~1 (vim - compare staged copy with repo version)
#   - swap back to Gstatus pane
#   - move cursor to new file and press <Enter> (opens file below status)
alias vimmg='vim -c Gstatus'

# Setup special theme for ssh session, no special characters
set -l approvedTerminal (test "$TERM_PROGRAM" = "iTerm.app" -o "$TERM_PROGRAM" = "gnome-terminal")
if test -z "$SSH_CLIENT" -a -z "$SSH_TTY" -a $approvedTerminal
    set MYTMUX (which tmux)
    # Start tmux at start of each session (only when local and tmux exists)
    if test -n "$MYTMUX" -a $TERM != "screen" -a -z "$TMUX"
        tmux > /dev/null 2>&1
    end
end

set -l LOCAL_FISH ~/.local/config.fish
if test -e $LOCAL_FISH
    source $LOCAL_FISH
end
