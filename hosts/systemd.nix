{ pkgs, packages }:
{
  systemd.services = {
    flatpak-repo = {
      path = [ pkgs.flatpak ];
      script = "flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo";
    };
    libvirtd = {
      enable = true;
      wantedBy = [ "multi-user.target" ];
      requires = [ "virtlogd.service" ];
    };
    fix-wifi = {
      enable = true;
      description = "Restarts the user wifi in case it failed to launch on Linux";
      wantedBy = [ "multi-user.target" ]; # Starts after login
      path = packages.nixosOnlyDeps ++ [ pkgs.kmod ]; # Required dependencies: modprobe (through kmod) and the fix-wifi script

      script = ''
        set -euxo pipefail
        fix-wifi
        echo "Restarted Wifi"
      '';

      # Run the script once as sudo after login
      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = false;
        User = "root"; # The script needs to run as sudo
        Group = "root";
      };
    };
  };

  systemd.user.services = {
    change-wallpaper = {
      enable = true;
      description = "Sets a Hyprpaper wallpaper at launch";
      serviceConfig.PassEnvironment = "DISPLAY";
      script = ''
        change-wallpaper
      '';
      wantedBy = [ "multi-user.target" ]; # starts after login
    };
  };
}
