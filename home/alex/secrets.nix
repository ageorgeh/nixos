{ config, inputs, ... }:

let
  ssh = config.home.homeDirectory + "/.ssh";
  secrets = inputs.self + "/secrets";
  p = import ../../lib/paths.nix { inherit config inputs; };
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
}
