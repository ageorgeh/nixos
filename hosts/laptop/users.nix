{ inputs, pkgs, config, ... }:

{
  users = {
    groups = {
     alex = {};
    };
    users = {
      alex = {
    name     = "alex";
    home     = "/Users/alex";
    isHidden = false;
    shell    = pkgs.zsh;
      };
    };
  };

  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;

    extraSpecialArgs = {
      inherit inputs;
    };

    users = {
     alex =  import ../../home/alex/default.nix;
    };
  };
}
