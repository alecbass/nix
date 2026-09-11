{ lib, ... }:
with lib;
{
  options.hasCudaSupport = mkOption {
    type = types.bool;
    default = false;
  };
}
