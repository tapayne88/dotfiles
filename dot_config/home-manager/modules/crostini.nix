{ pkgs, ... }:
{
  home.packages = with pkgs; [
    unstable.alacritty # alacritty terminal
    unstable.kitty # kitty terminal
    unstable.glxinfo # utility for inspect openGL config
    nixgl.nixGLIntel # OpenGL wrapper for nix programs - Pixelbook specific
    unstable.obsidian # note taking app, see permittedInsecurePackages in flake
    xsel # copy / paste from neovim
  ];
}
