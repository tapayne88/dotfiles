{ config, lib, pkgs, inputs, ... }:

{
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  # Set your time zone.
  time.timeZone = "Europe/London";

  users.users.tom = {
    isNormalUser = true;
    extraGroups = [ "wheel" "networkmanager" ]; # Enable ‘sudo’ for the user.
    packages = with pkgs; [];
    shell = pkgs.zsh;
  };

  stylix = {
    enable = true;
    base16Scheme = "${pkgs.base16-schemes}/share/themes/catppuccin-mocha.yaml";
    image = ../home/catppuccin-nix.png;
  };

  environment.systemPackages = with pkgs; [
    tmux
    git
    curl
    ripgrep
    fd
    vim
    wget
    kitty
    chezmoi
    inputs.zen-browser.packages.${stdenv.hostPlatform.system}.default

    brightnessctl # brightness controls
    wl-clipboard # clipboard management
    mako # notifications
    impala # wifi utility

    # hyprland utils
    hyprlauncher
    hyprlock
    hyprpaper
  ];

  programs.nh = {
    enable = true;
    clean.enable = true;
    clean.extraArgs = "--keep-since 7d --keep 3";
  };

  programs.git.enable = true;
  programs.zsh.enable = true;
  programs.neovim = {
    enable = true;
    defaultEditor = true;
  };

  programs.regreet.enable = true;

  programs.hyprland = {
    enable = true;
    withUWSM = true;
    xwayland.enable = true;
  };

  programs.uwsm.enable = true;

  programs.waybar.enable = true;

  fonts.packages = with pkgs; [
    font-awesome
    nerd-fonts.jetbrains-mono
  ];

  programs._1password.enable = true;
  programs._1password-gui = {
    enable = true;
    # Certain features, including CLI integration and system authentication support,
    # require enabling PolKit integration on some desktop environments (e.g. Plasma).
    polkitPolicyOwners = [ "tom" ];
  };
}
