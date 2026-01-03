{
  inputs,
  pkgs,
  lib,
  ...
}:
let
  isLinux = pkgs.stdenv.isLinux;
in
{
  imports = [
    inputs.agenix.homeManagerModules.default

    ./programs.nix # programs (with options)
    ./packages.nix # list of packages

    ./ssh.nix # SSH config
    ./secrets.nix # age secrets config

    ./shell.nix # Shell aliases
    ./environment.nix # Env variables

    ./filesystem.nix # home files

    ./hyprland.nix # Hyprland config
    ./theme.nix # gtk theme config

    ./desktop.nix # xdg desktop entries
    ./systemd.nix # User daemons
  ];

  home.username = "alex";
  home.homeDirectory = if pkgs.stdenv.isDarwin then "/Users/alex" else "/home/alex";
  home.stateVersion = "24.11";

  programs.home-manager.enable = true;
}
