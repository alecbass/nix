# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{
  lib,
  pkgs,
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
    # ../../modules/nvidia-drivers.nix
    # ../../modules/nvidia-prime-drivers.nix
    # ../../modules/intel-drivers.nix
  ];

  wsl = {
    enable = true;
    defaultUser = user.userName; # Set your primary login username - from user.nix

    # Optional: Integrate Windows PATH into Linux
    wslConf.interop.appendWindowsPath = true;
    wslConf.network.generateResolvConf = false;
  };

  # Overrides because Windows settings take precedence
  networking.enableIPv6 = false;
  networking.networkmanager.enable = lib.mkForce false;
  networking.nameservers = [
    "8.8.8.8"
    "1.1.1.1"
    "8.8.4.4"
  ];
  networking.resolvconf.enable = true;
  boot.kernel.sysctl."net.ipv6.conf.eth0.disable_ipv6" = true;

  # Native NixOS and/or Hyprland-specific, disable
  systemd.services.libvirtd.enable = lib.mkForce false;
  systemd.services.fix-wifi.enable = lib.mkForce false;
  systemd.user.services.change-wallpaper.enable = lib.mkForce false;
  services.xserver.enable = lib.mkForce false;
  services.displayManager.sddm.enable = lib.mkForce false;
  programs.hyprland.enable = lib.mkForce false;
  programs.ssh.startAgent = lib.mkForce true;
  xdg.portal.enable = lib.mkForce false;

  # The prompt UI doesn't show up. Ask in the tty instead
  programs.ssh.enableAskPassword = lib.mkForce false;
  environment.sessionVariables."SSH_ASKPASS_REQUIRE" = lib.mkForce "never";

  # WSL handles everything else, including hardware configuration

  #
  # Hardware
  #

  # Enable Nvidia GPU drivers
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
}
