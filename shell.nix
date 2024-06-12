let
  nixpkgs = fetchTarball "https://github.com/NixOS/nixpkgs/tarball/nixos-24.05";
  pkgs = import nixpkgs { config = {}; overlays = []; };
in pkgs.mkShellNoCC {
  packages = with pkgs; [
    cowsay
    lolcat
    neovim
    (python312.withPackages (ps: with ps; [
      # Setup pip
      pip
    ]))
    cargo
    rustc
    nodejs
    podman
    git
  ];

  GREETING = "Hello, Nix!";

  shellHook = ''
    echo $GREETING | cowsay | lolcat
  '';
}
