{ pkgs, ... }:
{
  services.greetd = {
    enable = true;
    settings = {
      default_session = {
        user = "greeter";
        command = ''
          ${pkgs.tuigreet}/bin/tuigreet \
          --time \
          --remember \
          --user-menu \
          --remember-user-session \
          --cmd 'uwsm start hyprland-uwsm.desktop'
        '';
      };
    };
  };
}
