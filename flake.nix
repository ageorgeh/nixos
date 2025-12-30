{
  description = "NixOS config with NVIDIA + GNOME + Home Manager";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.05";
    flake-utils.url = "github:numtide/flake-utils";
    agenix.url = "github:ryantm/agenix";
    home-manager = {
      url = "github:nix-community/home-manager/release-25.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
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

  outputs = inputs@{ self, nixpkgs, flake-utils, clipboard-sync, home-manager, nur, ... }:
    let
      mkPkgs = system: import nixpkgs {
        inherit system;
        config.allowUnfree = true;
        overlays = [ nur.overlays.default ];
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
