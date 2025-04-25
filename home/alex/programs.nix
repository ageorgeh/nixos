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
  xdg.configFile."waybar/config".source = ./dotfiles/config/waybar/config;
  xdg.configFile."waybar/style.css" = {
    source = ./dotfiles/config/waybar/style.css;
    force = true;
  };

}
