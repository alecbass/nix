{ probeRsRules }:
{
  # Enable Wayland - https://github.com/dc-tec/nixos-config/blob/main/modules%2Fgraphical%2Fdesktop%2Fhyprland%2Fdefault.nix
  services = {
    xserver = {
      enable = true;
      videoDrivers = [ "nvidia" ];
    };
    displayManager = {
      gdm = {
        enable = false;
      };
      sddm = {
        # https://github.com/nixos/nixpkgs/issues/523332
        enable = true;
        wayland.enable = true; # Workaround until Gnome can be launched in NixOS 26.05
      };
    };
    # Enable CUPS to print documents.
    printing.enable = true;
    pipewire = {
      enable = true;
      alsa = {
        enable = true;
        support32Bit = true;
      };
      pulse.enable = true;
      jack.enable = true;
      wireplumber.enable = true;

      # use the example session manager (no others are packaged yet so this is enabled by default,
      # no need to redefine it in your config for now)
      #media-session.enable = true;
    };
    pulseaudio.enable = false;

    # Udev rule overwrites
    # Allow rs-probe access
    udev.extraRules = probeRsRules;

    # Allow USBs to be mounted
    udisks2.enable = true;
  };
}
