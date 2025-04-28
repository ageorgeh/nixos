{ config, inputs, pkgs, hy3, ... }:

{
  home.username = "alex";
  home.homeDirectory = "/home/alex";
  home.stateVersion = "24.11";

  programs.home-manager.enable = true;

  home.packages = with pkgs; [
    # Google drive 
    rclone
    rclone-browser
    fuse
    # Nix formatting 
    nixpkgs-fmt
    # SSH key management
    keychain
    # Waybar
    nerd-fonts.jetbrains-mono
    inotify-tools
    file
    tidal-hifi
    # File system tools 
    xfce.thunar
    xfce.tumbler
    xfce.thunar-volman
    gvfs
    mako # Notificaiton daemon
    hyprpolkitagent # Auth agent
    # Wallpaper
    hyprpaper
    # Settings
    wdisplays # display settings
    pavucontrol # volume manager
    wlogout # logout/lock GUI
    firefox-devedition
    # Development
    jq
    nodejs_23
    nodejs_23.pkgs.pnpm
    imagemagick # Image manipulation
    socat
    # Go
    go # Go programming language
    gopls # Go language server
    discord
    hyprpicker # Color picker
  ];

  imports = [
    ./shell.nix
    ./ssh.nix
    ./cloud.nix
    ./programs.nix
    ./hyprland.nix
    ./theme.nix
    ./filesystem.nix
  ];
}
