{ config, inputs, pkgs, hy3, cfg, ... }:

{
  home.username = "alex";
  home.homeDirectory = "/home/alex";
  home.stateVersion = "24.11";

  programs.home-manager.enable = true;

  home.packages = with pkgs; [
    # Google drive 
    rclone
    fuse 

    # SSH key management
    keychain
    # Waybar
    nerd-fonts.jetbrains-mono
    inotify-tools
    file
    tidal-hifi
    # File system tools 
    xfce.thunar
    xfce.tumbler
    xfce.thunar-volman
    gvfs
    mako # Notification daemon
    hyprpolkitagent # Auth agent

    # Wallpaper
    hyprpaper

    # Settings
    wdisplays # display settings
    pavucontrol # volume manager
    wlogout # logout/lock GUI

    firefox-devedition

    thunderbird # Email client

    # ###########
    # Development
    # ###########
    jq
    bun
    nodejs_24
    nodejs_24.pkgs.pnpm
    nodejs_24.pkgs.aws-cdk # AWS CDK globally installed
    nodejs_24.pkgs.prettier
    typescript
    tailwindcss_4
    cargo # For building rust
    lua

    # Formatters
    prettierd # Prettier
    stylua # Formatting for .lua
    eslint_d # Eslint
    nixpkgs-fmt # Nix formatter

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
    jetbrains.datagrip # Database client
    insomnia # API client
    drawio # Drawio desktop

    # Resource monitoring
    btop # Better top
    nvtopPackages.nvidia # Nvidia top

    # Dynamo local
    dynamodb-local
    nosql-workbench

    libarchive # Unzipping etc
    zip # Easier zipping
    ripgrep # Used by nvim plugs
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

    ];

  imports = [
    ./shell.nix
    ./ssh.nix
    ./cloud.nix
    ./programs.nix
    ./hyprland.nix
    ./theme.nix
    ./filesystem.nix
    ./desktop.nix
    ./xdg.nix
    ./systemd.nix
  ];
}
