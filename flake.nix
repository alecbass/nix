{
  description = "My NixOS flake: can be used to create a NixOS flake or create a local environment with the same configuration.";
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-25.05";
    flake-utils.url = "github:numtide/flake-utils";
    stylix = {
      url = "github:nix-community/stylix/release-25.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    home-manager = {
      url = "github:nix-community/home-manager/release-25.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    hyprpanel = {
      url = "github:Jas-SinghFSU/HyprPanel";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    minecraft = {
      url = "path:/home/alec/Documents/nix/modules/minecraft.nix";
      flake = false; # This is a package
    };
    fix-wifi = { # Unused currently
      url = "path:/home/alec/Documents/nix/modules/fix-wifi.nix";
      flake = false;
    };
    roslyn-ls = {
      url = "path:/home/alec/Documents/nix/modules/roslyn-ls/package.nix";
      flake = false; # This is a package
    };
    rzls = {
      url = "path:/home/alec/Documents/nix/modules/rzls/package.nix";
      flake = false; # This is a package
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      flake-utils,
      ...
    }@inputs:
    let
      nixosSystem = "x86_64-linux"; # I only run NixOS on an x86 machine
      allSystems = flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs {
          inherit system;
          config = {
            allowUnfree = true;
            allowSupportedSystem = true;
            permittedInsecurePackages = [];
          };
        };

        # Define the custom SDDM theme as an overlay
        customSddmThemeOverlay = final: prev: {
          customSddmTheme = prev.stdenv.mkDerivation {
            name = "rose-pine";
            src = ./modules/sddm-theme;
            installPhase = ''
              mkdir -p $out/share/sddm/themes/rose-pine
              cp -r $src/* $out/share/sddm/themes/rose-pine
            '';
          };
        };

        probeRsRules = builtins.readFile ./config/udev/69-probe-rs.rules;
        fix-wifi = pkgs.writeShellScriptBin "fix-wifi" ''
          set -e

          if [[ $(whoami) != "root" ]]; then
            echo "This script should be run as sudo. Exiting..."
            exit 1
          fi

          modprobe -r b43 && modprobe -r bcma && modprobe -r wl && modprobe wl
        '';
        change-wallpaper = pkgs.writeShellScriptBin "change-wallpaper" ''
          script_path="$HOME/.config/hypr/wallpaper.sh"
          if [[ ! -f $script_path ]]; then 
            echo "Wallpaper script not found. Exiting..."
            exit 1
          fi

          exec $script_path && "Changed wallpaper"
        '';

        # Laptops usually have inbuilt hardware that doesn't match the home desktop
        is-laptop = false;

        packages = import ./packages.nix { inherit pkgs customSddmThemeOverlay; };
        python = with pkgs; (python312Full.withPackages(ps: with ps; [
          black
        ]));
        python-deps = with pkgs; [ python poetry ];
        tendlDeps = with pkgs; [ minio ] ++ python-deps;
      in
      {
        nixosConfigurations.default = nixpkgs.lib.nixosSystem {
          inherit system;
          specialArgs = { inherit inputs probeRsRules fix-wifi change-wallpaper is-laptop; };
          modules = [
            (
              {
                config,
                pkgs,
                ...
              }:
              {
                nixpkgs.config.allowUnfree = true;

                # Add the custom theme overlay
                nixpkgs.overlays = [
                  customSddmThemeOverlay
                ];
              }
            )
            ./hosts/default/configuration.nix
            inputs.stylix.nixosModules.stylix
            inputs.home-manager.nixosModules.default
          ];
        };

        # Shell-only environment
        devShells.default = with pkgs; mkShell {
          buildInputs = packages.userPackages ++ tendlDeps;
        };
      }
    );
  in
  # Spread the result all eachDefaultSystem to the end result
  allSystems // {
    nixosConfigurations.default = allSystems.nixosConfigurations."${nixosSystem}".default;
  };
}
