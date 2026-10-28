{ lib, ... }:
with lib;
{
  options.hasCudaSupport = mkOption {
    type = types.bool;
  };
  options.hasVulkanSupport = mkOption {
    type = types.bool;
  };
  options.hasFlashAttention = mkOption {
    type = types.bool;
  };
}
