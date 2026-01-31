{
  description = "NixOS config with NVIDIA + GNOME + Home Manager";

  inputs = {
    # NixOS
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };

  
    darwin = {
      url = "github:LnL7/nix-darwin/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-homebrew = {
      url = "github:zhaofengli-wip/nix-homebrew";
    };
    homebrew-bundle = {
      url = "github:homebrew/homebrew-bundle";
      flake = false;
    };
    homebrew-core = {
      url = "github:homebrew/homebrew-core";
      flake = false;
    };
    homebrew-cask = {
      url = "github:homebrew/homebrew-cask";
      flake = false;
    };


    # https://github.com/nix-community/nix4vscode
    # This is an alternative and might be better but requires unstable (as does the below)
    # i think when nix4vscode works with a stable channel we should switch to that
    nix-vscode-extensions = {
      url = "github:nix-community/nix-vscode-extensions";
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

    # https://sakshatshinde.github.io/hyprcursor-themes/
    rose-pine-hyprcursor = {
      url = "github:ndom91/rose-pine-hyprcursor";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.hyprlang.follows = "hyprland/hyprlang";
    };

    # secrets
    agenix = {
      url = "github:ryantm/agenix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # firefox addons
    nur = {
      url = "github:nix-community/NUR";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    clipboard-sync = {
      url = "github:dnut/clipboard-sync";
      inputs.nixpkgs.follows = "nixpkgs";
    };

  };

  outputs =
    inputs@{
      nixpkgs,
      clipboard-sync,
      home-manager,
      # darwin
      darwin,
      nix-homebrew,
      homebrew-core,
      homebrew-cask,
      homebrew-bundle,
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
          overlays = [ overlays.default ];
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
      };

      darwinConfigurations = {
        laptop = darwin.lib.darwinSystem {
          system  = "aarch64-darwin";
          pkgs = mkPkgs "aarch64-darwin";
          specialArgs = { inherit inputs; };
          modules = [
            home-manager.darwinModules.home-manager
            nix-homebrew.darwinModules.nix-homebrew
            {
              nix-homebrew = {
                user = "alex";
                enable = true;
                taps = {
                  "homebrew/homebrew-core" = homebrew-core;
                  "homebrew/homebrew-cask" = homebrew-cask;
                  "homebrew/homebrew-bundle" = homebrew-bundle;
                };
                mutableTaps = false;
                autoMigrate = true;
              };
            }
            ./hosts/laptop/default.nix
          ];
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
      } ;
        
    };
}
