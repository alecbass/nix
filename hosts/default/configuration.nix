# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, lib, pkgs, inputs, options, customSddmTheme, probeRsRules, packages, nixosPermittedInsecurePackages, ... }:
let
  username = "alec";
  userDescription = "Alec Bassingthwaighte";
  homeDirectory = "/home/${username}";
  hostName = "nixos";

  # TODO: It would be nice to have this called in the flake, but we don't have access to `pkgs` there
  minecraft = pkgs.callPackage ../../modules/minecraft.nix { };

  i18n = (import ../i18n.nix { });
  networking = (import ../networking.nix { inherit config pkgs; });
  time = (import ../time.nix { });
  stylix = (import ../stylix.nix { inherit pkgs; });
  services = (import ../services.nix { inherit probeRsRules; });
  security = (import ../security.nix { });
  systemd = (import ../systemd.nix { inherit pkgs packages; });
  programs = (import ../programs.nix { });
  environment = (import ../environment.nix { inherit pkgs packages inputs; });
  virtualisation = (import ../virtualisation.nix { });
  fonts = (import ../fonts.nix { inherit pkgs; });
  xdg = (import ../xdg.nix { inherit pkgs; });
  user = (import ../user.nix { inherit packages; });

  hardwareConfigurationImports = [ ./hardware-configuration.nix ];
in
{
  # TODO(alec): Import here rather than in the let declaration maybe?
  imports = [
    ../user.nix
    ../../modules/nvidia-drivers.nix
    ../../modules/nvidia-prime-drivers.nix
    ../../modules/intel-drivers.nix
    inputs.home-manager.nixosModules.default
  ] ++ hardwareConfigurationImports; # Include the results of the hardware scan.

  # Bootloader.
  boot.loader.grub = {
    enable = true;
    device = "/dev/sda";
    useOSProber = true;
    efiSupport = false;
    configurationLimit = 5;
  };
  boot.loader.efi = {};

  networking = networking.networking;
  i18n = i18n.i18n;
  time = time.time;
  stylix = stylix.stylix;
  services = services.services;
  security = security.security;
  systemd = systemd.systemd;
  programs = programs.programs;
  environment = environment.environment;
  virtualisation = virtualisation.virtualisation;
  fonts = fonts.fonts;
  xdg = xdg.xdg;
  users = user.users;

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";


  # Enable touchpad support (enabled default in most desktopManager).
  # services.xserver.libinput.enable = true;


  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

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

  #
  # Home Manager
  #

  home-manager = {
    extraSpecialArgs = { inherit inputs; };
    users.${username} = import ./home.nix;
    useGlobalPkgs = false;
    useUserPackages = true;
    backupFileExtension = "backup";
  };

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;configurati
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "24.11"; # Did you read the comment?

  #
  # Nix overrides
  #
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  #
  # Packages to explicitly allow
  #
  nixpkgs.config.permittedInsecurePackages = nixosPermittedInsecurePackages;
}
