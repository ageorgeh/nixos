{
  inputs,
  pkgs,
  ...
}:

{
  imports = [
    inputs.agenix.homeManagerModules.default

    ./programs.nix # programs (with options)
    ./packages.nix # list of packages

    ./ssh.nix # SSH config
    ./secrets.nix # age secrets config

    ./shell.nix # Shell aliases
    ./environment.nix # Env variables

    ./hyprland.nix # Hyprland config

    ./theme.nix # gtk theme config

    ./filesystem.nix # home files
    ./desktop.nix # Desktop entries

    ./systemd.nix # User daemons
  ];

  home.username = "alex";
  home.homeDirectory = if pkgs.stdenv.isDarwin then "/Users/alex" else "/home/alex";
  home.stateVersion = "24.11";

  programs.home-manager.enable = true;
}
