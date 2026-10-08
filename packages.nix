{ pkgs, hasCudaSupport, ... }:
with pkgs;
let
  fix-wifi = pkgs.writeShellScriptBin "fix-wifi" ''
    set -euo pipefail

    if [[ $(whoami) != "root" ]]; then
      echo "This script should be run as sudo. Exiting..."
      exit 1
    fi

    echo "Restarting wifi module..."
    modprobe -r b43 && modprobe -r bcma && modprobe -r wl && modprobe wl
    echo "Restarted wifi!"
  '';

  change-wallpaper = pkgs.writeShellScriptBin "change-wallpaper" ''
    set -euxo pipefail

    script_path="$HOME/.config/hypr/wallpaper.sh"
    if [[ ! -f $script_path ]]; then 
      echo "Wallpaper script not found. Exiting..."
      exit 1
    fi

    exec $script_path && "Changed wallpaper"
  '';

  run-llama = import ./modules/run-llama/module.nix { inherit pkgs; };
in
{
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
    # stremio # NOTE(alec): Removed as it uses qt-5 which nix does't build nicely anymore

    # Editing
    # gimp-with-plugins
    libreoffice-qt

    # Desktop-specific
    change-wallpaper
    fix-wifi

    # Miscellaneous
    tuigreet
    qt5.qtgraphicaleffects
    kdePackages.dolphin
    kdePackages.kio
    kdePackages.kio-extras
    kdePackages.breeze-icons
    kdePackages.dolphin-plugins
    kdePackages.kdesdk-thumbnailers
    kdePackages.kdegraphics-thumbnailers
    kdePackages.kdegraphics-mobipocket
    kdePackages.kimageformats
    # kdePackages.calligra
    kdePackages.qtimageformats
    kdePackages.ffmpegthumbs
    kdePackages.taglib
    kdePackages.baloo
    kdePackages.baloo-widgets
    kdePackages.qtsvg # To make file icons appear in Dolphin

    rofi
    (import ./scripts/rofi-launcher.nix { inherit pkgs; })

    # Windows emulation
    # wine # 32-bit, use wine64 for 64-bit

    # Wine - for https://nixos.wiki/wiki/Battle.net
    # (wineWow64Packages.full.override {
    #   wineRelease = "staging";
    #   mingwSupport = true;
    # })
    # winetricks
  ];

  systemPackages = [
    wget

    # Linux utils
    bat # cat alternative
    ripgrep # Searching tool
    htop # Process monitoring tool
    direnv # Local environment loader
    lsof # See processes by port
    tldr

    # Networking
    wireguard-tools

    # Nix-related
    nixfmt
    nixd
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
    change-wallpaper
    wayle # Top bar
  ];

  userPackages = [
    # Browsers
    google-chrome

    # Socials
    discord
    slack
    yt-dlp

    # Editing
    ffmpeg

    # Other utilities
    unzip

    # LLMs
    (llama-cpp.override {
      # Pass your config value here if the derivation supports it
      cudaSupport = hasCudaSupport; # Compiele with GPU usage
    })
    run-llama # Custom LLM serving script
  ];

}
