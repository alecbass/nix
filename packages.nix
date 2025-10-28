{ pkgs, ... }:
with pkgs; rec {
  # System packages that only work on NixOS and not on a Darwin flake
  nixosOnlyDeps = [
    # Terminal
    ghostty
    kitty

    # C/C++
    glibc
    glibcInfo

    # Linux utils
    htop # Process viewer
    neofetch # Basic details
    inetutils # Network utilities such as telnet
    usbutils # Unsurprisingly, USB utilities
    alsa-utils # Sound and volume utilities
    brightnessctl # Screen brightness controls

    # Device Management
    gparted

    # Networking
    networkmanagerapplet

    # Self-hosting
    k3s

    # Streaming
    stremio

    # Miscellaneous
    greetd.tuigreet
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

  systemPackages = [
    #  vim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
    #  wget

    # Editors
    neovim
    vim # For when neovim crashes lol
    code-cursor
    
    # LSPs
    shellcheck
    lua-language-server
    roslyn-ls
    rzls
    nuget-to-json # Used to generate deps.json for rzls

    # C/C++
    libgcc
    libcxx
    gcc
    gnumake
    clang
    clang-tools
    libclang
    libgcc
    cmake

    # Needed for Rust compilation
    openssl
    pkg-config
    libiconv

    # Linux utils
    bat # cat alternative
  ];

  hyprlandPackages = [
    # Wayland-specific
    hyprshot
    hypridle
    grim
    slurp
    waybar
    dunst
    wl-clipboard
    swaynotificationcenter
    hyprpaper # Background image
  ];

  userPackages = [
    #  thunderbird
    # Programming tools
    git
    gh # Github

    # Terminal
    zellij # Terminal tiling manager
    bash

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

    # Streaming
    jellyfin # Video streaming service

    # Other utilities
    unzip

    # postman Currently not able to download on nixpkgs 25.05
    thonny # For MicroPython

    # Tendl-specific
    _1password-cli
  ];

}
