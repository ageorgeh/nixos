{ pkgs, lib, ... }:
let
  isLinux = pkgs.stdenv.isLinux;
  isDarwin = pkgs.stdenv.isDarwin;
in
{
  home.packages =
    with pkgs;
    [
      playwright-driver.browsers

      # Fonts
      nerd-fonts.jetbrains-mono
      atkinson-hyperlegible-mono # Provides "Atkinson Hyperlegible Mono"
      ibm-plex

      file

      timewarrior

      firefox-devedition
      google-chrome
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
      gh

      # Formatters
      prettierd # Prettier
      stylua # Formatting for .lua
      eslint_d # Eslint
      nixfmt # Nix formatter

      dart-sass # SASS globally installed
      imagemagick # Image manipulation
      luajitPackages.magick
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
      ncdu # sudo ncdu --exclude /home/alex/Drive /

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
      typescript-language-server # TS
      vtsls # TS
      svelte-language-server # Svelte
      tailwindcss-language-server # Tailwind
      nixd # Nix
      yaml-language-server # yaml
      vscode-langservers-extracted # JSON
      mdx-language-server # MDX
      bash-language-server # Bash
      glsl_analyzer # Shaders
      gopls # Go language server
      tinymist # Typst

    ]
    ++ lib.optionals isLinux (
      with pkgs;
      [
        # Google drive
        rclone
        fuse
        rsync

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

        # images
        gimp
        loupe

        vlc
      ]
    )
    ++ lib.optionals isDarwin (
      with pkgs;
      [
        vlc-bin
      ]
    );
}
