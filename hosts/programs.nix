{ }:
{

  # Allow dynamically-linked executable to run
  programs.nix-ld.enable = true;

  # Install firefox.
  programs.firefox.enable = true;

  # Enable Hyprland
  programs.hyprland = {
    enable = true;
    xwayland.enable = true;
    withUWSM = true;
  };
}
