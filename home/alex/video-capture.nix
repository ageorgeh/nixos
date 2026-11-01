{
  config,
  lib,
  pkgs,
  hostName ? "",
  ...
}:
let
  tools = import ./video-capture {
    inherit pkgs;
    obs = config.programs.obs-studio.finalPackage;
    homeDirectory = config.home.homeDirectory;
  };
in
{
  config = lib.mkIf (pkgs.stdenv.hostPlatform.isLinux && hostName == "workstation") {
    home.packages = [ tools ];
    programs.firefox.profiles.cms-recording = {
      id = 2;
      name = "CMS Recording";
      path = "cms-recording";
      isDefault = false;
    };
    home.file."${config.programs.firefox.profilesPath}/cms-recording/user.js".source =
      tools.firefoxPrefs;
    xdg.configFile."hypr/cms-video.lua".source = tools.workspaceConfig;
  };
}
