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
    hyprshot = {
      name = "Hyprshot";
      genericName = "Screenshot Tool";
      exec = "hyprshot -m region --clipboard-only";
      terminal = false;
      categories = [ "Graphics" "Utility" ];
      startupNotify = true;
      comment = "A screenshot tool for Hyprland";
    };
    insomnia = {
      name = "Insomnia";
      genericName = "API Client";
      exec = "insomnia --use-angle=vulkan";
      terminal = false;
      categories = [ "Development" "Utility" ];
      startupNotify = true;
      comment = "An API client for developers";
    };
  };
}
