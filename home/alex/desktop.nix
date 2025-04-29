{ config, pkgs, ... }:

{
  xdg.desktopEntries = {
    hyprpicker = {
      name = "Hyprpicker";
      genericName = "Color Picker";
      exec = "hyprpicker -a";
      terminal = false;
      categories = [ "Graphics" "Utility" ];
      startupNotify = true;
      comment = "A color picker for Hyprland";
    };
  };
}
