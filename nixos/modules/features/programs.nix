{
  flake.nixosModules.programs =
    { pkgs, ... }:
    {
      services.gnome.gnome-keyring.enable = true;
      services.power-profiles-daemon.enable = true;
      services.upower.enable = true;

      environment.systemPackages = with pkgs; [
        chezmoi
        curl
        fd
        ghostty
        git
        kitty
        opencode
        ripgrep
        tmux
        vim
        wget

        brightnessctl # brightness controls
        wl-clipboard # clipboard management
        picard
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

    # VNC client
    services.remmina.enable = true;
  };
}
