{
  description = "NixOS config with NVIDIA + GNOME + Home Manager";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";
    # TODO remove this once unstable has 1.146.0 of aws sam
    nixpkgs-sam-pr.url = "github:NixOS/nixpkgs/pull/459380/head";
    flake-utils.url = "github:numtide/flake-utils";
    home-manager = {
      url = "github:nix-community/home-manager/release-25.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    # secrets
    agenix = {
      url = "github:ryantm/agenix";
    };

    # firefox addons
    nur = {
      url = "github:nix-community/NUR";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    hyprland.url = "github:hyprwm/Hyprland";

    hyprland-plugins = {
      url = "github:hyprwm/hyprland-plugins";
      inputs.hyprland.follows = "hyprland";
    };

    hy3 = {
      url = "github:outfoxxed/hy3";
      inputs.hyprland.follows = "hyprland";
    };

    clipboard-sync.url = "github:dnut/clipboard-sync";

    rose-pine-hyprcursor = {
      url = "github:ndom91/rose-pine-hyprcursor";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.hyprlang.follows = "hyprland/hyprlang";
    };
  };

  outputs = inputs@{ self, nixpkgs, nixpkgs-sam-pr, flake-utils, clipboard-sync, home-manager, nur, ... }:
    let
      mkPkgs = system:
        let
          pkgsPr = import nixpkgs-sam-pr {
            inherit system;
            config.allowUnfree = true;
          };
        in
        import nixpkgs {
          inherit system;
          config.allowUnfree = true;
          overlays = [
            (final: prev: {
              # pull the PR versions 
              aws-sam-cli = pkgsPr.aws-sam-cli;
              # PR also updates these; overriding them prevents mixed-version issues
              python312Packages = prev.python312Packages.override (pyFinal: pyPrev: {
                aws-lambda-builders = pkgsPr.python312Packages.aws-lambda-builders;
                ruamel-yaml = pkgsPr.python312Packages.ruamel-yaml;
              });
            })
            nur.overlays.default
          ];
        };

      mkHost = { hostName, system ? "x86_64-linux" }:
        let
          pkgs = mkPkgs system;
        in
        nixpkgs.lib.nixosSystem {
          inherit system pkgs;

          specialArgs = { inherit inputs; };

          modules = [
            # host entrypoint
            (./hosts + "/${hostName}/default.nix")

            # shared integrations
            home-manager.nixosModules.home-manager
            clipboard-sync.nixosModules.default
          ];
        };
    in
    {
      nixosConfigurations = {
        workstation = mkHost { hostName = "workstation"; };
        # media = mkHost { hostName = "media"; };
        # laptop = mkHost { hostName = "laptop"; };
      };

      homeConfigurations = {
        alex-darwin = home-manager.lib.homeManagerConfiguration {
          pkgs = mkPkgs "aarch64-darwin";
          extraSpecialArgs = { inherit inputs; hostName = "laptop"; };
          modules = [ ./home/alex/default.nix ];
        };
      };
    };
}
