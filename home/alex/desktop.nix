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
    firefox-devedition = {
      name = "Firefox Developer Edition";
      genericName = "Web Browser";
      comment = "Firefox Developer Edition (shared profile)";
      exec = "firefox-devedition -P dev";
      terminal = false;
      categories = [ "Network" "WebBrowser" ];
      startupNotify = true;
      mimeType = [
        "text/html"
        "x-scheme-handler/http"
        "x-scheme-handler/https"
      ];
    };
  };
}
