# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{
  lib,
  pkgs,
  nixos-wsl,
  ...
}:
let
  user = import ../../modules/base/user.nix { };
in
{
  imports = [
    nixos-wsl.nixosModules.default
    ../../modules/base
    ../../modules/development
    ../../modules/local-llm
  ];

  # My work laptop running WSL doesn't have CUDA support
  hasCudaSupport = false;

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
  environment.sessionVariables."DEFAULT_ZELLIJ_PROFILE" = lib.mkForce "oktopi";

  # Enable Intel GPU drivers for the Oktopi laptop - unneeded
  hardware = {
    graphics = {
      enable = true;
      extraPackages = with pkgs; [
        intel-media-driver
        intel-ocl
        intel-vaapi-driver
        vpl-gpu-rt # for newer GPUs on NixOS >24.05 or unstable
      ];
    };
  };

  # WSL handles everything else, including hardware configuration
}
