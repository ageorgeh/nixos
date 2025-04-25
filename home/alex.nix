{ config, pkgs, ... }:

{
  home.username = "alex";
  home.homeDirectory = "/home/alex";

  programs.home-manager.enable = true;

  programs.git = {
    enable = true;
    userName = "Alexander Hornung";
    userEmail = "aghornung@gmail.com";
  };

  programs.bash.enable = true;
  programs.zsh.enable = true;
  programs.fzf.enable = true;

  home.shellAliases = {
    code = "code --ozone-platform=x11";
    nixos-build = "sudo nixos-rebuild switch --flake ~/nixos-config#nixos";
    home-build = "home-manager switch --flake ~/nixos-config#alex";
  };

  home.stateVersion = "24.11";


  programs.keepassxc.enable = true;

  home.packages = with pkgs; [
    # Google drive 
    rclone
    rclone-browser
    fuse
    # Nix formatting 
    nixpkgs-fmt
  ];


  systemd.user.services.rclone-gdrive = {
    Unit = {
      Description = "Mount Google Drive 'books' folder with rclone";
      After = [ "graphical-session.target" "default.target" ];
      Wants = [ "graphical-session.target" ];
    };

    Service = {
      Type = "simple";
      ExecStart = ''
        ${pkgs.rclone}/bin/rclone mount \
          --vfs-cache-mode full \
          --vfs-cache-max-age 12h \
          --vfs-cache-max-size 512M \
          --vfs-write-back 10s \
          --poll-interval 10s \
          --dir-cache-time 1m \
          --allow-other \
          gdrive: ${config.home.homeDirectory}/Drive
      '';
      ExecStop = "${pkgs.fuse}/bin/fusermount -u ${config.home.homeDirectory}/Drive";
      Restart = "on-failure";
      RestartSec = 5;
    };

    Install = {
      WantedBy = [ "graphical-session.target" ];
    };
  };

  # VScode
  programs.vscode = {
    enable = true;
    package = pkgs.vscode.fhs;
    profiles.default.extensions = with pkgs.vscode-extensions; [ ];
  };


  # Hyprland
  programs.kitty.enable = true;

  wayland.windowManager.hyprland = {
    enable = true;
    package = null; # use the system-installed Hyprland
    portalPackage = null; # same for xdg-desktop-portal-hyprland
    systemd.variables = [ "--all" ]; # Fixes missing PATH in services

    settings = {
      "$mod" = "SUPER";
      bind =
        [
          "$mod, V, exec, code --ozone-platform=x11"
          "$mod, RETURN, exec, kitty"
          "$mod, F, exec, firefox"
          ", Print, exec, grimblast copy area"
        ]
        ++ (
          builtins.concatLists (builtins.genList
            (i:
              let ws = i + 1;
              in [
                "$mod, code:1${toString i}, workspace, ${toString ws}"
                "$mod SHIFT, code:1${toString i}, movetoworkspace, ${toString ws}"
              ]
            ) 9)
        );
    };
  };

  home.pointerCursor = {
    gtk.enable = true;
    package = pkgs.bibata-cursors;
    name = "Bibata-Modern-Classic";
    size = 16;
  };

  gtk = {
    enable = true;
    theme = {
      package = pkgs.flat-remix-gtk;
      name = "Flat-Remix-GTK-Grey-Darkest";
    };
    iconTheme = {
      package = pkgs.adwaita-icon-theme;
      name = "Adwaita";
    };
    font = {
      name = "Sans";
      size = 11;
    };
  };


}

