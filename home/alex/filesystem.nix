# This file configures the user's directory structure using xdg.userDirs.
# It ensures that standard XDG directories are properly set up and creates
# custom directories for specific purposes.

{ config, pkgs, ... }:

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

  # Files
  home.file = {
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

  };
}
