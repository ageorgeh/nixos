{ config, pkgs, ... }:

{
  # home.pointerCursor = {
  #   gtk.enable = true;
  #   package = pkgs.bibata-cursors;
  #   name = "Bibata-Modern-Classic";
  #   size = 24;
  # };


  gtk = {

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
      name = "Sans";
      size = 11;
    };


    # enable = true;

    # theme = {
    #   name = "rose-pine";
    #   package = pkgs.rose-pine-gtk-theme;
    # };

    # # iconTheme = {
    # #   name = "rose-pine"; # or any icon theme you prefer
    # #   package = pkgs.rose-pine-icon-theme;
    # # };

    # gtk3.extraConfig = {
    #   gtk-application-prefer-dark-theme = 0;
    # };

    # gtk4.extraConfig = {
    #   gtk-application-prefer-dark-theme = 0;
    # };

    # font = {
    #   name = "JetBrainsMono";
    #   size = 11;
    # };
  };

  home.file."Pictures/wallpapers" = {
    recursive = true;
    source = ./wallpapers;
  };

}
