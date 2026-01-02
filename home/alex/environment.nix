{
  config,
  pkgs,
  lib,
  ...
}:
let
  homeDir = config.home.homeDirectory;

  env = {
    EDITOR = "nvim";
    TERMINAL = "kitty";
    BROWSER = "firefox";
    NIXOS_OZONE_WL = "1";

    # NIXPKGS_ALLOW_UNFREE = "1";
    # POMO = homeDir + "/.config/pomo";
    # PNPM_HOME = homeDir + "/.local/share/pnpm";

    PLAYWRIGHT_BROWSERS_PATH = "${pkgs.playwright-driver.browsers}";
    PLAYWRIGHT_SKIP_VALIDATE_HOST_REQUIREMENTS = "true";

  };

  hyprEnv = {
    # only things that should apply when Hyprland runs
    MOZ_ENABLE_WAYLAND = "1";

    XDG_CURRENT_DESKTOP = "Hyprland";
    XDG_SESSION_DESKTOP = "Hyprland";
    XDG_SESSION_TYPE = "wayland";

    CLUTTER_BACKEND = "wayland";
    GDK_BACKEND = "wayland, x11";
    GDK_SCALE = "1";

    QT_QPA_PLATFORM = "wayland;xcb";
    QT_WAYLAND_DISABLE_WINDOWDECORATION = "1";
    QT_SCALE_FACTOR = "1";

    LIBVA_DRIVER_NAME = "nvidia";
    __GLX_VENDOR_LIBRARY_NAME = "nvidia";

    SDL_VIDEODRIVER = "wayland";

    AQ_DRM_DEVICES = "/dev/dri/card1";

    ELECTRON_OZONE_PLATFORM_HINT = "1";

    NVD_BACKEND = "direct";

    HYPRCURSOR_SIZE = "24";
    HYPRCURSOR_THEME = "rose-pine-hyprcursor";
  };

in
{
  home.sessionVariables = env;

  wayland.windowManager.hyprland.settings.env = lib.mapAttrsToList (k: v: "${k},${v}") hyprEnv;

  # aliases, prompt, functions...
  programs.bash.initExtra = '''';

  home.sessionPath = [
    "${homeDir}/.config/pomo"
    "${homeDir}/.local/share/pnpm"
  ];
}
