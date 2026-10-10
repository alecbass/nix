{ packages, ... }:
let
  userName = "alec";
  userDescription = "Alec Bassingthwaighte";
in
{
  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.${userName} = {
    isNormalUser = true;
    description = userDescription;
    extraGroups = [
      "networkmanager" # Default
      "wheel" # Default
      "docker" # Allows Docker usage
      "dialout" # Allows user to echo to /dev/ttyACM0 (and other devices) for hardware debugging
      "plugdev" # Allows user to access USB devices, see custom udev rules below
    ];
    packages = packages.userPackages;
  };

  userName = userName;
}
