{
  description = "My NixOS flake: can be used to create a NixOS flake or create a local environment with the same configuration.";
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-25.11";
    flake-utils.url = "github:numtide/flake-utils";
    stylix = {
      url = "github:nix-community/stylix/release-25.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    home-manager = {
      url = "github:nix-community/home-manager/release-25.11";
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
    rust-overlay = {
      url = "github:oxalica/rust-overlay";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      flake-utils,
      rust-overlay,
      ...
    }@inputs:
    let
      nixosSystem = "x86_64-linux"; # I only run NixOS on an x86 machine
      allSystems = flake-utils.lib.eachDefaultSystem (system:
      let
        overlays = [ (import rust-overlay) ];
        pkgs = import nixpkgs {
          inherit system overlays;
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

        packages = import ./packages.nix { inherit pkgs; };

        desktopConfig = nixpkgs.lib.nixosSystem {
          inherit system;
          specialArgs = { inherit inputs probeRsRules packages; };
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
                nixpkgs.overlays = [ customSddmThemeOverlay ];
              }
            )
            ./hosts/default/configuration.nix
            inputs.stylix.nixosModules.stylix
            inputs.home-manager.nixosModules.default
          ];
        };

        laptopConfig = nixpkgs.lib.nixosSystem {
          inherit system;
          specialArgs = { inherit inputs probeRsRules packages; };
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
                nixpkgs.overlays = [ customSddmThemeOverlay ];
              }
            )
            ./hosts/laptop/configuration.nix
            inputs.stylix.nixosModules.stylix
            inputs.home-manager.nixosModules.default
          ];
        };
      in
      {
        nixosConfigurations.default = desktopConfig;
        nixosConfigurations.laptop = laptopConfig;
        # Shell-only environment
        devShells.default = with pkgs; mkShell {
          buildInputs = packages.systemPackages ++ packages.userPackages ++ [ direnv ];
        };
      }
    );
  in
  # Spread the result all eachDefaultSystem to the end result
  allSystems // {
    nixosConfigurations.default = allSystems.nixosConfigurations."${nixosSystem}".default;
  };
}
