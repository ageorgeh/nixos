# Source:
# https://github.com/juspay/github-nix-ci/blob/main/nix/module.nix

top@{
  pkgs,
  lib,
  config,
  ...
}:

let
  inherit (pkgs.stdenv) isLinux isDarwin;
  inherit (lib) types;
  inherit (config.networking) hostName;

  host = toString (lib.throwIfNot (hostName != null) "networking.hostName must be set" hostName);

  # The list of systems that this host can build for.
  # cf. https://stackoverflow.com/q/78649070/55246
  supportedSystems =
    let
      extra-systems =
        # on Darwin, nix.conf's extra-platforms is a string, as opposed to a list (as on NixOS)
        if isDarwin then
          if lib.hasAttr "extra-platforms" config.nix.settings then
            lib.strings.splitString " " config.nix.settings.extra-platforms
          else
            [ ]
        else
          config.nix.settings.extra-platforms or [ ];
      host-system = config.nixpkgs.hostPlatform.system;
    in
    lib.unique ([ host-system ] ++ extra-systems);
  for = lib.flip map;
  forAttr = lib.flip lib.mapAttrsToList;
  # For input n, return [1..n]
  range = lib.genList (i: i + 1);
  # Poor man's zero-padding for numbers upto 99.
  paddedNum = n: if n < 10 then "0${toString n}" else toString n;

  # Labels for our runners (used to select them in workflows)
  #
  # The following labels are use:
  # - Hostname of the runner
  # - Nix systems it can build for.
  #
  # In workflow file, we expect the user to use the Nix system as label usually.
  extraLabels = [ host ] ++ supportedSystems;

  # Packages that will be made available to all runners.
  extraPackages =
    let
      # https://github.com/actions/upload-pages-artifact/blob/56afc609e74202658d3ffba0e8f6dda462b719fa/action.yml#L40
      gtar = pkgs.runCommandNoCC "gtar" { } ''
        mkdir -p $out/bin
        ln -s ${lib.getExe pkgs.gnutar} $out/bin/gtar
      '';
    in
    with pkgs;
    [
      # For nix builds
      nix
      nixci
      # For those that use Cachix
      cachix

      # Tools already available in standard GitHub Runners; so we provide
      # them here:
      coreutils
      which
      jq

      # Used in well-known GitHub Action workflows
      gtar
    ];

  runnerPackage =
    if config.services.github-nix-ci.cacheServer.enable then
      # https://gha-cache-server.falcondev.io/getting-started#binary-patch
      pkgs.github-runner.overrideAttrs (old: {
        postFixup = (old.postFixup or "") + ''
           dll="$out/lib/github-runner/Runner.Worker.dll"
           if [ ! -f "$dll" ]; then
             echo "github-nix-ci.nix:patchedRunner: Runner.Worker.dll not found at $dll" >&2
             exit 1
           fi

          sed -i 's/\x41\x00\x43\x00\x54\x00\x49\x00\x4F\x00\x4E\x00\x53\x00\x5F\x00\x52\x00\x45\x00\x53\x00\x55\x00\x4C\x00\x54\x00\x53\x00\x5F\x00\x55\x00\x52\x00\x4C\x00/\x41\x00\x43\x00\x54\x00\x49\x00\x4F\x00\x4E\x00\x53\x00\x5F\x00\x52\x00\x45\x00\x53\x00\x55\x00\x4C\x00\x54\x00\x53\x00\x5F\x00\x4F\x00\x52\x00\x4C\x00/g' $dll 
        '';
      })
    else
      pkgs.github-runner;

  # Runner configuration
  common = {
    inherit extraLabels;
    enable = true;
    replace = true;
    ephemeral = true;
    noDefaultLabels = true;
    package = runnerPackage;
    extraPackages = extraPackages ++ config.services.github-nix-ci.runnerSettings.extraPackages;
  }
  // lib.optionalAttrs isLinux { inherit user group; };
  user = "github-runner";
  group = "github-runner";

