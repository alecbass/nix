{
  pkgs,
  ...
}:
{
  environment.sessionVariables = {
    ZELLIJ_DEFAULT_PROFILE = "default";
  };

  environment.systemPackages = with pkgs; [
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

    yt-dlp

    # Editing
    ffmpeg

    # Other utilities
    unzip

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
    vaultwarden
    vaultwarden-webvault
  ];
}
