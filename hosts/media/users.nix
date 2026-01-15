{ inputs, config, ... }:

{
  users = {
    groups = {
      media = { };
      downloads = { };
    };
    users = {
      alex = {
        isNormalUser = true;
        extraGroups = [
          "wheel"
          "media"
          "downloads"
        ];
        openssh.authorizedKeys.keys = [
          "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOR+Q5C3CCcWO96jb3K5y8zepC01WfnrLvn9uzhHGMG8 media"
        ];
      };
      qbittorrent = {
        isSystemUser = true;
        extraGroups = [
          "media"
          "downloads"
        ];
      };
      plex = {
        isSystemUser = true;
        extraGroups = [ "media" ];
      };
    };
  };

  # Home Manager integration
  home-manager.useGlobalPkgs = true;
  home-manager.useUserPackages = true;

  home-manager.extraSpecialArgs = {
    inherit inputs;
  };

  home-manager.users.alex = import ../../home/media/default.nix;
}
