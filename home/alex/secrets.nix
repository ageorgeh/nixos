{ config, inputs, ... }:

let
  ssh = config.home.homeDirectory + "/.ssh";
  secrets = inputs.self + ../../secrets;
in

{
  age.identityPaths = [
    "${ssh}/id_ed25519_agenix"
  ];


  age.secrets."github-ssh-key" = {
    file = secrets + "/github-ssh-key.age";
    path = "${ssh}/github_id";
    mode = "600";
  };
}
