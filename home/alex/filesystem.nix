# This file configures the user's directory structure using xdg.userDirs.
# It ensures that standard XDG directories are properly set up and creates
# custom directories for specific purposes.

{
  cfg,
  config,
  pkgs,
  inputs,
  ...
}:

let
  mkSymlinkAttrs = inputs.self.lib.mkSymlinkAttrs {
    inherit pkgs;
    inherit (cfg) context runtimeRoot;
    hm = config.lib; # same as: cfg.context.inputs.home-manager.lib.hm;
  };
in
{
  # Directory structure
  xdg.userDirs = {
    enable = true;
    createDirectories = true;
    extraConfig = {
      # Create a custom directory for code
      XDG_CODE_DIR = "${config.home.homeDirectory}/code";
      XDG_AWS_DIR = "${config.home.homeDirectory}/.aws";
    };
  };

  # Symlink dotfiles
  # Ensure that either you define files in dotfiles/config or define settings in the
  # 'home-manager' way like above
  home.file = mkSymlinkAttrs {
    "Pictures/wallpapers" = {
      recursive = true;
      source = ./wallpapers;
    };

    ".aws/config" = {
      text = ''
        [default]
        sso_session = my-sso
        sso_account_id = 471112897136
        sso_role_name = AdministratorAccess
        region = ap-southeast-2

        [sso-session my-sso]
        sso_start_url = https://d-97674522b7.awsapps.com/start/#
        sso_region = ap-southeast-2
        sso_registration_scopes = sso:account:access
      '';
    };
    ".config" = {
      source = ./dotfiles/config;
      outOfStoreSymlink = true;
      recursive = true;
    };

    ".tmux.conf" = {
      source = ./dotfiles/.tmux.conf;
      outOfStoreSymlink = true;
    };

    "scripts" = {
      source = ./dotfiles/scripts;
      outOfStoreSymlink = true;
      recursive = true;
    };

    ".local/share/fonts/NerdFonts/JetBrainsMono".source =
      "${pkgs.nerd-fonts.jetbrains-mono}/share/fonts/truetype/NerdFonts/JetBrainsMono";
  };
}
