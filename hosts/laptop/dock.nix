{}:

{
imports= [
    ../../modules/darwin/dock
];
local.dock = {
    enable   = false;
    username = user;
    entries  = [
      # { path = "${pkgs.alacritty}/Applications/Alacritty.app/"; }
      { path = "/System/Applications/Music.app/"; }
      { path = "/System/Applications/Photos.app/"; }
      # { path = "${pkgs.jetbrains.phpstorm}/Applications/PhpStorm.app/"; }
      # { path = "/Applications/TablePlus.app/"; }
      { path = "/Applications/Claude.app/"; }
      { path = "/Applications/Discord.app/"; }
      { path = "/Applications/TickTick.app/"; }
      { path = "/System/Applications/Home.app/"; }
      {
        path    = toString myEmacsLauncher;
        section = "others";
      }
      {
        path    = "${config.users.users.${user}.home}/.local/share/";
        section = "others";
        options = "--sort name --view grid --display folder";
      }
      {
        path    = "${config.users.users.${user}.home}/.local/share/downloads";
        section = "others";
        options = "--sort name --view grid --display stack";
      }
    ];
  };
}