{ inputs, user }:
{
  home-manager = {
    extraSpecialArgs = { inherit inputs; };
    users.${user.userName} = import ./home.nix;
    useGlobalPkgs = false;
    useUserPackages = true;
    backupFileExtension = "backup";
  };
}
