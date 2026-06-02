{ pkgs, ... }:
with pkgs; let
  fix-wifi = pkgs.writeShellScriptBin "fix-wifi" ''
    set -euxo pipefail

    if [[ $(whoami) != "root" ]]; then
      echo "This script should be run as sudo. Exiting..."
      exit 1
    fi

    modprobe -r b43 && modprobe -r bcma && modprobe -r wl && modprobe wl
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
  
  add-ssh-key = pkgs.writeShellScriptBin "add-ssh-key" ''
    set -euo pipefail

    key_path="$HOME/.ssh/id_ed25519"
    if [[ ! -f $key_path ]]; then 
      echo "SSh key not found. Exiting..."
      exit 1
    fi

    ssh-add $key_path && echo "Added SSH key"
  '';

  gemini = pkgs.writeShellScriptBin "gemini" ''
    # Runs the Gemini CLI tool without worrrying about Zod package clashes
    set -euxo pipefail
    
    pnpm dlx @google/gemini-cli
  '';

  run-llama = import ./modules/run-llama/module.nix { inherit pkgs; };
in rec {
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

    # Windows emulation
    # wine # 32-bit, use wine64 for 64-bit

    # Device Management
    gparted

    # Networking
    networkmanagerapplet

    # Self-hosting
    k3s

    # Streaming
    # stremio # NOTE(alec): Removed as it uses qt-5 which nix does't build nicely anymore

    # Editing
    gimp-with-plugins
    libreoffice-qt

    # Desktop-specific
    change-wallpaper
    fix-wifi

    # Miscellaneous
    tuigreet
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
    wget

    # Editors
    neovim
    vim # For when neovim crashes lol
    
    # LSPs
    shellcheck # Scripts
    lua-language-server # Lua
    roslyn-ls # C# and Razor
    nuget-to-json # Used to generate deps.json for rzls
    stylua # Formatter for Lua
    bash-language-server # Bash
    vtsls # TypeScript
    terraform-ls # Terraform
    vscode-langservers-extracted # HTML, CSS, JSON, ESLint
    docker-language-server # Docker
    docker-compose-language-service # Docker Compose
    diagnostic-languageserver # Custom LSPs

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


    # Rust
    (rust-bin.fromRustupToolchainFile ./rust-toolchain.toml)

    # Needed for Rust compilation
    openssl
    pkg-config
    libiconv

    # Go
    go

    # JavaScript / TypeScript
    typescript
    eslint
    prettier
    nodejs_24
    corepack_24

    # CSS
    stylelint
    stylelint-lsp

    # Debugging
    gdb

    # Linux utils
    bat # cat alternative
    ripgrep # Searching tool
    htop # Process monitoring tool
    direnv # Local environment loader
    lsof # See processes by port
    tldr # 

    # Networking
    wireguard-tools
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
  ];

  userPackages = [
    #  thunderbird
    # Programming tools
    git
    gh # Github
    add-ssh-key

    # Terminal
    zellij # Terminal tiling manager
    bash

    # Python
    (python314.withPackages (ps: with ps; [
      # Setup pip
      # pip - pip3.12 uses a C recursion symbol which Python 3.14 has since removed
      ruff
      pyright
      uv
    ]))

    # Docker
    docker
    podman
    # podman-tui

    # Databases
    dbeaver-bin

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

    # postman Currently not able to download on nixpkgs 25.05
    thonny # For MicroPython

    # LLMs
    llama-cpp
    run-llama # Custom LLM serving script

    # Wine - for https://nixos.wiki/wiki/Battle.net
    (wineWow64Packages.full.override {
      wineRelease = "staging";
      mingwSupport = true;
    })
    winetricks
  ];

}
