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

  # Run an SSH agen to remember keys
  programs.ssh = {
    startAgent = true;
    enableAskPassword = true;
  };
}
