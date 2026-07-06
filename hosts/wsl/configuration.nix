# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, nixos-wsl, packages, ... }:
let
  user = import ../user.nix { inherit packages; };
in
{
  imports = [
    nixos-wsl.nixosModules.default
    ../base.nix
    ../../modules/nvidia-drivers.nix
    ../../modules/nvidia-prime-drivers.nix
    ../../modules/intel-drivers.nix
  ];
  # ++ hardwareConfigurationImports;

  wsl = {
    enable = true;
    defaultUser = user.userName; # Set your primary login username - from user.nix
    
    # Optional: Integrate Windows PATH into Linux
    wslConf.interop.appendWindowsPath = true; 
  };

  # WSL handles everything else, including hardware configuration
  networking = {}; # Let Windows handle the networking

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
