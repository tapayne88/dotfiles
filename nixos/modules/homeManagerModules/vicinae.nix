{
  inputs,
  ...
}:
{
  flake.modules.homeManager.vicinae = {
    nix.settings = {
      extra-substituters = [ "https://vicinae.cachix.org" ];
      extra-trusted-public-keys = [ "vicinae.cachix.org-1:1kDrfienkGHPYbkpNj1mWTr7Fm1+zcenzgTizIcI3oc=" ];
    };

    imports = [
      inputs.vicinae.homeManagerModules.default
    ];

    programs.vicinae = {
      enable = true;
      systemd = {
        enable = true;
        autoStart = true;
        environment = {
          USE_LAYER_SHELL = 1;
        };
      };
    };
  };
}
