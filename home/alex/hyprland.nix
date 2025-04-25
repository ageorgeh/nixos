{ config, inputs, pkgs, ... }:

{
  # Hyprland
  wayland.windowManager.hyprland = {
    enable = true;
    package = null; # use the system-installed Hyprland
    portalPackage = null; # same for xdg-desktop-portal-hyprland
    systemd.variables = [ "--all" ]; # Fixes missing PATH in services

    plugins = [
    ];


    settings = {

      general = {
        layout = "dwindle";
        gaps_in = 4;
        gaps_out = 4;
        border_size = 1;
        resize_on_border = true;
        "col.active_border" = "rgb(89b4fa) rgb(f5c2e7) 45deg";
        "col.inactive_border" = "rgb(313244)";
      };

      dwindle = {
        pseudotile = true;
        preserve_split = true;
      };

      decoration = {
        rounding = 10;
        blur = {
          enabled = true;
          size = 5;
          passes = 3;
          ignore_opacity = false;
          new_optimizations = true;
        };
        shadow = {
          enabled = true;
          range = 4;
          render_power = 3;
          color = "rgba(1a1a1aee)";
        };
      };

      ecosystem = {
        no_donation_nag = true;
      };


      exec-once = [
        "waybar"
        "mako"
        "hyprpolkitagent"
        "hyprpaper"
      ];
      animations = {
        enabled = true;

        bezier = [
          "ease, 0.2, 0.0, 0.2, 1.0"
        ];

        animation = [
          "windows, 1, 1, ease"
          "windowsOut, 1, 1, ease"
          "border, 1, 1, ease"
          "fade, 1, 1, ease"
          "workspaces, 1, 1, ease"
        ];
      };
      "$mod" = "SUPER";
      bind =
        [
          "$mod, V, exec, code --ozone-platform=x11"
          "$mod, RETURN, exec, kitty"
          "$mod, F, exec, firefox"
          "$mod, A, exec, wofi --show drun"
          "$mod, Q, killactive"
          "$mod, S, exec, ~/.config/scripts/quicksettings.sh"
          "$mod, G, togglegroup"
          "$mod, TAB, changegroupactive, f"
          "$mod SHIFT, TAB, changegroupactive, b"
          "$mod SHIFT, H, movewindoworgroup, l"
          "$mod SHIFT, L, movewindoworgroup, r"
          "$mod SHIFT, K, movewindoworgroup, u"
          "$mod SHIFT, J, movewindoworgroup, d"
          "$mod, mouse_down, exec, hyprctl -q keyword cursor:zoom_factor $(hyprctl getoption cursor:zoom_factor | awk '/^float.*/ {print $2 * 1.1}')"
          "$mod, mouse_up, exec, hyprctl -q keyword cursor:zoom_factor $(hyprctl getoption cursor:zoom_factor | awk '/^float.*/ {print $2 * 0.9}')"
          "$mod, equal, exec, hyprctl -q keyword cursor:zoom_factor $(hyprctl getoption cursor:zoom_factor | awk '/^float.*/ {print $2 * 1.1}')"
          "$mod, minus, exec, hyprctl -q keyword cursor:zoom_factor $(hyprctl getoption cursor:zoom_factor | awk '/^float.*/ {print $2 * 0.9}')"
          "$mod, KP_ADD, exec, hyprctl -q keyword cursor:zoom_factor $(hyprctl getoption cursor:zoom_factor | awk '/^float.*/ {print $2 * 1.1}')"
          "$mod, KP_SUBTRACT, exec, hyprctl -q keyword cursor:zoom_factor $(hyprctl getoption cursor:zoom_factor | awk '/^float.*/ {print $2 * 0.9}')"
          "$mod SHIFT, mouse_up, exec, hyprctl -q keyword cursor:zoom_factor 1"
          "$mod SHIFT, mouse_down, exec, hyprctl -q keyword cursor:zoom_factor 1"
          "$mod SHIFT, minus, exec, hyprctl -q keyword cursor:zoom_factor 1"
          "$mod SHIFT, KP_SUBTRACT, exec, hyprctl -q keyword cursor:zoom_factor 1"
          "$mod SHIFT, 0, exec, hyprctl -q keyword cursor:zoom_factor 1"
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
