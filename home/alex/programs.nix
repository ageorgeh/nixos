{
  pkgs,
  ...
}:
let
  commonVsExtensions = with pkgs.nix-vscode-extensions.vscode-marketplace; [
    ms-vscode-remote.remote-ssh
    ms-vscode-remote.remote-ssh-edit
    ms-vscode.remote-explorer

    mvllow.rose-pine

    openai.chatgpt

    # ms-vscode-remote.remote-wsl # windows?

    # ms-azuretools.vscode-containers
    # ms-vscode-remote.remote-containers
    # docker.docker

    grapecity.gc-excelviewer # csv
    mechatroner.rainbow-csv
    zainchen.json # json
    jock.svg
    jnoortheen.nix-ide

    esbenp.prettier-vscode

    jakob101.relativepath
    gruntfuggly.todo-tree

    spmeesseman.vscode-taskexplorer
    actboy168.tasks
    iulian-radu-at.vscode-tasks-sidebar

    vscodevim.vim
    formulahendry.code-runner
  ];
in
{
  # Git
  programs.git = {
    enable = true;
    settings = {
      user = {
        email = "aghornung@gmail.com";
        name = "Alexander Hornung";
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

    profiles = {
      default = {
        # enableUpdateCheck = false;
        # enableExtensionUpdateCheck = false;

        extensions =
          commonVsExtensions
          ++ (with pkgs.nix-vscode-extensions.vscode-marketplace; [

            # ---- config ---- #
            sumneko.lua
            ms-vscode.makefile-tools
            golang.go

            # ---- python ---- #
            ms-python.black-formatter
            ms-python.isort
            ms-python.vscode-pylance
            ms-python.python
            ms-python.debugpy
            ms-python.vscode-python-envs

            ms-toolsai.jupyter
            ms-toolsai.vscode-jupyter-cell-tags
            ms-toolsai.jupyter-keymap
            ms-toolsai.jupyter-renderers
            ms-toolsai.vscode-jupyter-slideshow

            # ---- web ---- #
            nicoespeon.abracadabra
            dbaeumer.vscode-eslint

            # glsl
            nolanderc.glsl-analyzer
            circledev.glsl-canvas

            george-alisson.html-preview-vscode
            svelte.svelte-vscode
            sebsojeda.vscode-svx
            bradlc.vscode-tailwindcss
            typescriptteam.native-preview

            christian-kohler.npm-intellisense

            # testing
            ms-playwright.playwright
            vitest.explorer

          ]);
      };
    };
  };

  # Vim
  programs.vim.enable = true;

  # Yazi file manager
  # ./dotfiles/config/yazi - for theme configuration
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
            # https://color.firefox.com/?theme=XQAAAAJeAQAAAAAAAABBqYhm849SCia48_6EGccwS-xMDPr6BEKkYVSt2yMiAsBLvzmxZf3j0v9IRknMzArcpsl645Ge7EzJvXkxnR-IdpUfjuoH0j2fU5z119YfdJkFCZr51wD39X1AG95aQjSf047Gsfg1eLa-yQmEuzaYNrnHf14SvHw9S9ScswXTOZbWwmf1JWZimp73kln7qUWzPieoSAtTvOMSnh-_0rQgIAgRFJJmsMtlxHeL_7_RO1PDjOCPnSpqZVvvdez9JEkZPIodlTKsU6P-62x-rt27JQGm6FBGeeFfDv9hn2AA
            firefox-color
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
            # https://color.firefox.com/?theme=XQAAAAJeAQAAAAAAAABBqYhm849SCia48_6EGccwS-xMDPr6BEKkYVSt2yMiAsBLvzmxZf3j0v9IRknMzArcpsl645Ge7EzJvXkxnR-IdpUfjuoH0j2fU5z119YfdJkFCZr51wD39X1AG95aQjSf047Gsfg1eLa-yQmEuzaYNrnHf14SvHw9S9ScswXTOZbWwmf1JWZimp73kln7qUWzPieoSAtTvOMSnh-_0rQgIAgRFJJmsMtlxHeL_7_RO1PDjOCPnSpqZVvvdez9JEkZPIodlTKsU6P-62x-rt27JQGm6FBGeeFfDv9hn2AA
            firefox-color
          ];
        };
      };
    };
  };
}
