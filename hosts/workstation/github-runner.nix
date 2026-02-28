{ inputs, pkgs, ... }:

# Configures the service for github action to be able to use this machine as the runner
# Creates runners with the labels 'workstation' and 'x86_64-linux'. These labels should be specified to use these runners
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
      extraPackages = with pkgs; [
        zstd
      ];
    };
    cacheServer = {
      enable = true;
    };
    personalRunners = {
      "ageorgeh/cms" = {
        num = 2;

        runnerOverrides = {
          extraPackages = with pkgs; [
            pnpm
            nodejs_24
            dynamodb-local
            ripgrep
          ];
          extraEnvironment = {
            ACTIONS_RESULTS_URL = "http://localhost:3002";
          };
        };
      };

      "ageorgeh/ts-ag" = {
        num = 2;

        runnerOverrides = {
          extraPackages = with pkgs; [
            pnpm
            nodejs_24
          ];
          extraEnvironment = {
            ACTIONS_RESULTS_URL = "http://localhost:3002";
            NPM_CONFIG_PROVENANCE = "false";
          };
        };
      };

      "ageorgeh/svelte-ag" = {
        num = 2;

        runnerOverrides = {
          extraPackages = with pkgs; [
            pnpm
            nodejs_24
          ];
          extraEnvironment = {
            ACTIONS_RESULTS_URL = "http://localhost:3002";
            NPM_CONFIG_PROVENANCE = "false";
          };
        };
      };
    };
  };

}
