# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{
  lib,
  config,
  nixos-wsl,
  packages,
  ...
}:
let
  user = import ../user.nix { inherit packages; };
in
{
  imports = [
    nixos-wsl.nixosModules.default
    ../base.nix
  ];

  wsl = {
    enable = true;
    defaultUser = user.userName; # Set your primary login username - from user.nix

    wslConf.interop.appendWindowsPath = true;
  };

  # Don't run any NixOS native stuff
  systemd.services.libvirtd.enable = lib.mkForce false;
  systemd.services.fix-wifi.enable = lib.mkForce false;

  # Use Windows networking
  networking.networkmanager.enable = lib.mkForce false;

  # Disable everything to do with display and Hyprland
  services.xserver.enable = lib.mkForce false;
  services.displayManager.sddm.enable = lib.mkForce false;
  programs.hyprland.enable = lib.mkForce false;
  programs.ssh.startAgent = lib.mkForce true;
  xdg.portal.enable = lib.mkForce false;
  systemd.user.services.change-wallpaper.enable = lib.mkForce false;

  # The prompt UI for SSH doesn't show up. Ask in the tty instead
  programs.ssh.enableAskPassword = lib.mkForce false;
  environment.sessionVariables."SSH_ASKPASS_REQUIRE" = lib.mkForce "never";

  # Enable Nvidia GPU drivers - unneeded
  hardware = {
    nvidia = {
      open = true;
      package = config.boot.kernelPackages.nvidiaPackages.stable;
      modesetting = {
        enable = true;
      };
      nvidiaSettings = true;
      powerManagement = {
        enable = false;
        finegrained = false;
      };
    };
    graphics = {
      enable = true;
    };
  };

  # WSL handles everything else, including hardware configuration
}
