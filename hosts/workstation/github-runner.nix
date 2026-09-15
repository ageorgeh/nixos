{ inputs, pkgs, ... }:

let
  sharedPnpmStore = "/run/github-runner-pnpm-store";
in

# Configures the service for github action to be able to use this machine as the runner
# Creates runners with the labels 'workstation' and 'x86_64-linux'. These labels should be specified to use these runners
{
  systemd.tmpfiles.rules = [
    "d ${sharedPnpmStore} 0750 github-runner github-runner -"
  ];

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
        MemoryHigh = "28%";
        MemoryMax = "30%";
        MemorySwapMax = "5%";

        # Investigating runs that might have hit the limit:
        # journalctl -u github-runner-workstation-ageorgeh-cms-01.service \
        # --since "10 minutes ago" --no-pager |
        # rg "Consumed.*memory peak"
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
            nodejs_24
            bun

            awscli2
            aws-sam-cli # AWS SAM CLI
            extenddb

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
            PNPM_CONFIG_STORE_DIR = sharedPnpmStore;
            CMS_EXTENDDB_ENDPOINT = "https://localhost:8443";
            CMS_EXTENDDB_ADMIN_PASSWORD_PATH = "/var/lib/extenddb/admin-password";
            CMS_EXTENDDB_CA_CERT_PATH = "/var/lib/extenddb/.extenddb/tls/cert.pem";
            NODE_EXTRA_CA_CERTS = "/var/lib/extenddb/.extenddb/tls/cert.pem";
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
