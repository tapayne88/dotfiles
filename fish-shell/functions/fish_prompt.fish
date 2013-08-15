set __fish_git_prompt_showdirtystate 'yes'
set __fish_git_prompt_showuntrackedfiles 'yes'
set __fish_git_prompt_showstashstate 'yes'
set __fish_git_prompt_showupstream 'yes'

set ___fish_git_prompt_char_dirtystate '±'
set ___fish_git_prompt_char_untrackedfiles '±'
set ___fish_git_prompt_char_prefix '⭠'
set ___fish_git_prompt_char_stagedstate '→'
set ___fish_git_prompt_char_stashstate '↩'
set ___fish_git_prompt_char_upstream_ahead '↑'
set ___fish_git_prompt_char_upstream_behind '↓'

function __my_fish_prompt_cwd --description 'My version of get CWD'
    set __my_fish_prompt_cwd (set_color --background=blue black)
    set -l myCwd (basename $PWD)
    if test $myCwd = (whoami)
        set myCwd '~'
    end
    echo "$__my_fish_prompt_cwd" "$myCwd "
end

function fish_prompt --description 'Write out the prompt'
    if test $__prompt_style = 'simple'
        my_fish_prompt_simple
    else
        my_fish_prompt_fancy
    end
end

function my_fish_prompt_fancy
    if not set -q __fish_prompt_normal
        set -g __fish_prompt_normal (set_color normal)
    end

    echo -n -s (__my_fish_prompt_cwd) (__my_fish_git_prompt) "$__fish_prompt_normal"
end

function my_fish_prompt_simple
    set_color white
    echo -n (basename $PWD)
    set_color normal
    echo -n ' % '
end
