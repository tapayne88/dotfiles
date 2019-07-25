local OP_TMUX_TOKEN_FILE="$HOME/.op_tmux_token_tmp"

function sourceOPSession {
  if (test -n "$OP_TMUX_TOKEN_FILE" && test -e "$OP_TMUX_TOKEN_FILE"); then
    export OP_SESSION_my="$(cat $OP_TMUX_TOKEN_FILE)"
  fi
}

function opsignin {
  sourceOPSession
  if (! test -e $OP_TMUX_TOKEN_FILE); then
    op signin my --output=raw | tee $OP_TMUX_TOKEN_FILE
    sourceOPSession
  fi
}
