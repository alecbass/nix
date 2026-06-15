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
      # TODO: Use my dotfiles repository
      # # Hyprland Config
      ".config/wlogout/icons".source = ../config/wlogout;
      ".config/rofi/config-emoji.rasi".text = "";
      ".config/rofi/config-long.rasi".text = "";

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

    packages = [
      (import ../scripts/rofi-launcher.nix { inherit pkgs; })
    ];
  };

  imports = [
    # ../config/rofi/rofi.nix
    ../config/wlogout.nix
  ];

  # Styling
  stylix.targets.waybar.enable = false;
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
  qt = {
    enable = true;
    style.name = "kvantum";
    platformTheme.name = "qtct";
  };

  services.hypridle = {
    settings = {
      general = {
        after_sleep_cmd = "hyprctl dispatch dpms on";
        ignore_dbus_inhibit = false;
        lock_cmd = "hyprlock";
      };
      listener = [
        {
          timeout = 900;
          on-timeout = "hyprlock";
        }
        {
          timeout = 1200;
          on-timeout = "hyprctl dispatch dpms off";
          on-resume = "hyprctl dispatch dpms on";
        }
      ];
    };
  };

  programs.home-manager.enable = true;
}
