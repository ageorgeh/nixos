{ inputs, pkgs, ... }:

# Configures the service for github action to be able to use this machine as the runner
# Creates runners with the labels 'workstation' and 'x86_64-linux'. These labels should be specified to use these runners
# TODO take this module https://github.com/juspay/github-nix-ci/blob/main/nix/module.nix
# and make it so that i can specify extra packages for each runner
{
  imports = [
    inputs.agenix.nixosModules.default
    # inputs.github-nix-ci.nixosModules.default
    ../../lib/github-nix-ci.nix
  ];

  age.identityPaths = [
    "/home/alex/.ssh/id_ed25519_agenix"
  ];

  services.github-nix-ci = {
    age.secretsDir = ../../secrets;
    runnerSettings = {

    };
    cacheServer = {
      enable = true;
    };
    personalRunners = {
      "ageorgeh/cms" = {
        num = 1;

        runnerOverrides = {
          extraPackages = with pkgs; [
            pnpm
            nodejs_24
          ];
          extraEnvironment = {
            # npm_config_store_dir = "/var/cache/pnpm-store";
            ACTIONS_RESULTS_URL = "http://localhost:3002";
          };
        };
      };
    };
  };

}
