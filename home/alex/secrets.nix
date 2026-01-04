{ config, inputs, ... }:

let
  ssh = config.home.homeDirectory + "/.ssh";
  secrets = inputs.self + "/secrets";
  p = inputs.self.lib.paths { inherit config inputs; };
in

{
  age.identityPaths = [
    "${ssh}/id_ed25519_agenix"
  ];

  age.secrets."github-ssh-key" = {
    file = secrets + "/github-ssh-key.age";
    path = p.keys.github;
    mode = "600";
  };

  age.secrets."media-ssh-key" = {
    file = secrets + "/media-ssh-key.age";
    path = p.keys.media;
    mode = "600";
  };
}
