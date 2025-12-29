{ config, inputs, ... }:

{
  users.users.alex = {
    isNormalUser = true;
    description = "Alexander Hornung";
    extraGroups = [ "networkmanager" "wheel" "docker" "input" ];
  };


  # Home Manager integration
  home-manager.useGlobalPkgs = true;
  home-manager.useUserPackages = true;

  home-manager.extraSpecialArgs = {
    inherit inputs;
    hy3 = inputs.hy3;
    hostName = config.networking.hostName;
    cfg = rec {
      username = "alex";
      homeDirectory = "/home/${username}";
      runtimeRoot = "${homeDirectory}/nixos-config";
      context = inputs.self;
    };
  };

  home-manager.users.alex = import ../../home/alex/default.nix;
}
