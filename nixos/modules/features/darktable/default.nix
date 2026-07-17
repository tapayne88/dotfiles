{
  flake.nixosModules.darktable = {
    hardware.graphics = {
      enable = true;
    };
  };

  flake.homeModules.darktable =
    { pkgs, ... }:

    let
      # Injects the keys from override file
      applyDarktableOverrides = pkgs.writeShellScript "apply-darktable-overrides" ''
        CONFIG_FILE="''${XDG_CONFIG_HOME:-$HOME/.config}/darktable/darktablerc"
        OVERRIDE_FILE="${./darktable-overrides.rc}"

        mkdir -p "$(dirname "$CONFIG_FILE")"
        touch "$CONFIG_FILE"

        while IFS='=' read -r key value; do
          if [[ -z "$key" || "$key" == \#* ]]; then 
            continue 
          fi
          ESCAPED_KEY=''${key//\//\\/}

          # Use an absolute path to sed to ensure the wrapper always finds it
          ${pkgs.gnused}/bin/sed -i "/^$ESCAPED_KEY=/d" "$CONFIG_FILE"
          echo "$key=$value" >> "$CONFIG_FILE"
        done < "$OVERRIDE_FILE"
      '';
    in
    {
      home.packages = [
        # Use symlinkJoin to bundle the original app with our wrapper
        (pkgs.symlinkJoin {
          name = "darktable-wrapped";
          paths = [ pkgs.darktable ];
          nativeBuildInputs = [ pkgs.makeWrapper ];
          postBuild = ''
            wrapProgram $out/bin/darktable \
              --run "${applyDarktableOverrides}"
          '';
        })
      ];
    };
}
