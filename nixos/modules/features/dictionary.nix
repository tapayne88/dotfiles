{
  flake.nixosModules.dictionary = { pkgs, ... }: {
    services.dictd = {
      enable = true;
      DBs = with pkgs.dictdDBs; [
        wordnet
        wiktionary
      ];
    };
  };
}
