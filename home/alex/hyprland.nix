{ config, inputs, pkgs, hy3, ... }:

{



  # Hyprland
  wayland.windowManager.hyprland = {
    enable = true;
    # package = null; # use the system-installed Hyprland
    package = inputs.hyprland.packages.${pkgs.system}.default;
    portalPackage = inputs.hyprland.packages.${pkgs.system}.xdg-desktop-portal-hyprland;
    systemd.variables = [ "--all" ]; # Fixes missing PATH in services

    plugins = [
      # inputs.hyprland-plugins.packages.${pkgs.system}.hyprtrails
      # inputs.hyprland-plugins.packages.${pkgs.stdenv.hostPlatform.system}.hyprbars
      inputs.hy3.packages.x86_64-linux.hy3
    ];

    extraConfig = ''
      plugin {
        hy3 {
          no_gaps_when_only = 1
          node_collapse_policy = 2
          group_inset = 10

          autotile {
            enable = false
            trigger_width = 800
            trigger_height = 600
          }
        }
      }
    '';

    settings =
      {

        windowrulev2 = [
          "float, class:(clipse)"
          "size 822 852, class:(clipse)"
          "stayfocused, class:(clipse)"
        ];

        env = [
          "NIXOS_OZONE_WL, 1"
          "NIXPKGS_ALLOW_UNFREE, 1"
          "XDG_CURRENT_DESKTOP, Hyprland"
          "XDG_SESSION_TYPE, wayland"
          "XDG_SESSION_DESKTOP, Hyprland"
          "GDK_BACKEND, wayland, x11"
          "CLUTTER_BACKEND, wayland"
          "QT_QPA_PLATFORM=wayland;xcb"
          "QT_WAYLAND_DISABLE_WINDOWDECORATION, 1"
          "LIBVA_DRIVER_NAME, nvidia"
          "__GLX_VENDOR_LIBRARY_NAME, nvidia"
          "QT_AUTO_SCREEN_SCALE_FACTOR, 1"
          "SDL_VIDEODRIVER, x11"
          "MOZ_ENABLE_WAYLAND, 1"
          "AQ_DRM_DEVICES,/dev/dri/card0:/dev/dri/card1"
          "GDK_SCALE,1"
          "QT_SCALE_FACTOR,1"
          "ELECTRON_OZONE_PLATFORM_HINT, auto"
          "NVD_BACKEND, direct"
          "HYPRCURSOR_THEME, rose-pine-hyprcursor"
          "HYPRCURSOR_SIZE,24"
          "TERMINAL, kitty"
          "EDITOR, nvim"
        ];



        general = {
          layout = "hy3";
          gaps_in = 4;
          gaps_out = 4;
          border_size = 1;
          resize_on_border = true;
          "col.active_border" = "rgb(89b4fa) rgb(f5c2e7) 45deg";
          "col.inactive_border" = "rgb(313244)";
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

        input = {
          sensitivity = -0.4;
        };


        exec-once = [
          "hyprpaper"
          "hyprsunset"
          "waybar"
          "mako"
          "hyprpolkitagent"
          "clipse --listen"
          "sleep 1 && ~/.config/scripts/layout/layout"
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
            "$mod, C, exec, kitty --class clipse -e 'clipse'"
            "$mod, V, exec, code --use-angle=vulkan"
            "$mod, RETURN, exec, kitty"
            "$mod, F, exec, firefox"
            "$mod, A, exec, tofi-drun | xargs -r hyprctl dispatch exec --"
            "$mod, Q, killactive"
            "$mod, PRINT, exec, hyprshot -m section --clipboard-only"
            "$mod, S, exec, ~/.config/scripts/quicksettings.sh"
            "$mod, U, exec, ~/.config/scripts/layout/layout"
            "$mod, G, hy3:makegroup, tab, toggle"
            "$mod, bracketleft, hy3:focustab, r, wrap"
            "$mod, bracketright, hy3:focustab, l, wrap"
            "$mod SHIFT, F, togglefloating"
            "$mod SHIFT, H, hy3:movewindow, l"
            "$mod SHIFT, L, hy3:movewindow, r"
            "$mod SHIFT, J, hy3:movewindow, d"
            "$mod SHIFT, K, hy3:movewindow, u"
            "$mod, H, hy3:movefocus, l, visible"
            "$mod, L, hy3:movefocus, r, visible"
            "$mod, J, hy3:movefocus, d, visible"
            "$mod, K, hy3:movefocus, u, visible"
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
