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
    # Application launcher
    wofi
    # Notificaiton daemon
    mako
    # Auth agent
    hyprpolkitagent
    # Wallpaper
    hyprpaper
    # Settings
    wdisplays # display settings
    networkmanagerapplet
    pavucontrol # volume manager
    wlogout # logout/lock GUI
    firefox-devedition
  ];

  imports = [
    ./shell.nix
    ./ssh.nix
    ./cloud.nix
    ./programs.nix
    ./hyprland.nix
    ./theme.nix
  ];
}
