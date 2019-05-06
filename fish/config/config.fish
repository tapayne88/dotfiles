set -x VISUAL nvim
set -x EDITOR nvim

# executable search path
set paths /usr/local/bin $HOME/.local/bin /home/linuxbrew/.linuxbrew/bin $HOME/Library/Python/3.7/bin
for p in $paths;
    if test -d $p
        set PATH $p $PATH
    end
end

# install fisher plugin manager if not installed
if not functions -q fisher
    set -q XDG_CONFIG_HOME; or set XDG_CONFIG_HOME ~/.config
    curl https://git.io/fisher --create-dirs -sLo $XDG_CONFIG_HOME/fish/functions/fisher.fish
    fish -c fisher
end

# Make some possibly destructive commands more interactive
alias rm 'rm -i'
alias mv 'mv -i'
alias cp 'cp -i'

alias grep 'grep -n --color=auto'
alias ssh 'env TERM=xterm-256color ssh'

set OP_TMUX_TOKEN_FILE ~/.op_tmux_token_tmp

function sourceOPSession
    if test -e $OP_TMUX_TOKEN_FILE
        set -gx 'OP_SESSION_my' (cat $OP_TMUX_TOKEN_FILE)
    end
end

function opsignin
    sourceOPSession
    if not test -e $OP_TMUX_TOKEN_FILE
        op signin my --output=raw | tee $OP_TMUX_TOKEN_FILE
        sourceOPSession
    end
end

sourceOPSession

# Setup consistent fish colours
set fish_color_normal normal
set fish_color_command --bold
set fish_color_quote yellow
set fish_color_redirection brblue
set fish_color_end brmagenta
set fish_color_error brred
set fish_color_param cyan
set fish_color_comment red
set fish_color_match --background=brblue
set fish_color_selection white --bold --background=brblack
set fish_color_search_match bryellow --background=brblack
set fish_color_operator bryellow
set fish_color_escape bryellow --bold
set fish_color_cwd green
set fish_color_autosuggestion 555 brblack
set fish_color_user brgreen
set fish_color_host normal
# set --erase fish_color_cancel
set fish_pager_color_prefix white --bold --underline
# set --erase fish_pager_color_completion
set fish_pager_color_description yellow
set fish_pager_color_progress brwhite --background=cyan
# set --erase fish_pager_color_secondary

# fzf defaults
set -x FZF_DEFAULT_COMMAND "ag --nocolor -g ''"
set -x FZF_TMUX 1
set -x FZF_TMUX_HEIGHT 40%
set -U FZF_LEGACY_KEYBINDINGS 0

set -U FZF_DEFAULT_OPTS "\
  --layout reverse \
  --color bg+:0,hl:0,hl+:4,fg:7,fg+:15,header:4,info:4,marker:4,pointer:4,prompt:4,spinner:4 \
"

set -x FPP_DISABLE_SPLIT 1

# For reviewing merge before commit
# Review flow below:
#   - git mg --no-ff --no-commit <branch>
#   - vimmg <any file currently staged>
#   - :Gdiff ~1 (vim - compare staged copy with repo version)
#   - swap back to Gstatus pane
#   - move cursor to new file and press <Enter> (opens file below status)
alias vimmg 'vim -c Gstatus'

# Setup special theme for ssh session, no special characters
set -l approvedTerminal (test "$TERM_PROGRAM" = "iTerm.app" -o "$TERM_PROGRAM" = "gnome-terminal")
if test -z "$SSH_CLIENT" -a -z "$SSH_TTY" -a $approvedTerminal
    set MYTMUX (which tmux)
    set -x TMUXP_CONFIGDIR "$HOME/.tmuxp"
    # Start tmux at start of each session (only when local and tmux exists)
    if test -n "$MYTMUX" -a $TERM != "screen" -a -z "$TMUX"
        tmux > /dev/null 2>&1
    end
end

set -l LOCAL_FISH ~/.local/config.fish
if test -e $LOCAL_FISH
    source $LOCAL_FISH
end

# Improved loading of kubectl aliases when available
[ -f ~/.kubectl_aliases ]; and source (cat ~/.kubectl_aliases | sed -E 's/alias (.*)=\'(.*)\'/function \1; \2; end/' | psub)
# The below version took ~7 seconds to load!
# [ -f ~/.kubectl_aliases ]; and source ~/.kubectl_aliases

# tabtab source for serverless package
# uninstall by removing these lines or running `tabtab uninstall serverless`
[ -f /usr/local/lib/node_modules/serverless/node_modules/tabtab/.completions/serverless.fish ]; and source /usr/local/lib/node_modules/serverless/node_modules/tabtab/.completions/serverless.fish
# tabtab source for sls package
# uninstall by removing these lines or running `tabtab uninstall sls`
[ -f /usr/local/lib/node_modules/serverless/node_modules/tabtab/.completions/sls.fish ]; and source /usr/local/lib/node_modules/serverless/node_modules/tabtab/.completions/sls.fish
