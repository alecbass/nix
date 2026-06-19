{
  pkgs,
  ...
}:
let
  userName = "alec";
  homeDirectory = "/home/${userName}";
  stateVersion = "25.11";
in
{
  home = {
    username = userName;
    homeDirectory = homeDirectory;
    stateVersion = stateVersion; # Please read the comment before changing.

    file = {
      # Log out options
      ".config/wlogout/icons".source = ../config/wlogout;

      # Shell scripts
      ".bashrc".source = ../config/files/.bashrc;
    };

    sessionVariables = {
      # Default applications
      EDITOR = "nvim";
      VISUAL = "nvim";
      TERMINAL = "ghostty";
      BROWSER = "google-chrome-stable";

      # XDG Base Directories
      XDG_CONFIG_HOME = "$HOME/.config";
      XDG_DATA_HOME = "$HOME/.local/share";
      XDG_STATE_HOME = "$HOME/.local/state";
      XDG_CACHE_HOME = "$HOME/.cache";
      XDG_SCREENSHOTS_DIR = "$HOME/Pictures/Screenshots";

      # Path modifications - now as a string
      # PATH = "$HOME/.local/bin:$HO../bin:$PATH";

      # Wayland and Hyprland specific
      JAVA_AWT_WM_NOREPARENTING = 1;
      XDG_SESSION_TYPE = "wayland";
      XDG_CURRENT_DESKTOP = "Hyprland";
      XDG_SESSION_DESKTOP = "Hyprland";

      # NVIDIA specific
      # __GLX_VENDOR_LIBRARY_NAME = "nvidia";
      # GBM_BACKEND = "nvidia-drm";

      # Localization
      LC_ALL = "en_AU.UTF-8";
    };

    sessionPath = [
      "$HOME/.local/bin"
      "$HO../bin"
    ];
  };

  imports = [
    ../config/wlogout.nix
  ];

  # Styling
  stylix.targets.waybar.enable = true;
  gtk = {
    iconTheme = {
      name = "Papirus-Dark";
      package = pkgs.papirus-icon-theme;
    };
    gtk3.extraConfig = {
      gtk-application-prefer-dark-theme = 1;
    };
    gtk4.extraConfig = {
      gtk-application-prefer-dark-theme = 1;
    };
  };

  programs.home-manager.enable = true;
}
