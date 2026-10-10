{ pkgs, ... }:
with pkgs;
let
in
{
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
  ];

}
