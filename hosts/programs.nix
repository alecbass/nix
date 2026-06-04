{ }:
{

  # Allow dynamically-linked executable to run
  programs.nix-ld.enable = true;

  # Install firefox.
  programs.firefox.enable = true;

  # Install direnv
  programs.direnv.enable = true;

  # Enable Hyprland
  programs.hyprland = {
    enable = true;
    xwayland.enable = true;
    withUWSM = true;
  };

  # Enable Steam - gamingggggg
  programs.steam = {
    enable = true;
    remotePlay.openFirewall = false; # Ports in the firewall for Steam Remote Play
    dedicatedServer.openFirewall = false; # Ports in the firewall for Steam Dedicated Server
  };

  # Run an SSH agen to remember keys
  programs.ssh = {
    startAgent = true;
    enableAskPassword = true;
  };
}
