{
  config,
  pkgs,
  lib,
  hostName ? "",
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

  envWorkstation = {
    RUSTC_WRAPPER = "${pkgs.sccache}/bin/sccache";
    SCCACHE_CACHE_SIZE = "20G";
  };

in
{
  home.sessionVariables =
    env
    // lib.optionalAttrs isLinux envLinux
    // lib.optionalAttrs (isLinux && hostName == "workstation") envWorkstation;

  home.sessionPath = [
    "${homeDir}/.config/pomo"
    "${homeDir}/.local/share/pnpm"
    "${homeDir}/.local/share/pnpm/bin"
  ];
}
