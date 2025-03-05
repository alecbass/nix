# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
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

  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Set your time zone.
  time.timeZone = "Australia/Melbourne";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_GB.UTF-8";

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
  services.xserver.enable = true;

  # Enable the GNOME Desktop Environment.
  services.xserver.displayManager.gdm.enable = true;
  services.xserver.desktopManager.gnome.enable = true;

  # Configure keymap in X11
  services.xserver = {
    xkb = {
      layout = "us";
      variant = "";
    };
  };

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
	    # virtualenvwrapper
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
      docker
      podman
      podman-tui

      # Databases
      pgadmin4
      dbeaver-bin
      neo4j

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
    ];
  };

  # Install firefox.
  programs.firefox.enable = true;

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
  ];

  #
  # Fonts
  #

  fonts.packages = with pkgs; [ nerdfonts ];

  #
  # Hardware
  #

  # Enable Nvidia GPU drivers
  hardware.nvidia.package = config.boot.kernelPackages.nvidiaPackages.stable;
  hardware.nvidia.open = true;
  hardware.graphics.enable = true;
  services.xserver.videoDrivers = [ "nvidia" ];


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
