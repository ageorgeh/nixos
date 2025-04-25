{ config, pkgs, ... }:

{
  # Hyprland
  wayland.windowManager.hyprland = {
    enable = true;
    package = null; # use the system-installed Hyprland
    portalPackage = null; # same for xdg-desktop-portal-hyprland
    systemd.variables = [ "--all" ]; # Fixes missing PATH in services

    settings = {
      exec-once = [
        "waybar"
      ];
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
}
