
{ lib, ... }:
with lib;
{
  options.hasVulkanSupport = mkOption {
    type = types.bool;
  };
}
