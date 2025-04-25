{ config, pkgs, ... }:

{
  programs.git = {
    enable = true;
    userName = "Alexander Hornung";
    userEmail = "aghornung@gmail.com";
  };


  programs.keepassxc.enable = true;


  # VScode
  programs.vscode = {
    enable = true;
    package = pkgs.vscode.fhs;
    profiles.default.extensions = with pkgs.vscode-extensions; [ ];
  };


  programs.kitty.enable = true;


  # Waybar
  programs.waybar = {
    enable = true;
    package = pkgs.waybar;
  };

  xdg.configFile."" = {
    source = ./dotfiles/config;
    recursive = true;
  };

  # xdg.configFile."waybar/config".source = ./dotfiles/config/waybar/config;
  # xdg.configFile."waybar/style.css".source = ./dotfiles/config/waybar/style.css;

  # # Wofi 
  # xdg.configFile."wofi/style.css".source = ./dotfiles/config/wofi/style.css;

  # # Mako
  # xdg.configFile."mako/config".source = ./dotfiles/config/mako/config;

  # # Kitty
  # xdg.configFile."kitty/kitty.conf".source = ./dotfiles/config/kitty/kitty.conf;

  # # Hyprpaper
  # xdg.configFile."hypr/hyprpaper.conf".source = ./dotfiles/config/hypr/hyprpaper.conf;

  # # Quicksettings
  # xdg.configFile."quicksettings.sh".source = ./dotfiles/config/quicksettings.sh;

}
