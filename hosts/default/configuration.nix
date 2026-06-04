# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, lib, pkgs, inputs, options, customSddmTheme, probeRsRules, packages, nixosPermittedInsecurePackages, ... }:
let
  # Include the results of the hardware scan.
  hardwareConfigurationImports = [ ./hardware-configuration.nix ];
in
{
  imports = [
    ../base.nix 
    ../../modules/nvidia-drivers.nix
    ../../modules/nvidia-prime-drivers.nix
    ../../modules/intel-drivers.nix
  ] ++ hardwareConfigurationImports;

  # Bootloader.
  boot.loader.grub = {
    enable = true;
    device = "/dev/sda";
    useOSProber = true;
    efiSupport = false;
    configurationLimit = 5;
  };
  boot.loader.efi = {};

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
