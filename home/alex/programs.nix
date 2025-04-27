{ config, pkgs, ... }:

{
  # Git
  programs.git = {
    enable = true;
    userName = "Alexander Hornung";
    userEmail = "aghornung@gmail.com";
  };

  # KeepassXC
  programs.keepassxc.enable = true;

  # VScode
  programs.vscode = {
    enable = true;
    package = pkgs.vscode.fhs;
    profiles.default.extensions = with pkgs.vscode-extensions; [ ];
  };

  # Vim
  programs.vim.enable = true;

  # Kitty
  programs.kitty.enable = true;

  # Waybar
  programs.waybar = {
    enable = true;
    package = pkgs.waybar;
  };


  # Wlsunset
  services.wlsunset = {
    enable = true;
    latitude = "-37.813629";
    longitude = "144.963058";
    temperature = {
      day = 5500;
      night = 3700;
    };
  };

  # Moves all config files to ~/.config
  xdg.configFile."" = {
    source = ./dotfiles/config;
    recursive = true;
  };
}
