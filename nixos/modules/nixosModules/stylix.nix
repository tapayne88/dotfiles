{
  flake.nixosModules.stylix =
    { pkgs, ... }:
    {
      stylix = {
        enable = true;
        base16Scheme = "${pkgs.base16-schemes}/share/themes/catppuccin-mocha.yaml";
        image = ../assets/nixos-catppuccin-mocha.png;
        polarity = "dark";

        cursor = {
          name = "Bibata-Modern-Classic";
          package = pkgs.bibata-cursors;
          size = 24;
        };

        fonts = {
          monospace = {
            package = pkgs.nerd-fonts.jetbrains-mono;
            name = "JetBrainsMono Nerd Font";
          };

          sansSerif = {
            package = pkgs.inter;
            name = "Inter";
          };

          serif = {
            package = pkgs.noto-fonts;
            name = "Noto Serif";
          };

          emoji = {
            package = pkgs.noto-fonts-color-emoji;
            name = "Noto Color Emoji";
          };
        };

        icons = {
          enable = true;
          package = pkgs.tela-circle-icon-theme;
          dark = "Tela-circle-dark";
          light = "Tela-circle-light";
        };
      };
    };
}
