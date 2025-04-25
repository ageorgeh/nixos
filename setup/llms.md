# flake.nix

{
description = "NixOS config with NVIDIA + GNOME + Home Manager";

inputs = {
nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
flake-utils.url = "github:numtide/flake-utils";
home-manager = {
url = "github:nix-community/home-manager";
inputs.nixpkgs.follows = "nixpkgs";
};
hyprland.url = "github:hyprwm/Hyprland";
};

outputs = { self, nixpkgs, flake-utils, home-manager, ... }:
{
nixosConfigurations.nixos = nixpkgs.lib.nixosSystem {
system = "x86_64-linux";
modules = [
./hosts/configuration.nix
home-manager.nixosModules.home-manager
{
nixpkgs.config.allowUnfree = true;
}
];
};

      homeConfigurations.alex = home-manager.lib.homeManagerConfiguration {
        pkgs = import nixpkgs {
          system = "x86_64-linux";
          config = {
            allowUnfree = true;
          };
        };

        modules = [
          ./home/alex.nix
        ];
      };

    };

}

# hosts/configuration.nix

{ config, pkgs, ... }:

{
imports = [
./hardware-configuration.nix
];

nix.settings = {
experimental-features = [ "nix-command" "flakes" ];
substituters = ["https://cache.nixos.org/" "https://hyprland.cachix.org"];
trusted-public-keys = ["hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc="];
};

boot.loader.systemd-boot.enable = true;
boot.loader.efi.canTouchEfiVariables = true;

services.xserver.videoDrivers = [ "nvidia" ];
services.gnome.gnome-keyring.enable = true;
security.pam.services.greetd.enableGnomeKeyring = true;
security.pam.services.hyprland.enableGnomeKeyring = true;
security.pam.services.sddm.enableGnomeKeyring = true;

hardware.nvidia = {
modesetting.enable = true;
powerManagement.enable = true;
powerManagement.finegrained = false;
open = false;
nvidiaSettings = true;
};

boot.kernelParams = [ "nvidia-drm.modeset=1" ];

networking.hostName = "nixos";
networking.networkmanager.enable = true;

time.timeZone = "Australia/Melbourne";

i18n.defaultLocale = "en_AU.UTF-8";
i18n.extraLocaleSettings = {
LC_ADDRESS = "en_AU.UTF-8";
LC_IDENTIFICATION = "en_AU.UTF-8";
LC_MEASUREMENT = "en_AU.UTF-8";
LC_MONETARY = "en_AU.UTF-8";
LC_NAME = "en_AU.UTF-8";
LC_NUMERIC = "en_AU.UTF-8";
LC_PAPER = "en_AU.UTF-8";
LC_TELEPHONE = "en_AU.UTF-8";
LC_TIME = "en_AU.UTF-8";
};

services.xserver.enable = true;
services.displayManager.sddm.enable = true;
services.displayManager.defaultSession = "hyprland";
services.displayManager.sddm.autoLogin.enable = false;
programs.hyprland.enable = true;

services.xserver.xkb = {
layout = "au";
variant = "";
};

services.printing.enable = true;

hardware.pulseaudio.enable = false;
security.rtkit.enable = true;
services.pipewire = {
enable = true;
alsa.enable = true;
alsa.support32Bit = true;
pulse.enable = true;
};

users.users.alex = {
isNormalUser = true;
description = "Alexander Hornung";
extraGroups = [ "networkmanager" "wheel" ];
packages = with pkgs; [ ];
};

programs.firefox.enable = true;

environment.systemPackages = with pkgs; [
git home-manager # Needed before user installs so that packages can be fetched
seahorse # GUI for managing stored keyring secrets
];

environment.sessionVariables = {
ELECTRON_OZONE_PLATFORM_HINT = "wayland";
NIXOS_OZONE_WL = "1";
EDITOR = "code --ozone-platform=x11 --wait";
XDG_CURRENT_DESKTOP = "GNOME";
DESKTOP_SESSION = "gnome";
};

environment.etc."fuse.conf".text = ''
user_allow_other
'';

system.stateVersion = "24.11";
}

# home/alex.nix

{ config, pkgs, ... }:

{
home.username = "alex";
home.homeDirectory = "/home/alex";

programs.home-manager.enable = true;

programs.git = {
enable = true;
userName = "Alexander Hornung";
userEmail = "aghornung@gmail.com";
};

programs.bash.enable = true;
programs.zsh.enable = true;
programs.fzf.enable = true;

home.shellAliases = {
code = "code --ozone-platform=x11";
nixos-build = "sudo nixos-rebuild switch --flake ~/nixos-config#nixos";
home-build = "home-manager switch --flake ~/nixos-config#alex";
};

home.stateVersion = "24.11";

programs.keepassxc.enable = true;

home.packages = with pkgs; [
rclone rclone-browser fuse # These are all for google drive mounting
];

systemd.user.services.rclone-gdrive = {
Unit = {
Description = "Mount Google Drive 'books' folder with rclone";
After = [ "graphical-session.target" "default.target" ];
Wants = [ "graphical-session.target" ];
};

    Service = {
      Type = "simple";
      ExecStart = ''
        ${pkgs.rclone}/bin/rclone mount \
          --vfs-cache-mode full \
          --vfs-cache-max-age 12h \
          --vfs-cache-max-size 512M \
          --vfs-write-back 10s \
          --poll-interval 10s \
          --dir-cache-time 1m \
          --allow-other \
          gdrive: ${config.home.homeDirectory}/Drive
      '';
      ExecStop = "${pkgs.fuse}/bin/fusermount -u ${config.home.homeDirectory}/Drive";
      Restart = "on-failure";
      RestartSec = 5;
    };

    Install = {
      WantedBy = [ "graphical-session.target" ];
    };

};

# VScode

programs.vscode = {
enable = true;
package = pkgs.vscode.fhs;
profiles.default.extensions = with pkgs.vscode-extensions; [ ];
};

# Hyprland

programs.kitty.enable = true;

wayland.windowManager.hyprland = {
enable = true;
package = null; # use the system-installed Hyprland
portalPackage = null; # same for xdg-desktop-portal-hyprland
systemd.variables = [ "--all" ]; # Fixes missing PATH in services

    settings = {
      "$mod" = "SUPER";
      bind =
        [
          "$mod, V, exec, code --ozone-platform=x11"
          "$mod, RETURN, exec, kitty"
          "$mod, F, exec, firefox"
          ", Print, exec, grimblast copy area"
        ]
        ++ (
          builtins.concatLists (builtins.genList (i:
            let ws = i + 1;
            in [
              "$mod, code:1${toString i}, workspace, ${toString ws}"
              "$mod SHIFT, code:1${toString i}, movetoworkspace, ${toString ws}"
            ]
          ) 9)
        );
    };

};

home.pointerCursor = {
gtk.enable = true;
package = pkgs.bibata-cursors;
name = "Bibata-Modern-Classic";
size = 16;
};

gtk = {
enable = true;
theme = {
package = pkgs.flat-remix-gtk;
name = "Flat-Remix-GTK-Grey-Darkest";
};
iconTheme = {
package = pkgs.adwaita-icon-theme;
name = "Adwaita";
};
font = {
name = "Sans";
size = 11;
};
};

}
