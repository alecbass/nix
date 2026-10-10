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
  ];
}
