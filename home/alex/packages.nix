{ pkgs, lib, ... }:
let
  isLinux = pkgs.stdenv.isLinux;
in
{
  home.packages =
    with pkgs;
    [

      # Waybar
      nerd-fonts.jetbrains-mono
      file

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
      direnv

      # Formatters
      prettierd # Prettier
      stylua # Formatting for .lua
      eslint_d # Eslint
      nixfmt # Nix formatter

      # install via npm for project versioning
      # oxlint
      # oxfmt

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
      # jetbrains.datagrip # Database client
      insomnia # API client
      yaak # API client
      drawio # Drawio desktop

      # Dynamo local
      dynamodb-local
      nosql-workbench

      # cli tools
      libarchive # Unzipping etc bsdtar -xf Sue_Ellen_Francisco.zip
      zip # Easier zipping
      ripgrep # faster grep - Used by nvim plugs
      tree
      util-linux

      lynx # Used by nvim plugs
      lua51Packages.tiktoken_core # Used by copilot-chat nvim: https://github.com/CopilotC-Nvim/CopilotChat.nvim#optional-dependencies
      gnumake # Make
      openssl # OpenSSL
      obsidian # Note taking
      kitty # Terminal emulator
      tmux # Terminal multiplexer
      webfontkitgenerator # Generating fonts
      # polypane # Browser dev tool - REMOVED from nix packages due to lack of support

      # images
      gimp
      loupe

      vlc

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
        # Google drive
        rclone
        fuse

        # Resource monitoring
        btop # Better top
        nvtopPackages.nvidia # Nvidia top
        iperf

        # Hyprland
        hyprsunset
        hyprpaper
        hyprpicker # Color picker
        hyprshot # Screenshot tool

        # File system tools
        thunar # File manager
        tumbler # Thumbnailing service
        thunar-volman # disk volume management

        mako # Notification daemon
        libnotify
        inotify-tools

        hyprpolkitagent # Auth agent

        tofi # App selector

        # Settings
        wdisplays # display settings
        lxqt.pavucontrol-qt # sound volume manager
        wlogout # logout/lock GUI

        tidal-hifi
      ]
    );
}
