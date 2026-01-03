{ pkgs, lib, ... }:
let
  isLinux = pkgs.stdenv.isLinux;
in
{
  home.packages =
    with pkgs;
    [
      # Google drive
      rclone
      fuse

      # Waybar
      nerd-fonts.jetbrains-mono
      inotify-tools
      file

      tidal-hifi

      timewarrior

      firefox-devedition
      thunderbird # Email client

      #
      # Development
      #
      jq
      bun
      pnpm
      nodejs_24
      nodejs_24.pkgs.aws-cdk # AWS CDK globally installed
      nodejs_24.pkgs.prettier
      typescript
      tailwindcss_4
      cargo # For building rust
      lua
      playwright-test
      playwright-driver.browsers

      # Formatters
      prettierd # Prettier
      stylua # Formatting for .lua
      eslint_d # Eslint
      nixfmt # Nix formatter

      dart-sass # SASS globally installed
      imagemagick # Image manipulation
      socat # Socket connection
      mkcert # Certificate generation
      awscli2 # AWS CLI
      aws-sam-cli # AWS SAM CLI
      lsof # List open files
      typst # Latex alternative
      pandoc # Document conversion
      # Go
      go # Go programming language

      discord # Discord - maybe in the future change to a better client
      hyprpicker # Color picker
      hyprshot # Screenshot tool
      # jetbrains.datagrip # Database client
      insomnia # API client
      yaak # API client
      drawio # Drawio desktop

      # Resource monitoring
      btop # Better top
      nvtopPackages.nvidia # Nvidia top

      # Dynamo local
      dynamodb-local
      nosql-workbench

      # cli tools
      libarchive # Unzipping etc bsdtar -xf Sue_Ellen_Francisco.zip
      zip # Easier zipping
      ripgrep # faster grep - Used by nvim plugs
      tree

      lynx # Used by nvim plugs
      lua51Packages.tiktoken_core # Used by copilot-chat nvim: https://github.com/CopilotC-Nvim/CopilotChat.nvim#optional-dependencies
      gnumake # Make
      openssl # OpenSSL
      obsidian # Note taking
      kitty # Terminal emulator
      tmux # Terminal multiplexer
      webfontkitgenerator # Generating fonts
      # polypane # Browser dev tool - REMOVED from nix packages due to lack of support

      #
      # Nvim
      #
      tree-sitter
      ripgrep
      fd
      lazygit
      neovim-remote
      tmuxinator

      # lsp
      lua-language-server # Lua
      svelte-language-server # Svelte
      typescript-language-server # TS
      tailwindcss-language-server # Tailwind
      nixd # Nix
      yaml-language-server # yaml
      vscode-langservers-extracted # JSON
      mdx-language-server # MDX
      bash-language-server # Bash
      glsl_analyzer # Shaders
      gopls # Go language server

    ]
    ++ lib.optionals isLinux (
      with pkgs;
      [
        # Hyprland
        hyprsunset
        hyprpaper

        # File system tools
        xfce.thunar # File manager
        xfce.tumbler # Thumbnailing service
        xfce.thunar-volman # Volume management

        mako # Notification daemon
        libnotify
        hyprpolkitagent # Auth agent

        tofi # App selector

        # Settings
        wdisplays # display settings
        pavucontrol # volume manager
        wlogout # logout/lock GUI
      ]
    );
}
