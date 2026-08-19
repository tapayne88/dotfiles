{
  flake.nixosModules.greeter =
    {
      lib,
      pkgs,
      config,
      ...
    }:
    {
      services.greetd = {
        enable = true;
        settings = {
          default_session = {
            user = "greeter";
            command = "${lib.getExe pkgs.tuigreet} --cmd 'uwsm start hyprland-uwsm.desktop'";
          };
        };
      };

      environment.persistence."${config.hostSettings.persistenceMountPath}".directories = [
        {
          directory = "/var/cache/tuigreet";
          user = "greeter";
          group = "greeter";
          mode = "0755";
        }
      ];

      environment.etc."tuigreet/config.toml".text = ''
        [display]
        show_time = true

        [remember]
        username = true
        session = false
        user_session = true

        [user_menu]
        enabled = true
        min_uid = 1000
        max_uid = 60000

        [secret]
        mode = "characters" 
        characters = "*"

        [theme]
        border = "gray"
        container = "black"
        text = "gray"
        time = "green"
        prompt = "magenta"
        input = "gray"
        action = "darkgrey"
        button = "yellow"
      '';
    };
}
