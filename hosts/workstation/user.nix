{ config, inputs, ... }:

{
  users.users.alex = {
    isNormalUser = true;
    description = "Alexander Hornung";
    extraGroups = [
      "networkmanager"
      "wheel"
      "docker"
      "input"
    ];
  };

  # Home Manager integration
  home-manager.useGlobalPkgs = true;
  home-manager.useUserPackages = true;

  home-manager.extraSpecialArgs = {
    inherit inputs;
    hostName = config.networking.hostName;
  };

  home-manager.users.alex = import ../../home/alex/default.nix;
}
