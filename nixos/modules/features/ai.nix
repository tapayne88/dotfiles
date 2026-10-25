{
  flake.homeModules.ai = {
    programs.opencode = {
      enable = true;
      cli = {
        keybinds = {
          leader = "ctrl+q";
          app_exit = "ctrl+c;<leader>q";
          messages_page_up = "ctrl+y";
          messages_page_down = "ctrl+e";
          messages_half_page_up = "ctrl+u";
          messages_half_page_down = "ctrl+d";
        };
        # TODO: Remove once stylix has been updated
        theme = {
          name = "stylix";
          mode = "system";
        };
      };
      mutableSettings = false;
      settings = {
        model = "opencode/glm-5.3";
      };
    };
  };
}
