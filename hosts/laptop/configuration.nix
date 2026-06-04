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
    device = "nodev";
    useOSProber = true;
    efiSupport = true;
    configurationLimit = 5;
  };
  boot.loader.efi = {
    canTouchEfiVariables = true;
    efiSysMountPoint = "/boot";
  };
  # Detect inbuild microphone
  boot.extraModprobeConfig = "
options snd-hda-intel model=dell-headset-multi
options snd-hda-intel model=headset-mic
  ";

  # Laptop DNS
  networking.nameservers = [
    "8.8.8.8"
    "1.1.1.1"
    "2001:4860:4860::8888"
    "2001:4860:4860::8844"
  ];

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
    bluetooth = {
      enable = true;
      powerOnBoot = false;
      settings = {
        General = {
          Experimental = false; # Don't show battery charge of Bluetooth devices
        };
        Policy = {
          AutoEnable = true;
        };
      };
    };
  };
}
