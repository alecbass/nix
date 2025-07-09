# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, lib, pkgs, inputs, options, ... }:
let
  username = "alec";
  userDescription = "Alec Bassingthwaighte";
  homeDirectory = "/home/${username}";
  hostName = "nixos";
  timeZone = "Australia/Melbourne";
in
{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
      ./user.nix
      ../../modules/nvidia-drivers.nix
      ../../modules/nvidia-prime-drivers.nix
      ../../modules/intel-drivers.nix
      inputs.home-manager.nixosModules.default
    ];

  # Bootloader.
  boot.loader.grub.enable = true;
  boot.loader.grub.device = "/dev/sda";
  boot.loader.grub.useOSProber = true;

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
      displayManager = {
        gdm = {
          enable = true;
          wayland = true;
        };
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
    # Enable sound with pipewire.
    pulseaudio.enable = false;
  };

  security.rtkit.enable = true;

  systemd.services = {
    # onedrive = {
    #   description = "Onedrive Sync Service";
    #   after = [ "network-online.target" ];
    #   wantedBy = [ "multi-user.target" ];
    #   serviceConfig = {
    #     Type = "simple";
    #     User = username;
    #     ExecStart = "${pkgs.onedrive}/bin/onedrive --monitor";
    #     Restart = "always";
    #     RestartSec = 10;
    #   };
    # };
    flatpak-repo = {
      path = [ pkgs.flatpak ];
      script = "flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo";
    };
    libvirtd = {
      enable = true;
      wantedBy = [ "multi-user.target" ];
      requires = [ "virtlogd.service" ];
    };
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
      lua-language-server

      # Python
      (python314.withPackages (ps: with ps; [
        # Setup pip
        # pip - pip3.12 uses a C recursion symbol which Python 3.14 has since removed
        ruff
        pyright
      ]))

      # Rust
      cargo
      rustc
      rustup

      # JavaScript/TypeScript
      nodejs_24
      corepack_24

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
      jellyfin # Video streaming service

      # Other utilities
      unzip
      # postman Currently not able to download on nixpkgs 25.05
      thonny # For MicroPython

      # Powercor-specific
      stoken
      citrix_workspace

      # Games
      # inputs.minecraft # TODO: Re-add
   ];
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

    # Linux utils
    htop # Process viewer
    neofetch # Basic details
    inetutils # Network utilities such as telnet
    usbutils # Unsurprisingly, USB utilities

    # Editing
    # dotnetCorePackages.sdk_9_0
    vscode # To use while razor LSPs don't really work
    (vscode-with-extensions.override {
      vscodeExtensions = with vscode-extensions; [
        bbenoist.nix
        ms-python.python
        ms-azuretools.vscode-docker
        ms-vscode-remote.remote-ssh
        ms-dotnettools.csharp
        ms-dotnettools.csdevkit
        ms-dotnettools.vscodeintellicode-csharp
        ms-dotnettools.vscode-dotnet-runtime
      ] ++ pkgs.vscode-utils.extensionsFromVscodeMarketplace [
        {
          name = "remote-ssh-edit";
          publisher = "ms-vscode-remote";
          version = "0.47.2";
          sha256 = "1hp6gjh4xp2m1xlm1jsdzxw9d8frkiidhph6nvl24d0h8z34w49g";
        }
      ];
    })

    # Wayland-specific
    hyprshot
    hypridle
    grim
    slurp
    waybar
    inputs.hyprpanel.packages.${pkgs.system}.default # Used instead of an overlay
    dunst
    wl-clipboard
    swaynotificationcenter

    # Networking
    networkmanagerapplet

    # Self-hosting
    k3s

    # Miscellaneous
    greetd.tuigreet
    customSddmTheme
    libsForQt5.qt5.qtgraphicaleffects
    kdePackages.dolphin
    kdePackages.kio
    kdePackages.kio-extras
    kdePackages.breeze-icons
    kdePackages.dolphin-plugins
    kdePackages.kdesdk-thumbnailers
    kdePackages.kdegraphics-thumbnailers
    kdePackages.kdegraphics-mobipocket
    kdePackages.kimageformats
    kdePackages.calligra
    kdePackages.qtimageformats
    kdePackages.ffmpegthumbs
    kdePackages.taglib
    kdePackages.baloo
    kdePackages.baloo-widgets
    kdePackages.qtsvg # To make file icons appear in Dolphin
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
    };
    graphics = {
      enable = true;
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

  services.udev.extraRules = ''
    # Probe-rs
	# Copy this file to /etc/udev/rules.d/
	# If rules fail to reload automatically, you can refresh udev rules
	# with the command "udevadm control --reload"

	# This rules are based on the udev rules from the OpenOCD project, with unsupported probes removed.
	# See http://openocd.org/ for more details.
	#
	# This file is available under the GNU General Public License v2.0

	ACTION!="add|change", GOTO="probe_rs_rules_end"

	SUBSYSTEM=="gpio", MODE="0660", GROUP="plugdev", TAG+="uaccess"

	SUBSYSTEM!="usb|tty|hidraw", GOTO="probe_rs_rules_end"

	# Please keep this list sorted by VID:PID

	# STMicroelectronics ST-LINK V1
	ATTRS{idVendor}=="0483", ATTRS{idProduct}=="3744", MODE="660", GROUP="plugdev", TAG+="uaccess"

	# STMicroelectronics ST-LINK/V2
	ATTRS{idVendor}=="0483", ATTRS{idProduct}=="3748", MODE="660", GROUP="plugdev", TAG+="uaccess"

	# STMicroelectronics ST-LINK/V2.1
	ATTRS{idVendor}=="0483", ATTRS{idProduct}=="374b", MODE="660", GROUP="plugdev", TAG+="uaccess"
	ATTRS{idVendor}=="0483", ATTRS{idProduct}=="3752", MODE="660", GROUP="plugdev", TAG+="uaccess"

	# STMicroelectronics STLINK-V3
	ATTRS{idVendor}=="0483", ATTRS{idProduct}=="374d", MODE="660", GROUP="plugdev", TAG+="uaccess"
	ATTRS{idVendor}=="0483", ATTRS{idProduct}=="374e", MODE="660", GROUP="plugdev", TAG+="uaccess"
	ATTRS{idVendor}=="0483", ATTRS{idProduct}=="374f", MODE="660", GROUP="plugdev", TAG+="uaccess"
	ATTRS{idVendor}=="0483", ATTRS{idProduct}=="3753", MODE="660", GROUP="plugdev", TAG+="uaccess"
	ATTRS{idVendor}=="0483", ATTRS{idProduct}=="3754", MODE="660", GROUP="plugdev", TAG+="uaccess"

	# SEGGER J-Link
	ATTRS{idVendor}=="1366", ATTRS{idProduct}=="0101", MODE="660", GROUP="plugdev", TAG+="uaccess"
	ATTRS{idVendor}=="1366", ATTRS{idProduct}=="0102", MODE="660", GROUP="plugdev", TAG+="uaccess"
	ATTRS{idVendor}=="1366", ATTRS{idProduct}=="0103", MODE="660", GROUP="plugdev", TAG+="uaccess"
	ATTRS{idVendor}=="1366", ATTRS{idProduct}=="0104", MODE="660", GROUP="plugdev", TAG+="uaccess"
	ATTRS{idVendor}=="1366", ATTRS{idProduct}=="0105", MODE="660", GROUP="plugdev", TAG+="uaccess"
	ATTRS{idVendor}=="1366", ATTRS{idProduct}=="0107", MODE="660", GROUP="plugdev", TAG+="uaccess"
	ATTRS{idVendor}=="1366", ATTRS{idProduct}=="0108", MODE="660", GROUP="plugdev", TAG+="uaccess"
	ATTRS{idVendor}=="1366", ATTRS{idProduct}=="1001", MODE="660", GROUP="plugdev", TAG+="uaccess"
	ATTRS{idVendor}=="1366", ATTRS{idProduct}=="1002", MODE="660", GROUP="plugdev", TAG+="uaccess"
	ATTRS{idVendor}=="1366", ATTRS{idProduct}=="1003", MODE="660", GROUP="plugdev", TAG+="uaccess"
	ATTRS{idVendor}=="1366", ATTRS{idProduct}=="1004", MODE="660", GROUP="plugdev", TAG+="uaccess"
	ATTRS{idVendor}=="1366", ATTRS{idProduct}=="1005", MODE="660", GROUP="plugdev", TAG+="uaccess"
	ATTRS{idVendor}=="1366", ATTRS{idProduct}=="1006", MODE="660", GROUP="plugdev", TAG+="uaccess"
	ATTRS{idVendor}=="1366", ATTRS{idProduct}=="1007", MODE="660", GROUP="plugdev", TAG+="uaccess"
	ATTRS{idVendor}=="1366", ATTRS{idProduct}=="1008", MODE="660", GROUP="plugdev", TAG+="uaccess"
	ATTRS{idVendor}=="1366", ATTRS{idProduct}=="1009", MODE="660", GROUP="plugdev", TAG+="uaccess"
	ATTRS{idVendor}=="1366", ATTRS{idProduct}=="100a", MODE="660", GROUP="plugdev", TAG+="uaccess"
	ATTRS{idVendor}=="1366", ATTRS{idProduct}=="100b", MODE="660", GROUP="plugdev", TAG+="uaccess"
	ATTRS{idVendor}=="1366", ATTRS{idProduct}=="100c", MODE="660", GROUP="plugdev", TAG+="uaccess"
	ATTRS{idVendor}=="1366", ATTRS{idProduct}=="100d", MODE="660", GROUP="plugdev", TAG+="uaccess"
	ATTRS{idVendor}=="1366", ATTRS{idProduct}=="100e", MODE="660", GROUP="plugdev", TAG+="uaccess"
	ATTRS{idVendor}=="1366", ATTRS{idProduct}=="100f", MODE="660", GROUP="plugdev", TAG+="uaccess"
	ATTRS{idVendor}=="1366", ATTRS{idProduct}=="1010", MODE="660", GROUP="plugdev", TAG+="uaccess"
	ATTRS{idVendor}=="1366", ATTRS{idProduct}=="1011", MODE="660", GROUP="plugdev", TAG+="uaccess"
	ATTRS{idVendor}=="1366", ATTRS{idProduct}=="1012", MODE="660", GROUP="plugdev", TAG+="uaccess"
	ATTRS{idVendor}=="1366", ATTRS{idProduct}=="1013", MODE="660", GROUP="plugdev", TAG+="uaccess"
	ATTRS{idVendor}=="1366", ATTRS{idProduct}=="1014", MODE="660", GROUP="plugdev", TAG+="uaccess"
	ATTRS{idVendor}=="1366", ATTRS{idProduct}=="1015", MODE="660", GROUP="plugdev", TAG+="uaccess"
	ATTRS{idVendor}=="1366", ATTRS{idProduct}=="1016", MODE="660", GROUP="plugdev", TAG+="uaccess"
	ATTRS{idVendor}=="1366", ATTRS{idProduct}=="1017", MODE="660", GROUP="plugdev", TAG+="uaccess"
	ATTRS{idVendor}=="1366", ATTRS{idProduct}=="1018", MODE="660", GROUP="plugdev", TAG+="uaccess"
	ATTRS{idVendor}=="1366", ATTRS{idProduct}=="1019", MODE="660", GROUP="plugdev", TAG+="uaccess"
	ATTRS{idVendor}=="1366", ATTRS{idProduct}=="101a", MODE="660", GROUP="plugdev", TAG+="uaccess"
	ATTRS{idVendor}=="1366", ATTRS{idProduct}=="101b", MODE="660", GROUP="plugdev", TAG+="uaccess"
	ATTRS{idVendor}=="1366", ATTRS{idProduct}=="101c", MODE="660", GROUP="plugdev", TAG+="uaccess"
	ATTRS{idVendor}=="1366", ATTRS{idProduct}=="101d", MODE="660", GROUP="plugdev", TAG+="uaccess"
	ATTRS{idVendor}=="1366", ATTRS{idProduct}=="101e", MODE="660", GROUP="plugdev", TAG+="uaccess"
	ATTRS{idVendor}=="1366", ATTRS{idProduct}=="101f", MODE="660", GROUP="plugdev", TAG+="uaccess"
	ATTRS{idVendor}=="1366", ATTRS{idProduct}=="1020", MODE="660", GROUP="plugdev", TAG+="uaccess"
	ATTRS{idVendor}=="1366", ATTRS{idProduct}=="1021", MODE="660", GROUP="plugdev", TAG+="uaccess"
	ATTRS{idVendor}=="1366", ATTRS{idProduct}=="1022", MODE="660", GROUP="plugdev", TAG+="uaccess"
	ATTRS{idVendor}=="1366", ATTRS{idProduct}=="1023", MODE="660", GROUP="plugdev", TAG+="uaccess"
	ATTRS{idVendor}=="1366", ATTRS{idProduct}=="1024", MODE="660", GROUP="plugdev", TAG+="uaccess"
	ATTRS{idVendor}=="1366", ATTRS{idProduct}=="1025", MODE="660", GROUP="plugdev", TAG+="uaccess"
	ATTRS{idVendor}=="1366", ATTRS{idProduct}=="1026", MODE="660", GROUP="plugdev", TAG+="uaccess"
	ATTRS{idVendor}=="1366", ATTRS{idProduct}=="1027", MODE="660", GROUP="plugdev", TAG+="uaccess"
	ATTRS{idVendor}=="1366", ATTRS{idProduct}=="1028", MODE="660", GROUP="plugdev", TAG+="uaccess"
	ATTRS{idVendor}=="1366", ATTRS{idProduct}=="1029", MODE="660", GROUP="plugdev", TAG+="uaccess"
	ATTRS{idVendor}=="1366", ATTRS{idProduct}=="102a", MODE="660", GROUP="plugdev", TAG+="uaccess"
	ATTRS{idVendor}=="1366", ATTRS{idProduct}=="102b", MODE="660", GROUP="plugdev", TAG+="uaccess"
	ATTRS{idVendor}=="1366", ATTRS{idProduct}=="102c", MODE="660", GROUP="plugdev", TAG+="uaccess"
	ATTRS{idVendor}=="1366", ATTRS{idProduct}=="102d", MODE="660", GROUP="plugdev", TAG+="uaccess"
	ATTRS{idVendor}=="1366", ATTRS{idProduct}=="102e", MODE="660", GROUP="plugdev", TAG+="uaccess"
	ATTRS{idVendor}=="1366", ATTRS{idProduct}=="102f", MODE="660", GROUP="plugdev", TAG+="uaccess"
	ATTRS{idVendor}=="1366", ATTRS{idProduct}=="1050", MODE="660", GROUP="plugdev", TAG+="uaccess"
	ATTRS{idVendor}=="1366", ATTRS{idProduct}=="1051", MODE="660", GROUP="plugdev", TAG+="uaccess"
	ATTRS{idVendor}=="1366", ATTRS{idProduct}=="1052", MODE="660", GROUP="plugdev", TAG+="uaccess"
	ATTRS{idVendor}=="1366", ATTRS{idProduct}=="1053", MODE="660", GROUP="plugdev", TAG+="uaccess"
	ATTRS{idVendor}=="1366", ATTRS{idProduct}=="1054", MODE="660", GROUP="plugdev", TAG+="uaccess"
	ATTRS{idVendor}=="1366", ATTRS{idProduct}=="1055", MODE="660", GROUP="plugdev", TAG+="uaccess"
	ATTRS{idVendor}=="1366", ATTRS{idProduct}=="1056", MODE="660", GROUP="plugdev", TAG+="uaccess"
	ATTRS{idVendor}=="1366", ATTRS{idProduct}=="1057", MODE="660", GROUP="plugdev", TAG+="uaccess"
	ATTRS{idVendor}=="1366", ATTRS{idProduct}=="1058", MODE="660", GROUP="plugdev", TAG+="uaccess"
	ATTRS{idVendor}=="1366", ATTRS{idProduct}=="1059", MODE="660", GROUP="plugdev", TAG+="uaccess"
	ATTRS{idVendor}=="1366", ATTRS{idProduct}=="105a", MODE="660", GROUP="plugdev", TAG+="uaccess"
	ATTRS{idVendor}=="1366", ATTRS{idProduct}=="105b", MODE="660", GROUP="plugdev", TAG+="uaccess"
	ATTRS{idVendor}=="1366", ATTRS{idProduct}=="105c", MODE="660", GROUP="plugdev", TAG+="uaccess"
	ATTRS{idVendor}=="1366", ATTRS{idProduct}=="105d", MODE="660", GROUP="plugdev", TAG+="uaccess"
	ATTRS{idVendor}=="1366", ATTRS{idProduct}=="105e", MODE="660", GROUP="plugdev", TAG+="uaccess"
	ATTRS{idVendor}=="1366", ATTRS{idProduct}=="105f", MODE="660", GROUP="plugdev", TAG+="uaccess"
	ATTRS{idVendor}=="1366", ATTRS{idProduct}=="1060", MODE="660", GROUP="plugdev", TAG+="uaccess"
	ATTRS{idVendor}=="1366", ATTRS{idProduct}=="1061", MODE="660", GROUP="plugdev", TAG+="uaccess"
	ATTRS{idVendor}=="1366", ATTRS{idProduct}=="1062", MODE="660", GROUP="plugdev", TAG+="uaccess"
	ATTRS{idVendor}=="1366", ATTRS{idProduct}=="1063", MODE="660", GROUP="plugdev", TAG+="uaccess"
	ATTRS{idVendor}=="1366", ATTRS{idProduct}=="1064", MODE="660", GROUP="plugdev", TAG+="uaccess"
	ATTRS{idVendor}=="1366", ATTRS{idProduct}=="1065", MODE="660", GROUP="plugdev", TAG+="uaccess"
	ATTRS{idVendor}=="1366", ATTRS{idProduct}=="1066", MODE="660", GROUP="plugdev", TAG+="uaccess"
	ATTRS{idVendor}=="1366", ATTRS{idProduct}=="1067", MODE="660", GROUP="plugdev", TAG+="uaccess"
	ATTRS{idVendor}=="1366", ATTRS{idProduct}=="1068", MODE="660", GROUP="plugdev", TAG+="uaccess"
	ATTRS{idVendor}=="1366", ATTRS{idProduct}=="1069", MODE="660", GROUP="plugdev", TAG+="uaccess"
	ATTRS{idVendor}=="1366", ATTRS{idProduct}=="106a", MODE="660", GROUP="plugdev", TAG+="uaccess"
	ATTRS{idVendor}=="1366", ATTRS{idProduct}=="106b", MODE="660", GROUP="plugdev", TAG+="uaccess"
	ATTRS{idVendor}=="1366", ATTRS{idProduct}=="106c", MODE="660", GROUP="plugdev", TAG+="uaccess"
	ATTRS{idVendor}=="1366", ATTRS{idProduct}=="106d", MODE="660", GROUP="plugdev", TAG+="uaccess"
	ATTRS{idVendor}=="1366", ATTRS{idProduct}=="106e", MODE="660", GROUP="plugdev", TAG+="uaccess"
	ATTRS{idVendor}=="1366", ATTRS{idProduct}=="106f", MODE="660", GROUP="plugdev", TAG+="uaccess"

	# FT232H
	ATTRS{idVendor}=="0403", ATTRS{idProduct}=="6014", MODE="660", GROUP="plugdev", TAG+="uaccess"
	# FT2232x
	ATTRS{idVendor}=="0403", ATTRS{idProduct}=="6010", MODE="660", GROUP="plugdev", TAG+="uaccess"
	# FT4232H
	ATTRS{idVendor}=="0403", ATTRS{idProduct}=="6011", MODE="660", GROUP="plugdev", TAG+="uaccess"

	# FTDI-based Olimex devices
	ATTRS{idVendor}=="0x15ba", ATTRS{idProduct}=="0x0003", MODE="660", GROUP="plugdev", TAG+="uaccess"
	ATTRS{idVendor}=="0x15ba", ATTRS{idProduct}=="0x0004", MODE="660", GROUP="plugdev", TAG+="uaccess"
	ATTRS{idVendor}=="0x15ba", ATTRS{idProduct}=="0x002a", MODE="660", GROUP="plugdev", TAG+="uaccess"
	ATTRS{idVendor}=="0x15ba", ATTRS{idProduct}=="0x002b", MODE="660", GROUP="plugdev", TAG+="uaccess"

	# Espressif USB JTAG/serial debug unit
	ATTRS{idVendor}=="303a", ATTRS{idProduct}=="1001", MODE="660", GROUP="plugdev", TAG+="uaccess"
	# Espressif USB Bridge
	ATTRS{idVendor}=="303a", ATTRS{idProduct}=="1002", MODE="660", GROUP="plugdev", TAG+="uaccess"

	# CMSIS-DAP compatible adapters
	ATTRS{product}=="*CMSIS-DAP*", MODE="660", GROUP="plugdev", TAG+="uaccess"
	# WCH Link (CMSIS-DAP compatible adapter)
	ATTRS{idVendor}=="1a86", ATTRS{idProduct}=="8010", MODE="660", GROUP="plugdev", TAG+="uaccess"
	ATTRS{idVendor}=="1a86", ATTRS{idProduct}=="8011", MODE="660", GROUP="plugdev", TAG+="uaccess"

	LABEL="probe_rs_rules_end"
  '';

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
}
