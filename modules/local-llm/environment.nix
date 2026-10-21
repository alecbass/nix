{ pkgs, config, ... }:
let
  # Custom LLM serving script
  run-llama = import ./run-llama/module.nix { inherit pkgs; };
in
{
  environment.systemPackages = with pkgs; [
    run-llama

    (llama-cpp.override {
      cudaSupport = config.hasCudaSupport; # Compile with Nvidia GPU usage
      vulkanSupport = config.hasVulkanSupport; # Compile with Intel Arc GPU usage
    })
  ];
}
