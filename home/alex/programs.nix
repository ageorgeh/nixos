{
  pkgs,
  config,
  ...
}:

{
  # Git
  programs.git = {
    enable = true;
    signing.format = null;
    settings = {
      user = {
        email = "aghornung@gmail.com";
        name = "Alexander Hornung";
      };
      pull = {
        rebase = false;
      };
    };
  };

  # KeepassXC
  programs.keepassxc.enable = true;

  # vscode
  # currently i do extensions through nix here and then all other vscode config through their UI
  # its too difficult to do it here
  programs.vscode = {
    enable = true;
    package = pkgs.vscode;
    mutableExtensionsDir = false;
  };

  # Vim
  # programs.vim.enable = true;

  # Yazi file manager
  # ./dotfiles/config/yazi - for theme configuration
  programs.yazi = {
    enable = true;
    # enableZshIntegration = true;
    # enableBashIntegration = true;
    shellWrapperName = "y";

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
    withRuby = false;
    sideloadInitLua = true;
    # extraLuaPackages = ps: [ ps.magick ];
    # extraPackages = [ pkgs.imagemagick ];
  };

  # firefox
  programs.firefox = {
    enable = true;
    # configPath = "${config.xdg.configHome}/mozilla/firefox"; # new behavior
    configPath = ".mozilla/firefox"; # legacy behavior
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
            # search here
            # https://nur.nix-community.org/repos/rycee/

            ublock-origin
            keepassxc-browser
            darkreader
            vimium
            floccus
            auto-tab-discard

            # https://color.firefox.com/?theme=XQAAAAJeAQAAAAAAAABBqYhm849SCia48_6EGccwS-xMDPr6BEKkYVSt2yMiAsBLvzmxZf3j0v9IRknMzArcpsl645Ge7EzJvXkxnR-IdpUfjuoH0j2fU5z119YfdJkFCZr51wD39X1AG95aQjSf047Gsfg1eLa-yQmEuzaYNrnHf14SvHw9S9ScswXTOZbWwmf1JWZimp73kln7qUWzPieoSAtTvOMSnh-_0rQgIAgRFJJmsMtlxHeL_7_RO1PDjOCPnSpqZVvvdez9JEkZPIodlTKsU6P-62x-rt27JQGm6FBGeeFfDv9hn2AA
            # firefox-color

            gruvbox-dark-theme
          ];
        };
      };
      dev = {
        id = 1;
        name = "dev";
        isDefault = false;
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
            auto-tab-discard
            # https://color.firefox.com/?theme=XQAAAAJeAQAAAAAAAABBqYhm849SCia48_6EGccwS-xMDPr6BEKkYVSt2yMiAsBLvzmxZf3j0v9IRknMzArcpsl645Ge7EzJvXkxnR-IdpUfjuoH0j2fU5z119YfdJkFCZr51wD39X1AG95aQjSf047Gsfg1eLa-yQmEuzaYNrnHf14SvHw9S9ScswXTOZbWwmf1JWZimp73kln7qUWzPieoSAtTvOMSnh-_0rQgIAgRFJJmsMtlxHeL_7_RO1PDjOCPnSpqZVvvdez9JEkZPIodlTKsU6P-62x-rt27JQGm6FBGeeFfDv9hn2AA
            firefox-color
          ];
        };
      };
    };
  };
}
