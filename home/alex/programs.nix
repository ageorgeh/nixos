{ config, pkgs, cfg, ... }:


let
  inherit (config.home) username homeDirectory;

  mkSymlinkAttrs = import ../../lib/mkSymlinkAttrs.nix {
    inherit pkgs;
    inherit (cfg) context runtimeRoot;
    hm = config.lib; # same as: cfg.context.inputs.home-manager.lib.hm;
  };

in
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

  # Neovim
  programs.neovim = {
    enable = true;
    viAlias = true;
    vimAlias = true;
    withNodeJs = true; # for LSPs like tsserver
    withPython3 = true;
    extraPackages = with pkgs; [
    ];
  };

  # firefox
  programs.firefox = {
    enable = true;
    profiles = {
      default = {
        id = 0;
        name = "default";
        isDefault = true;
        settings = {
          "ui.systemUsesDarkTheme" = 1;
          "extensions.autoDisableScopes" = 0;
        };
        extensions = {
          force = true;
          packages = with pkgs.nur.repos.rycee.firefox-addons; [
            ublock-origin
            keepassxc-browser
            darkreader
            vimium
            floccus
          ];
        };
      };
    };
  };


  # Symlink dotfiles
  # Ensure that either you define files in dotfiles/config or define settings in the 
  # 'home-manager' way like above
  home.file = mkSymlinkAttrs {
    ".config" = {
      source = ./dotfiles/config;
      outOfStoreSymlink = true;
      recursive = true;
    };

    ".tmux.conf" = {
      source = ./dotfiles/.tmux.conf;
      outOfStoreSymlink = true;
    };

    "scripts" = {
      source = ./dotfiles/scripts;
      outOfStoreSymlink = true;
      recursive = true;
    };

    ".local/share/fonts/NerdFonts/JetBrainsMono".source =
      "${pkgs.nerd-fonts.jetbrains-mono}/share/fonts/truetype/NerdFonts/JetBrainsMono";
  };


}
