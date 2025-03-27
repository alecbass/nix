# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, inputs, ... }:
let
  username = "alec";
  userDescription = "Alec Bassingthwaighte";
  homeDirectory = "/home/${username}";
  hostName = "alec";
  timeZone = "Australia/Melbourne";
in
{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
      ./user.nix
      # ../../modules/nvidia-drivers.nix
      # ../../modules/nvidia-prime-drivers.nix
      # ../../modules/intel-drivers.nix
      # inputs.home-manager.nixosModules.default
    ];

  # Bootloader.
  boot.loader.grub.enable = true;
  boot.loader.grub.device = "/dev/sda";
  boot.loader.grub.useOSProber = true;

  networking = {
    hostName = "nixos"; # Define your hostname.

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
      "8.8.8.8"
      "1.1.1.1"
      "2001:4860:4860::8888"
      "2001:4860:4860::8844"
    ];

    # Meme stuff to make DNS work on the desktop
    resolvconf.enable = pkgs.lib.mkForce false;
    dhcpcd.extraConfig = "nohook resolve.conf";
  };

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Set your time zone.
  time.timeZone = "Australia/Melbourne";

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
      displayManager = {
        gdm = {
          enable = true;
          wayland = true;
        };
      };
    };
  };

  # Configure keymap in X11
  # services.xserver = {
  #   xkb = {
  #     layout = "us";
  #     variant = "";
  #   };
  # };

  # Enable CUPS to print documents.
  services.printing.enable = true;

  # Enable sound with pipewire.
  hardware.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    # If you want to use JACK applications, uncomment this
    #jack.enable = true;

    # use the example session manager (no others are packaged yet so this is enabled by default,
    # no need to redefine it in your config for now)
    #media-session.enable = true;
  };

  # Enable touchpad support (enabled default in most desktopManager).
  # services.xserver.libinput.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.alec = {
    isNormalUser = true;
    description = "Alec Bassingthwaighte";
    extraGroups = [
      "networkmanager" # Default
      "wheel" # Default
      "docker" # Allows Docker usage
      "dialout" # Allows user to echo to /dev/ttyACM0 (and other devices) for hardware debugging
    ];
    packages = with pkgs; [
      #  thunderbird
      # Programming tools
      git
      neovim
      vim # For when neovim crashes lol
      shellcheck

      # Python
      (python313.withPackages (ps: with ps; [
        # Setup pip
        pip
        ruff
        ruff-lsp
        pyright
      ]))

      # Rust
      cargo
      rustc
      rustup

      # JavaScript/TypeScript
      nodejs_22
      corepack_22

      # Go
      go

      # C/C++
      clang-tools
      libclang
      libcxx
      glibc
      libgcc
      cmake
      # bear # Remove?

      # Debugging
      gdb

      # Docker
      # docker
      # podman
      # podman-tui

      # Databases
      pgadmin4
      dbeaver-bin

      # Browsers
      google-chrome

      # Socials
      discord
      slack
      teams-for-linux
      yt-dlp

      # Editing
      gimp-with-plugins
      ffmpeg

      # VPN
      pritunl-client

      # Device Management
      gparted

      # Streaming
      stremio

      # Other utilities
      unzip
      postman
      thonny # For MicroPython

      # Powercor-specific
      stoken
      citrix_workspace
   ];
  };

  # Install firefox.
  programs.firefox.enable = true;

  # Enable Hyprland
  programs.hyprland = {
    enable = true;
    xwayland.enable = true;
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
      enable = false;
    };

    docker = {
      enable = false;
    };

    podman = {
      enable = false;

      # Create a `docker` alias for podman, to use it as a drop-in replacement
      dockerCompat = true;

      # True to let pod-compose containers talk to each other
      defaultNetwork.settings.dns_enabled = true;
    };
  };

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    #  vim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
    #  wget
    libgcc
    libcxx
    gcc
    gnumake
    clang
    libclang
    glibc
    glibcInfo

    # Needed for Rust compilation
    openssl
    pkg-config
    libiconv

    # Terminal
    ghostty
    kitty # For Hyprland
  ];

  #
  # Fonts
  #

  fonts.packages = with pkgs; [ 
    nerdfonts

    # NOTE: When updating to nixOS 25.05, nerdfonts will be replaced with nerd-fonts
    # nerd-fonts._3270
    # nerd-fonts.agave
    # nerd-fonts.anonymice
    # nerd-fonts.arimo
    # nerd-fonts.aurulent-sans-mono
    # nerd-fonts.bigblue-terminal
    # nerd-fonts.bitstream-vera-sans-mono
    # nerd-fonts.blex-mono
    # nerd-fonts.caskaydia-cove
    # nerd-fonts.caskaydia-mono
    # nerd-fonts.code-new-roman
    # nerd-fonts.comic-shanns-mono
    # nerd-fonts.commit-mono
    # nerd-fonts.cousine
    # nerd-fonts.d2coding
    # nerd-fonts.daddy-time-mono
    # nerd-fonts.departure-mono
    # nerd-fonts.dejavu-sans-mono
    # nerd-fonts.droid-sans-mono
    # nerd-fonts.envy-code-r
    # nerd-fonts.fantasque-sans-mono
    # nerd-fonts.fira-code
    # nerd-fonts.fira-mono
    # nerd-fonts.geist-mono
    # nerd-fonts.go-mono
    # nerd-fonts.gohufont
    # nerd-fonts.hack
    # nerd-fonts.hasklug
    # nerd-fonts.heavy-data
    # nerd-fonts.hurmit
    # nerd-fonts.im-writing
    # nerd-fonts.inconsolata
    # nerd-fonts.inconsolata-go
    # nerd-fonts.inconsolata-lgc
    # nerd-fonts.intone-mono
    # nerd-fonts.iosevka
    # nerd-fonts.iosevka-term
    # nerd-fonts.iosevka-term-slab
    # nerd-fonts.jetbrains-mono
    # nerd-fonts.lekton
    # nerd-fonts.liberation
    # nerd-fonts.lilex
    # nerd-fonts.martian-mono
    # nerd-fonts.meslo-lg
    # nerd-fonts.monaspace
    # nerd-fonts.monofur
    # nerd-fonts.monoid
    # nerd-fonts.mononoki
    # nerd-fonts.mplus
    # nerd-fonts.noto
    # nerd-fonts.open-dyslexic
    # nerd-fonts.overpass
    # nerd-fonts.profont
    # nerd-fonts.proggy-clean-tt
    # nerd-fonts.recursive-mono
    # nerd-fonts.roboto-mono
    # nerd-fonts.shure-tech-mono
    # nerd-fonts.sauce-code-pro
    # nerd-fonts.space-mono
    # nerd-fonts.symbols-only
    # nerd-fonts.terminess-ttf
    # nerd-fonts.tinos
    # nerd-fonts.ubuntu
    # nerd-fonts.ubuntu-mono
    # nerd-fonts.ubuntu-sans
    # nerd-fonts.victor-mono
    # nerd-fonts.zed-mono
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
    };
    graphics = {
      enable = true;
    };
  };

  # xdg.portal = {
  #   enable = true;
  #   wlr.enable = true;
  #   extraPortals = [
  #     pkgs.xdg-desktop-portal-gtk
  #     pkgs.xdg-desktop-portal
  #   ];
  #   configPackages = [
  #     pkgs.xdg-desktop-portal-gtk
  #     pkgs.xdg-desktop-portal-hyprland
  #     pkgs.xdg-desktop-portal
  #   ];
  # };
 

  #
  # Home Manager
  #

  # home-manager = {
  #   extraSpecialArgs = { inherit inputs; };
  #   users.${username} = import ./home.nix;
  #   useGlobalPkgs = true;
  #   useUserPackages = true;
  #   backupFileExtension = "backup";
  # };

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
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
}
