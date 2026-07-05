{
  flake.modules.nixos.file-browser =
    {
      pkgs,
      ...
    }:
    {
      environment.systemPackages = with pkgs; [
        # Fix nemo icon
        (symlinkJoin {
          name = "nemo";
          paths = [ nemo ];
          postBuild = ''
            # Remove the symlinked desktop file from the cache clone
            rm $out/share/applications/nemo.desktop

            # Copy the raw text file from the binary cache so we can edit it
            cp ${nemo}/share/applications/nemo.desktop $out/share/applications/nemo.desktop

            # Make it writable and swap out the icon string
            chmod +w $out/share/applications/nemo.desktop
            substituteInPlace $out/share/applications/nemo.desktop \
              --replace "Icon=system-file-manager" "Icon=nemo"
          '';
        })
        nemo-with-extensions
      ];
    };
}
