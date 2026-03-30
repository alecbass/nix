{ pkgs, ... }:
with pkgs;
let
  script = builtins.readFile ./run-llama.sh;
  run-llama = writeShellScriptBin "run-llama" script;
in
  run-llama
  # symlinkJoin {
  #   name = "run-llama";
  #   paths = [ run-llama ];
  # }
