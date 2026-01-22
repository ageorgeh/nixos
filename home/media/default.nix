{
  inputs,
  config,
  ...
}:
let
  p = inputs.self.lib.paths { inherit config inputs; };
  ssh = config.home.homeDirectory + "/.ssh";
  secrets = inputs.self + "/secrets";
in
{
  imports = [
    inputs.agenix.homeManagerModules.default

  ];

  home.username = "alex";
  home.homeDirectory = "/home/alex";
  home.stateVersion = "24.11";

  programs.home-manager.enable = true;

  programs.git = {
    enable = true;
    settings = {
      user = {
        email = "aghornung@gmail.com";
        name = "Alexander Hornung - media";
      };
      pull = {
        rebase = false;
      };
    };
  };

  programs.ssh = {
    enable = true;
    enableDefaultConfig = false; # TODO remove this when it becomes deprecated

    matchBlocks = {
      "*" = {
        forwardAgent = false;
        addKeysToAgent = "yes";
        identitiesOnly = true;
        compression = false;
        serverAliveInterval = 0;
        serverAliveCountMax = 3;
        hashKnownHosts = false;
        userKnownHostsFile = "~/.ssh/known_hosts";
        controlMaster = "no";
        controlPath = "~/.ssh/master-%r@%n:%p";
        controlPersist = "no";
      };

      "github.com" = {
        hostname = "github.com";
        user = "git";
        identityFile = p.keys.github;
        identitiesOnly = true;
      };
    };
  };

  age.identityPaths = [
    "${ssh}/id_ed25519_agenix"
  ];

  age.secrets."github-ssh-key" = {
    file = secrets + "/github-ssh-key.age";
    path = p.keys.github;
    mode = "600";
  };

}
