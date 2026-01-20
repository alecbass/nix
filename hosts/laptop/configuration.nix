# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, lib, pkgs, inputs, options, customSddmTheme, probeRsRules, packages, ... }:
let
  username = "alec";
  userDescription = "Alec Bassingthwaighte";
  homeDirectory = "/home/${username}";
  hostName = "nixos";
  timeZone = "Australia/Brisbane";

  # TODO: It would be nice to have this called in the flake, but we don't have access to `pkgs` there
  minecraft = pkgs.callPackage ../../modules/minecraft.nix { };

  hardwareConfigurationImports = [ ./hardware-configuration.nix ];
in
{
  imports = [
      ./user.nix
      ../../modules/nvidia-drivers.nix
      ../../modules/nvidia-prime-drivers.nix
      ../../modules/intel-drivers.nix
      inputs.home-manager.nixosModules.default
    ] ++ hardwareConfigurationImports; # Include the results of the hardware scan.

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

  networking = {
    hostName = "${hostName}"; # Define your hostname.

    networkmanager = {
      # Enable networking
      enable = true;

      # Meme stuff to make DNS work on the desktop
      dns = "none";
    };

    wireless = {
      # Enables wireless support via wpa_supplicant.
      enable = false; # Clashes with networkmanager
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
  };

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Set your time zone.
  time.timeZone = timeZone;

  # Select internationalisation properties.
  i18n.defaultLocale = "en_AU.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "en_AU.UTF-8";
    LC_IDENTIFICATION = "en_AU.UTF-8";
    LC_MEASUREMENT = "en_AU.UTF-8";
    LC_MONETARY = "en_AU.UTF-8";
    LC_NAME = "en_AU.UTF-8";
    LC_NUMERIC = "en_AU.UTF-8";
    LC_PAPER = "en_AU.UTF-8";
    LC_TELEPHONE = "en_AU.UTF-8";
    LC_TIME = "en_AU.UTF-8";
  };

  stylix = {
    enable = true;
    base16Scheme = {
      base00 = "191724";
      base01 = "1f1d2e";
      base02 = "26233a";
      base03 = "6e6a86";
      base04 = "908caa";
      base05 = "e0def4";
      base06 = "e0def4";
      base07 = "524f67";
      base08 = "eb6f92";
      base09 = "f6c177";
      base0A = "ebbcba";
      base0B = "31748f";
      base0C = "9ccfd8";
      base0D = "c4a7e7";
      base0E = "f6c177";
      base0F = "524f67";
    };
    image = ../../config/assets/wall.png;
    polarity = "dark";
    opacity.terminal = 0.8;
    cursor.package = pkgs.bibata-cursors;
    cursor.name = "Bibata-Modern-Ice";
    cursor.size = 24;
    fonts = {
      # monospace = {
      #   package = pkgs.nerd-fonts.jetbrains-mono;
      #   name = "JetBrainsMono Nerd Font Mono";
      # };
      sansSerif = {
        package = pkgs.montserrat;
        name = "Montserrat";
      };
      serif = {
        package = pkgs.montserrat;
        name = "Montserrat";
      };
      sizes = {
        applications = 12;
        terminal = 15;
        desktop = 11;
        popups = 12;
      };
    };
  };

  # Enable the X11 windowing system.
  # services.xserver.enable = true;

  # Enable the GNOME Desktop Environment.
  # services.xserver.displayManager.gdm.enable = true;
  # services.xserver.desktopManager.gnome.enable = true;

  # Enable Wayland - https://github.com/dc-tec/nixos-config/blob/main/modules%2Fgraphical%2Fdesktop%2Fhyprland%2Fdefault.nix

  services = {
    xserver = {
      enable = true;
      videoDrivers = [ "nvidia" ];
    };
    displayManager = {
      gdm = {
        enable = true;
        wayland = true;
      };
    };
    # Enable CUPS to print documents.
    printing.enable = true;
    pipewire = {
      enable = true;
      alsa = {
        enable = true;
        support32Bit = true;
      };
      pulse.enable = true;
      jack.enable = true;
      wireplumber.enable = true;

      # use the example session manager (no others are packaged yet so this is enabled by default,
      # no need to redefine it in your config for now)
      #media-session.enable = true;
    };
    pulseaudio.enable = false;
  };

  security.rtkit.enable = true;

  systemd.services = {
    flatpak-repo = {
      path = [ pkgs.flatpak ];
      script = "flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo";
    };
    libvirtd = {
      enable = true;
      wantedBy = [ "multi-user.target" ];
      requires = [ "virtlogd.service" ];
    };
    fix-wifi = {
      enable = true;
      description = "Restarts the user wifi in case it failed to launch on Linux";
      wantedBy = [ "multi-user.target" ]; # Starts after login
      path = packages.nixosOnlyDeps ++ [ pkgs.kmod ]; # Required dependencies: modprobe (through kmod) and the fix-wifi script

      script = ''
        set -euxo pipefail
        fix-wifi
        echo "Restarted Wifi"
      '';

      # Run the script once as sudo after login
      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = false;
        User = "root"; # The script needs to run as sudo
        Group = "root";
      };
    };
  };

  systemd.user.services = {
    change-wallpaper = {
      enable = true;
      description = "Sets a Hyprpaper wallpaper at launch";
      serviceConfig.PassEnvironment = "DISPLAY";
      script = ''
        change-wallpaper
      '';
      wantedBy = [ "multi-user.target" ]; # starts after login
    };
  };

  # Enable touchpad support (enabled default in most desktopManager).
  # services.xserver.libinput.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.${username} = {
    isNormalUser = true;
    description = "Alec Bassingthwaighte";
    extraGroups = [
      "networkmanager" # Default
      "wheel" # Default
      "docker" # Allows Docker usage
      "dialout" # Allows user to echo to /dev/ttyACM0 (and other devices) for hardware debugging
      "plugdev" # Allows user to access USB devices, see custom udev rules below
    ];
    packages = packages.userPackages ++ [ minecraft ];
  };

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
  };

  # Enable Steam - gamingggggg
  programs.steam = {
    enable = true;
    remotePlay.openFirewall = false; # Ports in the firewall for Steam Remote Play
    dedicatedServer.openFirewall = false; # Ports in the firewall for Steam Dedicated Server
  };

  environment.sessionVariables = {
    # If your cursor becomes invisible
    WLR_NO_HARDWARE_CURSORS = "1";
    # Hint electron apps to use wayland
    NIXOS_OZONE_WL = "1";
  };


  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # Virtualisation for Docker and Podman

  virtualisation = {
    containers = {
      enable = true;
    };

    docker = {
      enable = true;
    };

    podman = {
      enable = true;

      # Create a `docker` alias for podman, to use it as a drop-in replacement
      dockerCompat = false;

      # True to let pod-compose containers talk to each other
      defaultNetwork.settings.dns_enabled = true;
    };
  };

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = packages.nixosOnlyDeps ++ packages.systemPackages ++ packages.hyprlandPackages ++ [
    inputs.hyprpanel.packages.${pkgs.system}.default # Used instead of an overlay
    # customSddmTheme
  ];

  #
  # Fonts
  #

  fonts.packages = with pkgs; [ 
    nerd-fonts._3270
    nerd-fonts.agave
    nerd-fonts.anonymice
    nerd-fonts.arimo
    nerd-fonts.aurulent-sans-mono
    nerd-fonts.bigblue-terminal
    nerd-fonts.bitstream-vera-sans-mono
    nerd-fonts.blex-mono
    nerd-fonts.caskaydia-cove
    nerd-fonts.caskaydia-mono
    nerd-fonts.code-new-roman
    nerd-fonts.comic-shanns-mono
    nerd-fonts.commit-mono
    nerd-fonts.cousine
    nerd-fonts.d2coding
    nerd-fonts.daddy-time-mono
    nerd-fonts.departure-mono
    nerd-fonts.dejavu-sans-mono
    nerd-fonts.droid-sans-mono
    nerd-fonts.envy-code-r
    nerd-fonts.fantasque-sans-mono
    nerd-fonts.fira-code
    nerd-fonts.fira-mono
    nerd-fonts.geist-mono
    nerd-fonts.go-mono
    nerd-fonts.gohufont
    nerd-fonts.hack
    nerd-fonts.hasklug
    nerd-fonts.heavy-data
    nerd-fonts.hurmit
    nerd-fonts.im-writing
    nerd-fonts.inconsolata
    nerd-fonts.inconsolata-go
    nerd-fonts.inconsolata-lgc
    nerd-fonts.intone-mono
    nerd-fonts.iosevka
    nerd-fonts.iosevka-term
    nerd-fonts.iosevka-term-slab
    nerd-fonts.jetbrains-mono
    nerd-fonts.lekton
    nerd-fonts.liberation
    nerd-fonts.lilex
    nerd-fonts.martian-mono
    nerd-fonts.meslo-lg
    nerd-fonts.monaspace
    nerd-fonts.monofur
    nerd-fonts.monoid
    nerd-fonts.mononoki
    # nerd-fonts.mplus
    nerd-fonts.noto
    nerd-fonts.open-dyslexic
    nerd-fonts.overpass
    nerd-fonts.profont
    nerd-fonts.proggy-clean-tt
    nerd-fonts.recursive-mono
    nerd-fonts.roboto-mono
    nerd-fonts.shure-tech-mono
    nerd-fonts.sauce-code-pro
    nerd-fonts.space-mono
    nerd-fonts.symbols-only
    nerd-fonts.terminess-ttf
    nerd-fonts.tinos
    nerd-fonts.ubuntu
    nerd-fonts.ubuntu-mono
    nerd-fonts.ubuntu-sans
    nerd-fonts.victor-mono
    nerd-fonts.zed-mono
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

  xdg.portal = {
    enable = true;
    wlr.enable = true;
    extraPortals = [
      pkgs.xdg-desktop-portal-gtk
      pkgs.xdg-desktop-portal
    ];
    configPackages = [
      pkgs.xdg-desktop-portal-gtk
      pkgs.xdg-desktop-portal-hyprland
      pkgs.xdg-desktop-portal
    ];
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

  #
  # Udev rule overwrites
  #
  # Allow rs-probe access
  services.udev.extraRules = probeRsRules;

  # Allow USBs to be mounted
  services.udisks2.enable = true;

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
  nixpkgs.config.permittedInsecurePackages = [
    "broadcom-sta-6.30.223.271-59-6.12.65"
  ];
}
