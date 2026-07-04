{ pkgs, lib, ... }:

let
  browser = "firefox-devedition.desktop";
in
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
    gtk4.theme = {
      package = pkgs.gruvbox-gtk-theme;
      name = "Gruvbox-Dark";
    };
    iconTheme = {
      package = pkgs.papirus-icon-theme;
      name = "Papirus-Dark";
    };
    font = {
      name = "JetBrainsMono Nerd Font";
      size = 11;
    };
  };

  xdg.mimeApps = {
    enable = true;

    # defaultApplications = {
    #   "text/html" = browser;
    #   "text/xml" = browser;
    #   "application/xhtml+xml" = browser;
    #   "application/xml" = browser;
    #   "x-scheme-handler/http" = browser;
    #   "x-scheme-handler/https" = browser;
    #   "x-scheme-handler/about" = browser;
    #   "x-scheme-handler/unknown" = browser;
    # };

    # associations.added = {
    #   "text/html" = browser;
    #   "text/xml" = browser;
    #   "application/xhtml+xml" = browser;
    #   "application/xml" = browser;
    #   "x-scheme-handler/http" = browser;
    #   "x-scheme-handler/https" = browser;
    # };
  };
}
