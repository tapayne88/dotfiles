# Loads different file for each environment, also setting variables
if test -e ~/.config/fish/functions/work_env.fish
    echo 'At work...'
    set -x LOCATION 'work'
    work_env
end

if test -e ~/.config/fish/functions/home_env.fish
    echo 'At home...'
    set -x LOCATION 'home'
    home_env
end

env

if test -n "$SSH_CLIENT"; or test -n "$SSH_TTY"
    set -g __prompt_style 'simple'
else
    set -g __prompt_style 'fancy'

    # Start tmux at start of each session (only when local)
    if test $TERM != "screen"
        if test -z "$TMUX"
            tmux
        end
    end
end
