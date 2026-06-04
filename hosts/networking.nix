{ config, pkgs, ... }:
let
  hostName = "nixos";
in 
{
  networking = {
    hostName = "${hostName}"; # Define your hostname.

    networkmanager = {
      # Enable networking
      enable = true;

      # Meme stuff to make DNS work on the desktop
      dns = "none";

      # On desktop home wifi, setting this to false prevents the speed from dropping to near zero after a few minutes
      wifi.powersave = false;
    };

    wireless = {
      # Enables wireless support via wpa_supplicant.
      # enable = false; # Clashes with networkmanager
    };

    # Set DNS
    nameservers = [
      "127.0.0.1"
      "::1"
      "8.8.8.8"
      "1.1.1.1"
      "2001:4860:4860::8888"
      "2001:4860:4860::8844"
    ];

    # Meme stuff to make DNS work on the desktop
    resolvconf.enable = pkgs.lib.mkForce false;
    dhcpcd.extraConfig = "nohook resolve.conf";
  };
}
