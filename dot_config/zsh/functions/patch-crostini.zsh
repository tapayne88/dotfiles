function patch-opengl {
  sudo mkdir -p /run/opengl-driver
  sudo ln -s `nix eval --raw nixpkgs.mesa_drivers.outPath`/lib /run/opengl-driver/lib
}

function patch-nix {
  sudo umount /proc/{cpuinfo,diskstats,meminfo,stat,uptime}
}

function launch-alacritty {
  WAYLAND_DISPLAY= alacritty &
}
