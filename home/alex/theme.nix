{ pkgs, lib, ... }:

{
  services.xsettingsd.enable = true;
  gtk = lib.mkIf pkgs.stdenv.isLinux {
    enable = true;
    theme = {
      package = pkgs.rose-pine-gtk-theme;
      name = "rose-pine";
    };
    iconTheme = {
      package = pkgs.papirus-icon-theme;
      name = "Papirus-Dark";
    };
    font = {
      name = "JetBrainsMono";
      size = 11;
    };
  };
}
