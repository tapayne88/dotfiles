function patch-nix {
  sudo umount /proc/{cpuinfo,diskstats,meminfo,stat,uptime}
}

function kitty {
  nixGLIntel command kitty "$@"
}

function glxinfo {
  nixGLIntel command glxinfo "$@"
}
