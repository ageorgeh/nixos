{ config, inputs, pkgs, hy3, ... }:

{
  home.username = "alex";
  home.homeDirectory = "/home/alex";
  home.stateVersion = "24.11";

  programs.home-manager.enable = true;

  home.packages = with pkgs; [
    # Google drive 
    rclone
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
    nodejs_23.pkgs.aws-cdk # AWS CDK globally installed
    dart-sass # SASS globally installed
    imagemagick # Image manipulation
    socat # Socket connection
    mkcert # Certificate generation
    awscli2 # AWS CLI 
    aws-sam-cli # AWS SAM CLI
    lsof # List open files
    # Go
    go # Go programming language
    gopls # Go language server
    discord # Discord - maybe in the future change to a better client
    hyprpicker # Color picker
    hyprshot # Screenshot tool 
    jetbrains.datagrip # Database client
    insomnia # API client
    # Resource monitoring
    btop # Better top
    nvtopPackages.nvidia # Nvidia top
  ];

  imports = [
    ./shell.nix
    ./ssh.nix
    ./cloud.nix
    ./programs.nix
    ./hyprland.nix
    ./theme.nix
    ./filesystem.nix
    ./desktop.nix
    ./xdg.nix
  ];
}
