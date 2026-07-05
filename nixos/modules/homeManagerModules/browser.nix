{
  inputs,
  ...
}:
{
  flake.homeModules.browser = {
    imports = [
      inputs.zen-browser.homeModules.beta
    ];

    programs.zen-browser = {
      enable = true;
      setAsDefaultBrowser = true;
    };

    stylix.targets.zen-browser = {
      enable = true;
      profileNames = [ "Tom" ];
    };
  };
}
