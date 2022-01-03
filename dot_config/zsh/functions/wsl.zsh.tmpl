function copy-alacritty-config {
  fake_chezmoi "$1" ~/.config/alacritty/alacritty.yml /mnt/c/Users/tapay/AppData/Roaming/alacritty
}

function copy-windows-terminal-config {
  fake_chezmoi "$1" ~/.config/windows_terminal/settings.json /mnt/c/Users/tapay/AppData/Local/Packages/Microsoft.WindowsTerminal_8wekyb3d8bbwe/LocalState/settings.json
}

function fake_chezmoi {
  local arg=$1
  local new_settings=$2
  local current_settings=$3

  diff -u $current_settings $new_settings | diff-so-fancy

  if [ "$arg" != "-n" ]; then
    cp $new_settings $current_settings
  fi
}
