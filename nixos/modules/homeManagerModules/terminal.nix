{
  flake.modules.homeManager.terminal =
    { config, ... }:
    {
      programs.kitty.enable = config.hostSettings.terminal.pname == "kitty";
      programs.ghostty.enable = config.hostSettings.terminal.pname == "ghostty";
    };
}
