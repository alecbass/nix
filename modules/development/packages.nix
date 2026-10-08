{
  pkgs,
  flakePkgs,
  config,
  ...
}:
let
  add-ssh-key = pkgs.writeShellScriptBin "add-ssh-key" ''
    set -euo pipefail

    key_path="$HOME/.ssh/id_ed25519"
    if [[ ! -f $key_path ]]; then 
      echo "SSh key not found. Exiting..."
      exit 1
    fi

    ssh-add $key_path && echo "Added SSH key"
  '';
in
{
  environment.systemPackages = with pkgs; [
    # Editors
    neovim
    vim # For when neovim crashes lol

    # LSPs
    shellcheck # Scripts
    lua-language-server # Lua
    roslyn-ls # C# and Razor
    nuget-to-json # Used to generate deps.json for rzls
    stylua # Formatter for Lua
    bash-language-server # Bash
    vtsls # TypeScript
    terraform-ls # Terraform
    vscode-langservers-extracted # HTML, CSS, JSON, ESLint
    docker-language-server # Docker
    docker-compose-language-service # Docker Compose
    diagnostic-languageserver # Custom LSPs
    tree-sitter # Parser for Neovim Treesitter
    yaml-language-server
    basedpyright # Python

    # C/C++
    libgcc
    libcxx
    gcc
    gnumake
    clang
    clang-tools
    libclang
    libgcc
    cmake

    # Rust
    (flakePkgs.rust-bin.fromRustupToolchainFile ../../rust-toolchain.toml)

    # Needed for Rust compilation
    openssl
    pkg-config
    libiconv

    # Go
    go

    # JavaScript / TypeScript
    typescript
    eslint
    prettier
    nodejs_26
    pnpm

    # CSS
    stylelint
    stylelint-lsp

    # Debugging
    gdb
    #  thunderbird
    # Programming tools
    git
    gh # Github
    add-ssh-key

    # Terminal
    zellij # Terminal tiling manager
    bash

    # Python
    (python314.withPackages (
      ps: with ps; [
        # Setup pip
        # pip - pip3.12 uses a C recursion symbol which Python 3.14 has since removed
        ruff
        basedpyright
        uv

        # Specific to Oktopi
        # pytest-language-server
      ]
    ))

    # Docker
    docker
    podman
    # podman-tui

    # Databases
    dbeaver-bin

    # postman Currently not able to download on nixpkgs 25.05
    thonny # For MicroPython

    opencode
    claude-code

    # Oktopi-specific
    awscli2
  ];

}
