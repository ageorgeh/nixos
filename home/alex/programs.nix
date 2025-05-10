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
    package = pkgs.vscode;
    profiles.default.extensions = with pkgs.vscode-extensions; [ ];
  };

  # Vim
  programs.vim.enable = true;

  # Kitty
  programs.kitty.enable = true;

  programs.tofi = {
    enable = true;
    # https://github.com/philj56/tofi/blob/master/doc/config
    settings = {
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
      background-color = "#02061866"; # slate-950
      text-color = "#004f3b"; # emerald-900
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
  # programs.waybar = {
  #   enable = false;
  #   package = pkgs.waybar;
  # };


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


  # Neovim
  programs.neovim = {
    enable = true;
    viAlias = true;
    vimAlias = true;
    withNodeJs = true; # for LSPs like tsserver
    withPython3 = true;
    extraPackages = with pkgs; [
      tree-sitter
      ripgrep
      fd
    ];
  };

  # Moves all config files to ~/.config
  xdg.configFile."" = {
    source = ./dotfiles/config;
    recursive = true;
  };



  # home.file.".config/nvim".source = config.lib.file.mkOutOfStoreSymlink
  #   "${config.home.homeDirectory}/nixos-config/home/alex/temp/nvim";

}
