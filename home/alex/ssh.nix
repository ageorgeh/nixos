{
  config,
  inputs,
  ...
}:

let
  p = inputs.self.lib.paths { inherit config inputs; };
in
{
  services.ssh-agent.enable = true;

  programs.ssh = {
    enable = true;
    enableDefaultConfig = false; # TODO remove this when it becomes deprecated

    settings = {
      "*" = {
        ForwardAgent = false;
        AddKeysToAgent = "yes";
        IdentitiesOnly = true;
        Compression = false;
        ServerAliveInterval = 0;
        ServerAliveCountMax = 3;
        HashKnownHosts = false;
        UserKnownHostsFile = "~/.ssh/known_hosts";
        ControlMaster = "no";
        ControlPath = "~/.ssh/master-%r@%n:%p";
        ControlPersist = "no";
      };

      "github.com" = {
        HostName = "github.com";
        User = "git";
        IdentityFile = p.keys.github;
        IdentitiesOnly = true;
      };

      "media-server" = {
        HostName = "192.168.20.75"; # TODO parameterise this
        User = "alex"; # TODO this too
        IdentityFile = p.keys.media;
      };

      "media-client" = {
        HostName = "192.168.20.40";
        User = "root";
      };
    };
  };
}
