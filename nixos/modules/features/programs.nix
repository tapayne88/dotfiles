{
  flake.nixosModules.programs =
    { pkgs, ... }:
    {
      services.gnome.gnome-keyring.enable = true;
      services.power-profiles-daemon.enable = true;
      services.upower.enable = true;

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
