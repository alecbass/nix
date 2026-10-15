{ pkgs }:
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
