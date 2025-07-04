{
  description = "My flake";
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-25.05";
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
  };

  outputs =
    {
      self,
      nixpkgs,
      # TODO: Re-add minecraft
      ...
    }@inputs:
    let
      system = "x86_64-linux";

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
    in
    {
      nixosConfigurations.default = nixpkgs.lib.nixosSystem {
        inherit system;
        specialArgs = { inherit inputs; };
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
    };
}
