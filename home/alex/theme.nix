{ pkgs, lib, ... }:

lib.mkIf pkgs.stdenv.isLinux {
  services.xsettingsd.enable = true;
  gtk = {
    enable = true;
    theme = {
      # This should help with finding the theme name once instaled
      # ls /etc/profiles/per-user/alex/share/themes/

      # package = pkgs.rose-pine-gtk-theme;
      # name = "rose-pine";

      # package = pkgs.magnetic-catppuccin-gtk;
      # name = "Catppuccin-GTK-Dark";

      package = pkgs.gruvbox-gtk-theme;
      name = "Gruvbox-Dark";

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
