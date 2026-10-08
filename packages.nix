{ pkgs, hasCudaSupport, ... }:
with pkgs;
let
  run-llama = import ./modules/run-llama/module.nix { inherit pkgs; };
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

  hyprlandPackages = [
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
