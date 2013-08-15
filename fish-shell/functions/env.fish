# executable search path
# including Android SDK
set -l paths $HOME/.local/bin
set paths $paths $HOME/.local/sbin
set paths $paths $HOME/dev/android-sdk-linux/tools
set paths $paths $HOME/dev/android-sdk-linux/platform-tools

set -x PATH $paths $PATH

set -x VISUAL $HOME/.local/bin/vim
set -x EDITOR $HOME/.local/bin/vim
set -x TERM xterm-256color

if test -L $HOME/.dir_colors
    dircolors ~/.dir_colors
end

set -l node (which node)

if test $node != "node not found"
    set -x NODE_PATH $node
end

# For reviewing merge before commit
# Review flow below:
#   - git mg --no-ff --no-commit <branch>
#   - vimmg <any file currently staged>
#   - :Gdiff ~1 (vim - compare staged copy with repo version)
#   - swap back to Gstatus pane
#   - move cursor to new file and press <Enter> (opens file below status)
alias vimmg "vim -c Gstatus"

function env
end