in
{
  options = {
    services.github-nix-ci = lib.mkOption {
      type = types.submodule {
        options = {
          age.secretsDir = lib.mkOption {
            type = types.nullOr types.path;
            default = null;
            description = ''
              The directory where agenix secrets are stored

              If set to non-null, the age secrets will be scaffolded
              automatically. 
            '';
          };

          cacheServer = {
            enable = lib.mkEnableOption "github actions cache server";
            port = lib.mkOption {
              type = lib.types.port;
              default = 3002;
            };
          };

          runnerSettings = {
            extraPackages = lib.mkOption {
              type = types.listOf types.package;
              default = [ ];
              description = ''
                Extra packages to be installed on all runners
              '';
            };
          };

          orgRunners = lib.mkOption {
            type = types.attrsOf (
              types.submodule (
                { config, name, ... }:
                {
                  options = {
                    num = lib.mkOption {
                      type = types.int;
                    };

                    tokenFile = lib.mkOption {
                      type = types.path;
                      description = "The path to the token file for this runner";
                      default = top.config.age.secrets."github-nix-ci/${name}.token.age".path;
                      defaultText = "The agenix secret file at the conventional path";
                    };

                    url = lib.mkOption {
                      type = types.str;
                      default = "https://github.com/${name}";
                      readOnly = true;
                    };

                    runnerOverrides = lib.mkOption {
                      type = types.submodule {
                        freeformType = types.attrsOf types.anything;
                        options = { };
                      };
                      default = { };
                      description = ''
                        Overrides for services.github-runners.<name> options
                      '';
                    };

                    output.runners = lib.mkOption {
                      type = types.raw;
                      default = lib.listToAttrs (
                        for (range config.num) (
                          i:
                          lib.nameValuePair "${host}-${name}-${paddedNum i}" (
                            lib.mkMerge [
                              common
                              config.runnerOverrides
                              {
                                inherit (config) tokenFile url;
                              }
                            ]
                          )
                        )
                      );
                    };
                  };
                }
              )
            );
            default = { };
          };

          personalRunners = lib.mkOption {
            type = types.attrsOf (
              types.submodule (
                { config, name, ... }:
                {
                  options = {
                    num = lib.mkOption {
                      type = types.int;
                    };

                    tokenFile = lib.mkOption {
                      type = types.path;
                      description = "The path to the token file for this runner";
                      default = top.config.age.secrets."github-nix-ci/${config.output.user}.token.age".path;
                      defaultText = "The agenix secret file at the conventional path";
                    };

                    url = lib.mkOption {
                      type = types.str;
                      default = "https://github.com/${config.output.user}/${config.output.repo}";
                      readOnly = true;
                    };

                    runnerOverrides = lib.mkOption {
                      type = types.submodule {
                        freeformType = types.attrsOf types.anything;
                        options = { };
                      };
                      default = { };
                      description = ''
                        Overrides for services.github-runners.<name> options
                      '';
                    };

                    output.user = lib.mkOption {
                      type = types.str;
                      default =
                        let
                          parts = lib.splitString "/" name;
                        in
                        if lib.length parts == 2 then builtins.elemAt parts 0 else abort "Invalid user/repo";
                    };
                    output.repo = lib.mkOption {
                      type = types.str;
                      default =
                        let
                          parts = lib.splitString "/" name;
                        in
                        if lib.length parts == 2 then builtins.elemAt parts 1 else abort "Invalid user/repo";
                    };
                    output.runners = lib.mkOption {
                      type = types.raw;
                      default = lib.listToAttrs (
                        for (range config.num) (
                          i:
                          lib.nameValuePair "${host}-${config.output.user}-${config.output.repo}-${paddedNum i}" (
                            lib.mkMerge [
                              common
                              config.runnerOverrides
                              {
                                inherit (config) tokenFile url;
                              }
                            ]
                          )
                        )
                      );
                    };
                  };
                }
              )
            );
            default = { };
          };

          output.runner.owner = lib.mkOption {
            type = types.str;
            default = if isDarwin then "_github-runner" else "github-runner";
            description = "The owner of the runner process";
          };
        };
      };
      default = { };
    };
  };
  config = lib.mkMerge [
    {
      # ---- github-runners ---- #
      # Each org gets its own set of runners. There will be at max `num` parallels
      # CI builds for this org / host combination.
      services.github-runners =
        let
          runners =
            forAttr config.services.github-nix-ci.personalRunners (_: cfg: cfg.output.runners)
            ++ forAttr config.services.github-nix-ci.orgRunners (_: cfg: cfg.output.runners);
        in
        builtins.foldl' (
          a: b:
          lib.mkMerge [
            a
            b
          ]
        ) { } runners;

      # ---- age secrets ---- #
      age.secrets =
        let
          inherit (config.services.github-nix-ci.age) secretsDir;
          ageSecretConfigFor =
            name:
            let
              fname = "github-nix-ci/${name}.token.age";
            in
            lib.nameValuePair fname {
              inherit (config.services.github-nix-ci.output.runner) owner;
              file = "${secretsDir}/${fname}";
            };
        in
        lib.mkIf (secretsDir != null) (
          lib.listToAttrs (
            forAttr config.services.github-nix-ci.orgRunners (name: _: ageSecretConfigFor name)
            ++ forAttr config.services.github-nix-ci.personalRunners (
              name: cfg: ageSecretConfigFor cfg.output.user
            )
          )
        );

      # ---- user (linux only) ---- #
      users.users.${user} = lib.mkIf isLinux {
        inherit group;
        isSystemUser = true;
      };
      users.groups.${group} = lib.mkIf isLinux { };
      nix.settings.trusted-users = [
        (if isLinux then user else "_github-runner")
      ];
    }

    # ---- cache server ---- #
    # based on
    # https://gha-cache-server.falcondev.io/getting-started
    # https://github.com/falcondev-oss/github-actions-cache-server
    (lib.mkIf config.services.github-nix-ci.cacheServer.enable {
      virtualisation.docker.enable = true;
      virtualisation.oci-containers.backend = "docker";

      virtualisation.oci-containers.containers.cache-server = {
        image = "ghcr.io/falcondev-oss/github-actions-cache-server:latest";
        ports = [ "${toString config.services.github-nix-ci.cacheServer.port}:3000" ];
        environment = {
          API_BASE_URL = "http://localhost:${toString config.services.github-nix-ci.cacheServer.port}";

          STORAGE_DRIVER = "filesystem";
          STORAGE_FILESYSTEM_PATH = "/data/cache";

          DB_DRIVER = "sqlite";
          DB_SQLITE_PATH = "/data/cache-server.db";

          CACHE_CLEANUP_OLDER_THAN_DAYS = "30";
        };
        volumes = [ "cache-data:/data" ];
        autoStart = true;
      };

      # systemd.tmpfiles.rules = [
      #   "d ${toString config.services.github-nix-ci.cacheServer.dataDir} 0750 root root -"
      # ];

      networking.firewall.allowedTCPPorts = [ config.services.github-nix-ci.cacheServer.port ];
    })

  ];

}
