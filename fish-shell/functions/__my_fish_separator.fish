function __my_fish_separator --description 'Gets a coloured separator between segments of prompt'
    set -l __my_fish_segment_separator '⮀'
    set __fish_my_separator (set_color --background=$argv[1] $argv[2])
    echo "$__fish_my_separator"$__my_fish_segment_separator
end
