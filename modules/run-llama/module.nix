{ pkgs, ... }:
with pkgs;
let
  script = builtins.readFile ./run-llama.sh;
  run-llama = writeShellScriptBin "run-llama" script;
in
  symlinkJoin {
    name = "run-llama";
    paths = [ run-llama ];
  }
