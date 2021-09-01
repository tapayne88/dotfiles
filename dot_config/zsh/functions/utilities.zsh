# Catch-all for simple utility functions

# ensure ssh server has terminfo for env TERM
function ssh() {
  emulate -L zsh

  # local LOCAL_TERM=$(echo -n "$TERM" | sed -e s/tmux/screen/)
  TERM=xterm-256color command ssh "$@"
}

# ctop doesn't like tmux terminfo
function ctop() {
  emulate -L zsh

  # local LOCAL_TERM=$(echo -n "$TERM" | sed -e s/tmux/screen/)
  TERM=xterm-256color command ctop "$@"
}

function toggle_color() {
  local THEME_FNAME="$XDG_CONFIG_HOME/.term_theme"
  local THEME=$(cat $THEME_FNAME)

  if [ "$THEME" = "nord" ]; then
    THEME="kitty_tokyonight_day"
    export BAT_THEME="base16"
  else
    THEME="nord"
    export BAT_THEME="Nord"
  fi

  echo $THEME > $THEME_FNAME
  kitty @ --to $KITTY_LISTEN_ON set-colors "~/.config/kitty/colors/$THEME.conf"
  tmux setenv THEME $THEME
  tmux source-file ~/.tmux.conf
}
