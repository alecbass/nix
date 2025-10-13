{ pkgs, ... }:
with pkgs; rec {
  system-packages = [
    #  vim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
    #  wget

    # Editors
    neovim
    vim # For when neovim crashes lol
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
    glibc
    glibcInfo
    cmake

    # Needed for Rust compilation
    openssl
    pkg-config
    libiconv

    # Terminal
    ghostty
    kitty # For Hyprland
    zellij # Terminal tiling manager

    # Linux utils
    htop # Process viewer
    neofetch # Basic details
    inetutils # Network utilities such as telnet
    usbutils # Unsurprisingly, USB utilities
    alsa-utils # Sound and volume utilities
    brightnessctl # Screen brightness controls
    bat # cat alternative

    # Device Management
    gparted

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

    # Networking
    networkmanagerapplet

    # Self-hosting
    k3s

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

  user-packages = [
    #  thunderbird
    # Programming tools
    git
    gh # Github

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
    stremio
    jellyfin # Video streaming service

    # Other utilities
    unzip
    # postman Currently not able to download on nixpkgs 25.05
    thonny # For MicroPython

    # Powercor-specific
    stoken
  ];

}
