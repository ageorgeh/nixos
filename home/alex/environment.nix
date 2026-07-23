{
  config,
  pkgs,
  lib,
  ...
}:
let
  homeDir = config.home.homeDirectory;
  isLinux = pkgs.stdenv.isLinux;

  env = {
    EDITOR = "nvim";
    TERMINAL = "kitty";
    BROWSER = "firefox";

    NIXPKGS_ALLOW_UNFREE = "1";
    # POMO = homeDir + "/.config/pomo";

    # To allow global pnpm installs
    PNPM_HOME = homeDir + "/.local/share/pnpm";

    # PLAYWRIGHT_BROWSERS_PATH = "${pkgs.playwright-driver.browsers}";
    # PLAYWRIGHT_SKIP_VALIDATE_HOST_REQUIREMENTS = "true";
    # PLAYWRIGHT_HOST_PLATFORM_OVERRIDE = "ubuntu-24.04";

    VIMRUNTIME = "${pkgs.neovim-unwrapped}/share/nvim/runtime"; # helps vscode find types for lsp
  };

  envLinux = {
    NIXOS_OZONE_WL = "1";
  };

in
{
  home.sessionVariables = env // lib.optionalAttrs isLinux envLinux;

  home.sessionPath = [
    "${homeDir}/.config/pomo"
    "${homeDir}/.local/share/pnpm"
    "${homeDir}/.local/share/pnpm/bin"
  ];
}
