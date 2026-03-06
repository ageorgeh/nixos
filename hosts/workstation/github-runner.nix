{ inputs, pkgs, ... }:

let
  browsers =
    (builtins.fromJSON (builtins.readFile "${pkgs.playwright-driver}/browsers.json")).browsers;

  chromium-rev = (builtins.head (builtins.filter (x: x.name == "chromium") browsers)).revision;
in
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
            bun

            awscli2
            aws-sam-cli # AWS SAM CLI
            dynamodb-local

            playwright-test
            playwright-driver.browsers

            dart-sass # SASS globally installed
            mkcert # Certificate generation

            lsof # List open files
            ripgrep
            docker_28
          ];
          extraEnvironment = {
            ACTIONS_RESULTS_URL = "http://localhost:3002";
            PLAYWRIGHT_BROWSERS_PATH = "${pkgs.playwright-driver.browsers}";
            PLAYWRIGHT_SKIP_VALIDATE_HOST_REQUIREMENTS = "true";
            PLAYWRIGHT_NODEJS_PATH = "${pkgs.nodejs_24}/bin/node";
            PLAYWRIGHT_LAUNCH_OPTIONS_EXECUTABLE_PATH = "${pkgs.playwright-driver.browsers}/chromium-${chromium-rev}/chrome-linux/chrome";
            PLAYWRIGHT_HOST_PLATFORM_OVERRIDE = "ubuntu-24.04";
          };

          serviceOverrides = {
            SystemCallFilter = "";
            RestrictNamespaces = false;
            PrivateUsers = false;
            PrivateDevices = false;
            NoNewPrivileges = false;
            ProtectSystem = "full"; # or false
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
