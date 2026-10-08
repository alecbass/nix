{
  packages,
  ...
}:
{
  environment.sessionVariables = {
    ZELLIJ_DEFAULT_PROFILE = "default";
  };

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = packages.systemPackages ++ packages.hyprlandPackages;
}
