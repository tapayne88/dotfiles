function patch-nix {
  sudo umount /proc/{cpuinfo,diskstats,meminfo,stat,uptime}
}

function kitty {
  nixGL command kitty
}
