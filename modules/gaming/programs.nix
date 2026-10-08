#
# Nix programs required for games to run
#

{ pkgs, ... }:
{
  # Enable Steam - gamingggggg
  programs.steam = {
    enable = true;
    remotePlay.openFirewall = false; # Ports in the firewall for Steam Remote Play
    dedicatedServer.openFirewall = false; # Ports in the firewall for Steam Dedicated Server
    extraCompatPackages = with pkgs; [
      proton-ge-bin
    ];
  };
}
