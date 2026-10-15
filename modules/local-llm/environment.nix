{ pkgs, config, ... }:
let
  # Custom LLM serving script
  run-llama = import ./run-llama/module.nix { inherit pkgs; };
in
{
  environment.systemPackages = with pkgs; [
    run-llama

    (llama-cpp.override {
      cudaSupport = config.hasCudaSupport; # Compiele with GPU usage
    })
  ];
}
