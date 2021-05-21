function patch-nix {
  sudo umount /proc/{cpuinfo,diskstats,meminfo,stat,uptime}
}
