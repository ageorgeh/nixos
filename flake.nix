{
  description = "NixOS config with NVIDIA + GNOME + Home Manager";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.05";
    flake-utils.url = "github:numtide/flake-utils";
    home-manager = {
      url = "github:nix-community/home-manager/release-25.05";
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

  outputs = inputs @ { self, nixpkgs, flake-utils, home-manager, clipboard-sync, hy3, ... }:

    let
      defaultCfg = rec {
        username = "alex";
        homeDirectory = "/home/${username}";
        runtimeRoot = "${homeDirectory}/nixos-config";
        context = self;
      };

      pkgs = import nixpkgs {
        system = "x86_64-linux";
        config = {
          allowUnfree = true;
        };
      };

      loadShell = name: import (./shells + "/${name}.nix") { inherit pkgs; };
    in
    {
      nixosConfigurations.nixos = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = { inherit inputs; };
        modules = [
          ./hosts/configuration.nix
          home-manager.nixosModules.home-manager
          clipboard-sync.nixosModules.default
          {
            nixpkgs.config.allowUnfree = true;
          }
        ];
      };

      homeConfigurations.alex = home-manager.lib.homeManagerConfiguration {
        pkgs = pkgs;
        extraSpecialArgs = {
          inherit inputs; inherit hy3; cfg = defaultCfg;
        };
        modules = [
          ./home/alex/default.nix
        ];
      };

      # nix develop ~/nixos-config#python
      devShells."x86_64-linux"."python" = loadShell "python";


    };
}

