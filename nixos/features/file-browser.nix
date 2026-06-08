{
  pkgs,
  ...
}:
{
  environment.systemPackages = with pkgs; [
    nemo
    nemo-with-extensions
  ];
}
