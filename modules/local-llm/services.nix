{ pkgs, config, ... }:
{
  services.llama-cpp = {
    enable = true;
    package = (
      pkgs.llama-cpp.override {
        cudaSupport = config.hasCudaSupport; # Compile with Nvidia GPU usage
        vulkanSupport = config.hasVulkanSupport; # Compile with Intel Arc GPU usage
      }
    );
    # package = pkgs.llama-cpp-rocm;

    # Takes care of downloading if model not present
    settings.host = "127.0.0.1";
    settings.port = 8012;
    settings.models-preset = (pkgs.formats.ini { }).generate "models-preset.ini" {
      # Requires 8GB VRAM
      "Coder-Fim" = {
        # Extract from the model URL on HuggingFace
        hf-repo = "henrik3/sweep-next-edit-v2-7B-GGU";

        # Optimization parameters
        temp = "0.1";
        flash-attn = config.hasFlashAttention;
      };
    };
  };
}
