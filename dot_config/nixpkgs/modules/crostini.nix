{ pkgs, ... }:
{
  home.packages = with pkgs; [
    alacritty # alacritty terminal
    unstable.kitty # kitty terminal
    glxinfo # utility for inspect openGL config
    nixgl.nixGLIntel # OpenGL wrapper for nix programs - Pixelbook specific
    unstable.obsidian # note taking app
    xsel # copy / paste from neovim
  ];
}
