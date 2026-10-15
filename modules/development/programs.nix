{ ... }:
{

  # Install direnv
  programs.direnv.enable = true;

  # Run an SSH agen to remember keys
  programs.ssh = {
    startAgent = true;
    enableAskPassword = true;
  };

  environment.sessionVariables = {
    SSH_ASKPASS_REQUIRE = "prefer";

    # For World of Warcraft - currently disabled
    WINEARCH = "win64";
    WINEPREFIX = "$HOME/.wine-battlenet";

    # Oktopi-specific, don't run slow Git pre-commit hooks
    HUSKY = "0";

    # Use Neovim for the default git commit editor
    EDITOR = "nvim";

    # Don't run Minuet by default
    NEOVIM_RUN_MINUET = "0";

    # Use the standard Zellij profile by default
    ZELLIJ_DEFAULT_PROFILE = "default";
  };
}
