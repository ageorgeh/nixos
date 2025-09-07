{ config, pkgs, ... }:

{
  programs.ssh = {
    enable = true;
    enableDefaultConfig = false;

    matchBlocks = {
      "*" = {
        forwardAgent = false;
        serverAliveInterval = 60;
        hashKnownHosts = true;
        controlMaster = "auto";
        controlPath = "~/.ssh/master-%r@%h:%p";
      };

      "github.com" = {
        hostname = "github.com";
        user = "git";
        identityFile = "~/.ssh/github_id";
        identitiesOnly = true;
      };
    };

    extraConfig = ''
      AddKeysToAgent yes
      IdentitiesOnly yes
    '';
  };

  home.file.".ssh/config" = {
    target = ".ssh/config_source";
    onChange = ''
      install -m 400 ~/.ssh/config_source ~/.ssh/config
    '';
  };
}
