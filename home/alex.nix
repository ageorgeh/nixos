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

  #test

  home.stateVersion = "24.11";
  
  
  home.packages = with pkgs; [ ];

  # VScode
  programs.vscode = {
    enable = true;
    package = pkgs.vscode.fhs;
    extensions = with pkgs.vscode-extensions; [ ];
  };
  # Needed for wayland vscode
  home.shellAliases = {
    code = "code --ozone-platform=x11";
  };


  # Hyprland
  programs.kitty.enable = true;

  wayland.windowManager.hyprland = {
    enable = true;
    package = null;        # use the system-installed Hyprland
    portalPackage = null;  # same for xdg-desktop-portal-hyprland
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
          builtins.concatLists (builtins.genList (i:
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

