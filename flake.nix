{
  description = "NixOS config with NVIDIA + GNOME + Home Manager";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";
    # TODO remove this once unstable has 1.146.0 of aws sam
    nixpkgs-sam-pr.url = "github:NixOS/nixpkgs/pull/459380/head";
    home-manager = {
      url = "github:nix-community/home-manager/release-25.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # hyprland
    hyprland.url = "github:hyprwm/Hyprland";
    hyprland-plugins = {
      url = "github:hyprwm/hyprland-plugins";
      inputs.hyprland.follows = "hyprland";
    };
    hy3 = {
      url = "github:outfoxxed/hy3";
      inputs.hyprland.follows = "hyprland";
    };
    rose-pine-hyprcursor = {
      url = "github:ndom91/rose-pine-hyprcursor";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.hyprlang.follows = "hyprland/hyprlang";
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

    clipboard-sync.url = "github:dnut/clipboard-sync";

  };

  outputs =
    inputs@{
      nixpkgs,
      clipboard-sync,
      home-manager,
      self,
      ...
    }:
    let
      overlays = import ./overlays/default.nix {
        inherit inputs;
      };

      mkPkgs =
        system:
        import nixpkgs {
          inherit system;
          overlays = overlays.default;
          config.allowUnfree = true;
        };

      mkHost =
        {
          hostName,
          system ? "x86_64-linux",
          wayland ? false,
        }:
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
          ]
          ++ nixpkgs.lib.optionals wayland [ clipboard-sync.nixosModules.default ];
        };
    in
    {
      inherit overlays;
      overlay = overlays.default;

      # local
      lib = import ./lib/default.nix { };

      nixosConfigurations = {
        workstation = mkHost {
          hostName = "workstation";
          wayland = true;
        };
        media = mkHost { hostName = "media"; };
        # laptop = mkHost { hostName = "laptop"; };
      };

      homeConfigurations = {
        alex-darwin = home-manager.lib.homeManagerConfiguration {
          pkgs = mkPkgs "aarch64-darwin";
          extraSpecialArgs = {
            inherit inputs;
            hostName = "laptop";
          };
          modules = [ ./home/alex/default.nix ];
        };
      };
    };
}
