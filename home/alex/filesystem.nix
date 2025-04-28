# This file configures the user's directory structure using xdg.userDirs.
# It ensures that standard XDG directories are properly set up and creates
# custom directories for specific purposes.

{ config, pkgs, ... }:

{
  xdg.userDirs = {
    enable = true;
    createDirectories = true;
    extraConfig = {
      # Create a custom directory for code
      XDG_CODE_DIR = "${config.home.homeDirectory}/code";
    };
  };
}
