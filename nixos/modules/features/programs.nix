{
  flake.nixosModules.programs =
    { pkgs, ... }:
    {
      environment.systemPackages = with pkgs; [
        tmux
        git
        curl
        ripgrep
        fd
        vim
        wget
        kitty
        ghostty
        chezmoi

        brightnessctl # brightness controls
        wl-clipboard # clipboard management
        mako # notifications
        impala # wifi utility
      ];

      programs.git.enable = true;
      programs.zsh.enable = true;
      programs.neovim = {
        enable = true;
        defaultEditor = true;
      };
    };

  flake.homeModules.programs = {
    # Document viewer
    programs.zathura.enable = true;
  };
}
