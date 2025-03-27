{
  lib,
  config,
  pkgs,
  ...
}: let
  userName = "alec";
  userDescription = "Alec Bassingthwaighte";
in {
  options = {
  };
  config = {
    users.users.${userName} = {
      isNormalUser = true;
      description = userDescription;
      shell = pkgs.bash;
      extraGroups = ["wheel" "docker" "wireshark" "libvirtd" "kvm" "dialout" "video"];
    };
    programs.bash.enable = true;
  };
}
