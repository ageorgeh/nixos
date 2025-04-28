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

  programs.tofi = {
    enable = true;
    settings = {
      # drun-launch = true;
      terminal = "kitty";
      "matching-algorithm" = "fuzzy";
      font = "~/.nix-profile/share/fonts/truetype/NerdFonts/JetBrainsMono/JetBrainsMonoNerdFont-Regular.ttf";
      width = "100%";
      height = "100%";
      border-width = "0";
      outline-width = "0";
      padding-left = "35%";
      padding-top = "35%";
      result-spacing = "25";
      background-color = "#000A";
    };
  };


  # Yazi file manager
  # home/alex/dotfiles/config/yazi - for theme configuration
  programs.yazi = {
    enable = true;
    # enableZshIntegration = true;
    # enableBashIntegration = true;
    # shellWrapperName = "kitty";

    settings = {
      manager = {
        show_hidden = true;
      };
      preview = {
        max_width = 1000;
        max_height = 1000;
      };
    };
  };

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
