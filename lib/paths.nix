{ config, inputs }:

let
  home = config.home.homeDirectory;
  sshDir = "${home}/.ssh";
in
{
  secretsDir = inputs.self + "/secrets";
  keys = {
    github = "${sshDir}/github_id";
  };
}
