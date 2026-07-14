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
      serviceOverrides = {
        # Keep two concurrent runners from exhausting the workstation. MemoryHigh
        # starts reclaim/throttling before MemoryMax enforces the hard cgroup cap.
        MemoryHigh = "25%";
        MemoryMax = "30%";
        MemorySwapMax = "5%";
      };
    };
    cacheServer = {
      enable = true;
    };
    personalRunners = {

      # sudo systemctl restart github-runner-workstation-ageorgeh-cms-01.service
      # sudo systemctl restart github-runner-workstation-ageorgeh-cms-02.service
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

            dart-sass # SASS globally installed
            mkcert # Certificate generation

            lsof # List open files
            rsync
            libarchive # unzipping etc
            ripgrep
            docker_29

            qpdf
            poppler-utils

            util-linux
          ];
          extraEnvironment = {

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

      # "ageorgeh/ts-ag" = {
      #   num = 2;

      #   runnerOverrides = {
      #     extraPackages = with pkgs; [
      #       pnpm
      #       nodejs_24
      #     ];
      #     extraEnvironment = {
      #       NPM_CONFIG_PROVENANCE = "false";
      #     };
      #   };
      # };

      # "ageorgeh/svelte-ag" = {
      #   num = 2;

      #   runnerOverrides = {
      #     extraPackages = with pkgs; [
      #       pnpm
      #       nodejs_24
      #     ];
      #     extraEnvironment = {
      #       NPM_CONFIG_PROVENANCE = "false";
      #     };
      #   };
      # };
    };
  };

}
