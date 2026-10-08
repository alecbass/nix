{
  pkgs,
  packages,
  ...
}:
{
  environment.sessionVariables = {
    # If your cursor becomes invisible
    WLR_NO_HARDWARE_CURSORS = "1";

    # Hint electron apps to use wayland
    NIXOS_OZONE_WL = "1";

    # Let GDM find gnome-session https://github.com/NixOS/nixpkgs/issues/523332#issuecomment-4528189167
    XDG_DATA_DIRS = [ "${pkgs.gdm}/share" ];
    ZELLIJ_DEFAULT_PROFILE = "default";
  };

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages =
    packages.nixosOnlyDeps ++ packages.systemPackages ++ packages.hyprlandPackages;
}
