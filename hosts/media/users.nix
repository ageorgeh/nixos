{ ... }:

{
  users.users = {
    alex = {
      isNormalUser = true;
      extraGroups = [ "wheel" ];
      openssh.authorizedKeys.keys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOR+Q5C3CCcWO96jb3K5y8zepC01WfnrLvn9uzhHGMG8 media"
      ];
    };
    qbittorrent = {
      isNormalUser = true;
      extraGroups = [ "wheel" ];
    };
  };
}
