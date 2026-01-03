{
  lib,
  config,
  pkgs,
  inputs,
  ...
}:

let
  mkSymlinkAttrs = inputs.self.lib.mkSymlinkAttrs {
    inherit pkgs;
    context = inputs.self;
    runtimeRoot = if pkgs.stdenv.isDarwin then "/Users/alex" else "/home/alex" + "/nixos-config";
    hm = config.lib; # same as: inputs.home-manager.lib.hm;
  };
  isDarwin = pkgs.stdenv.isDarwin;
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

  home.file = {
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
  }
  // lib.optionalAttrs (!isDarwin) {
    # Linux-style font path
    ".local/share/fonts/NerdFonts/JetBrainsMono".source =
      "${pkgs.nerd-fonts.jetbrains-mono}/share/fonts/truetype/NerdFonts/JetBrainsMono";
  }
  // lib.optionalAttrs isDarwin {
    # macOS standard font path
    "Library/Fonts/JetBrainsMono Nerd Font.ttf".source =
      "${pkgs.nerd-fonts.jetbrains-mono}/share/fonts/truetype/NerdFonts/JetBrainsMonoNerdFont-Regular.ttf";
    # Also include for tofi
    ".local/share/fonts/NerdFonts/JetBrainsMono".source =
      "${pkgs.nerd-fonts.jetbrains-mono}/share/fonts/truetype/NerdFonts/JetBrainsMono";

  }
  // (mkSymlinkAttrs {
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
  });
}
