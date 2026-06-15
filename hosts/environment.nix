{
  pkgs,
  packages,
  inputs,
}:
{
  environment.sessionVariables = {
    # If your cursor becomes invisible
    WLR_NO_HARDWARE_CURSORS = "1";

    # Hint electron apps to use wayland
    NIXOS_OZONE_WL = "1";
    SSH_ASKPASS_REQUIRE = "prefer";

    # For World of Warcraft
    WINEARCH = "win64";
    WINEPREFIX = "$HOME/.wine-battlenet";

    # Let GDM find gnome-session https://github.com/NixOS/nixpkgs/issues/523332#issuecomment-4528189167
    XDG_DATA_DIRS = [ "${pkgs.gdm}/share" ];
  };

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages =
    packages.nixosOnlyDeps
    ++ packages.systemPackages
    ++ packages.hyprlandPackages
    ++ [
      inputs.hyprpanel.packages.${pkgs.system}.default # Used instead of an overlay
      # customSddmTheme
    ];
}
