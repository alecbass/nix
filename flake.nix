{
  description = "My NixOS flake: can be used to create a NixOS flake or create a local environment with the same configuration.";
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    stylix = {
      url = "github:nix-community/stylix/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    home-manager = {
      url = "github:nix-community/home-manager/release-26.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    rust-overlay = {
      url = "github:oxalica/rust-overlay";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixos-wsl.url = "github:nix-community/NixOS-WSL/main";
  };

  outputs =
    {
      nixpkgs,
      flake-utils,
      rust-overlay,
      nixos-wsl,
      ...
    }@inputs:
    let
      nixosSystem = "x86_64-linux"; # I only run NixOS on x86 machines
      nixosPermittedInsecurePackages = [
        "broadcom-sta-6.30.223.271-63-6.18.50"
      ];

      baseOsConfig = { ... }: {
        nixpkgs.config = {
          allowBroken = false;
          allowUnfree = true;
        };
        nixpkgs.overlays = [ ];
      };

      allSystems = flake-utils.lib.eachDefaultSystem (
        system:
        let
          overlays = [ (import rust-overlay) ];
          pkgs = import nixpkgs {
            inherit system overlays;
            config = {
              allowBroken = false;
              allowUnfree = true;
              allowSupportedSystem = true;
              permittedInsecurePackages = nixosPermittedInsecurePackages;
            };
          };
          probeRsRules = builtins.readFile ./udev/69-probe-rs.rules;

          desktopConfig = nixpkgs.lib.nixosSystem {
            inherit system;
            specialArgs = {
              inherit
                inputs
                probeRsRules
                nixosPermittedInsecurePackages
                ;
              flakePkgs = pkgs;
            };
            modules = [
              baseOsConfig
              ./hosts/default/configuration.nix
              inputs.stylix.nixosModules.stylix
              inputs.home-manager.nixosModules.default
            ];
          };

          laptopConfig = nixpkgs.lib.nixosSystem {
            inherit system;
            specialArgs = {
              inherit
                inputs
                probeRsRules
                nixosPermittedInsecurePackages
                ;
              flakePkgs = pkgs;
            };
            modules = [
              baseOsConfig
              ./hosts/laptop/configuration.nix
              inputs.stylix.nixosModules.stylix
              inputs.home-manager.nixosModules.default
            ];
          };

          wslConfig = nixpkgs.lib.nixosSystem {
            inherit system;
            specialArgs = {
              inherit
                inputs
                probeRsRules
                nixosPermittedInsecurePackages
                nixos-wsl
                ;
              flakePkgs = pkgs;
            };
            modules = [
              baseOsConfig
              ./hosts/wsl/configuration.nix
              inputs.stylix.nixosModules.stylix
              inputs.home-manager.nixosModules.default
            ];
          };

          # Assume that the dev shell does not had CUDA support
          devShellPackages = import ./packages.nix {
            inherit pkgs;
            hasCudaSupport = false;
          };
        in
        {
          nixosConfigurations.default = desktopConfig;
          nixosConfigurations.laptop = laptopConfig;
          nixosConfigurations.wsl = wslConfig;
          # Shell-only environment
          devShells.default =
            with pkgs;
            mkShell {
              buildInputs = devShellPackages.systemPackages ++ devShellPackages.userPackages ++ [ direnv ];
            };
        }
      );
    in
    # Spread the result all eachDefaultSystem to the end result
    allSystems
    // {
      nixosConfigurations.default = allSystems.nixosConfigurations."${nixosSystem}".default;
      nixosConfigurations.laptop = allSystems.nixosConfigurations."${nixosSystem}".laptop;
      nixosConfigurations.wsl = allSystems.nixosConfigurations."${nixosSystem}".wsl;
    };
}
