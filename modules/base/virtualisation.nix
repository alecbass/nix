{ }:
{
  # Virtualisation for Docker and Podman
  virtualisation = {
    containers = {
      enable = true;
    };

    docker = {
      enable = true;
    };

    podman = {
      enable = true;

      # Create a `docker` alias for podman, to use it as a drop-in replacement
      dockerCompat = false;

      # True to let pod-compose containers talk to each other
      defaultNetwork.settings.dns_enabled = true;
    };
  };
}
