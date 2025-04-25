# NixOS Configuration Context for LLMs

Generated on Fri 25 Apr 2025 18:25:22 AEST

## Repository Structure

```
./flake.lock
./flake.nix
./.gitignore
./home/alex/cloud.nix
./home/alex/default.nix
./home/alex/dotfiles/config/waybar/config
./home/alex/dotfiles/config/waybar/scripts/reload
./home/alex/dotfiles/config/waybar/style.css
./home/alex/hyprland.nix
./home/alex/programs.nix
./home/alex/shell.nix
./home/alex/ssh.nix
./home/alex/theme.nix
./hosts/configuration.nix
./hosts/hardware-configuration.nix
./setup/githubSsh.sh
./setup/googleDrive.md
./setup/llms.md
./setup/llms.sh
./setup/nixos-config-context.md
./.vscode/settings.json
```

## NixOS Configuration Files

## File: .gitignore

```
result
```

## File: .vscode/settings.json

```
{
  "editor.fontFamily": "'JetBrainsMono Nerd Font', 'monospace'",
  "editor.fontLigatures": true
}
```

## File: flake.nix

```
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
          ./home/alex/default.nix
        ];
      };

    };
}

```

## File: home/alex/cloud.nix

```
{ config, pkgs, ... }:

{
  systemd.user.services.rclone-gdrive = {
    Unit = {
      Description = "Mount Google Drive with rclone";
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
}
```

## File: home/alex/default.nix

```
{ config, pkgs, ... }:

{
  home.username = "alex";
  home.homeDirectory = "/home/alex";
  home.stateVersion = "24.11";

  programs.home-manager.enable = true;

  home.packages = with pkgs; [
    # Google drive
    rclone
    rclone-browser
    fuse
    # Nix formatting
    nixpkgs-fmt
    # SSH key management
    keychain
    # Waybar
    nerd-fonts.jetbrains-mono
    inotify-tools
    file
  ];

  imports = [
    ./shell.nix
    ./ssh.nix
    ./cloud.nix
    ./programs.nix
    ./hyprland.nix
    ./theme.nix
  ];
}
```

## File: home/alex/dotfiles/config/waybar/config

```
{
  "layer": "top",
  "position": "top",
  "modules-left": [
    "hyprland/workspaces",
    "custom/vscode"
  ],
  "modules-center": [
    "clock"
  ],
  "modules-right": [
    "cpu",
    "memory",
    "temperature",
    "mpd",
    "pulseaudio",
    "network",
    "tray"
  ],
  "hyprland/workspaces": {},
  "clock": {
    "interval": 60,
    "format": "{:%A, %d %B | %I:%M %p}"
  },
  "cpu": {
    "format": "  {usage}%",
    "interval": 2
  },
  "memory": {
    "format": " {used:0.1f}G/{total:0.1f}G",
    "interval": 2
  },
  "temperature": {
    "critical-threshold": 80,
    "format": " {temperatureC}°C",
    "hwmon-path": "/sys/class/thermal/thermal_zone0/temp"
  },
  "mpd": {
    "format": "{artist} - {title}",
    "format-paused": " {artist} - {title}",
    "format-stopped": " Stopped",
    "interval": 5
  },
  "pulseaudio": {
    "format": "{volume}% "
  },
  "network": {
    "format-wifi": "  {essid} ({signalStrength}%)",
    "format-ethernet": "  {ifname}",
    "format-disconnected": "⚠ Disconnected"
  },
  "custom/vscode": {
    "format": " ",
    "tooltip-format": "Open VSCode (SUPER + V)",
    "on-click": "/home/alex/.nix-profile/bin/code --ozone-platform=x11",
    "interval": 3600
  }
}
```

## File: home/alex/dotfiles/config/waybar/scripts/reload

```
#!/usr/bin/env bash

CSS_FILE="$HOME/.config/waybar/style.css"

# Run this for dev
ln -sf /home/alex/nixos-config/home/alex/dotfiles/config/waybar/style.css ~/.config/waybar/style.css

# Ensure inotifywait is installed
if ! command -v inotifywait &>/dev/null; then
  echo "❌ inotifywait (from inotify-tools) is not installed."
  exit 1
fi

echo "👀 Watching $CSS_FILE for changes..."

# Infinite loop to watch for changes
while inotifywait -e close_write "$CSS_FILE"; do
  PID=$(pidof waybar)
  if [ -n "$PID" ]; then
    kill -SIGUSR2 "$PID"
    echo "🔁 Waybar CSS reloaded!"
  else
    echo "❌ Waybar is not running."
  fi
done
```

## File: home/alex/dotfiles/config/waybar/style.css

```
* {
  font-family: "JetBrainsMono Nerd Font", "Sans";
  font-size: 13px;
  padding: 0 12px;
  margin: 0;
  min-height: 28px;
  border: none;
  color: #cdd6f4;
}

window#waybar {
  background: transparent;
  margin: 6px 12px;
  padding: 0 6px;
  box-shadow: 0 4px 16px rgba(0, 0, 0, 0.35);
}

#waybar > box {
  margin: 2px 0;
}

#workspaces button {
  border-radius: 12px;
  padding: 0 10px;
  margin: 0 4px;
  transition: background 0.2s;
}

#workspaces button.focused {
  background: rgba(219, 56, 15, 0.6);
  color: #89b4fa;
}

#workspaces button:hover {
  border-radius: 10px;
  background: transparent;
  margin: 0 6px;
  padding: 0 10px;
  transition: background 0.2s;
  background: #370617;
}

/* Tooltips */
tooltip {
  background: #370617;
  border-radius: 10px;
  padding: 6px 10px;
}

tooltip label {
  color: #cdd6f4;
}
```

## File: home/alex/hyprland.nix

```
{ config, pkgs, ... }:

{
  # Hyprland
  wayland.windowManager.hyprland = {
    enable = true;
    package = null; # use the system-installed Hyprland
    portalPackage = null; # same for xdg-desktop-portal-hyprland
    systemd.variables = [ "--all" ]; # Fixes missing PATH in services

    settings = {
      exec-once = [
        "waybar"
      ];
      "$mod" = "SUPER";
      bind =
        [
          "$mod, V, exec, code --ozone-platform=x11"
          "$mod, RETURN, exec, kitty"
          "$mod, F, exec, firefox"
          ", Print, exec, grimblast copy area"
        ]
        ++ (
          builtins.concatLists (builtins.genList
            (i:
              let ws = i + 1;
              in [
                "$mod, code:1${toString i}, workspace, ${toString ws}"
                "$mod SHIFT, code:1${toString i}, movetoworkspace, ${toString ws}"
              ]
            ) 9)
        );
    };
  };
}
```

## File: home/alex/programs.nix

```
{ config, pkgs, ... }:

{
  programs.git = {
    enable = true;
    userName = "Alexander Hornung";
    userEmail = "aghornung@gmail.com";
  };


  programs.keepassxc.enable = true;


  # VScode
  programs.vscode = {
    enable = true;
    package = pkgs.vscode.fhs;
    profiles.default.extensions = with pkgs.vscode-extensions; [ ];
  };


  programs.kitty.enable = true;


  # Waybar
  programs.waybar = {
    enable = true;
    package = pkgs.waybar;
  };
  xdg.configFile."waybar/config".source = ./dotfiles/config/waybar/config;
  xdg.configFile."waybar/style.css" = {
    source = ./dotfiles/config/waybar/style.css;
    force = true;
  };

}
```

## File: home/alex/shell.nix

```
{ config, pkgs, ... }:

{
  programs.bash.enable = true;
  programs.zsh.enable = true;
  programs.fzf.enable = true;

  home.shellAliases = {
    code = "code --ozone-platform=x11";
    nixos-build = "sudo nixos-rebuild switch --flake ~/nixos-config#nixos";
    home-build = "home-manager switch --flake ~/nixos-config#alex";
    logout = "hyprctl dispatch exit";
  };
}
```

## File: home/alex/ssh.nix

```
{ config, pkgs, ... }:

{
  programs.ssh = {
    enable = true;
    forwardAgent = false;
    hashKnownHosts = true;
    serverAliveInterval = 60;
    controlMaster = "auto";
    controlPath = "~/.ssh/master-%r@%h:%p";

    matchBlocks = {
      "github.com" = {
        hostname = "github.com";
        user = "git";
        identityFile = "~/.ssh/github_id";
        identitiesOnly = true;
      };
    };

    extraConfig = ''
      AddKeysToAgent yes
      IdentitiesOnly yes
    '';
  };

  home.file.".ssh/config" = {
    target = ".ssh/config_source";
    onChange = ''
      install -m 400 ~/.ssh/config_source ~/.ssh/config
    '';
  };
}
```

## File: home/alex/theme.nix

```
{ config, pkgs, ... }:

{
  home.pointerCursor = {
    gtk.enable = true;
    package = pkgs.bibata-cursors;
    name = "Bibata-Modern-Classic";
    size = 24;
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
```

## File: hosts/configuration.nix

```
{ config, pkgs, ... }:

{
  imports = [
    ./hardware-configuration.nix
  ];


  nix.settings = {
    experimental-features = [ "nix-command" "flakes" ];
    substituters = [ "https://cache.nixos.org/" "https://hyprland.cachix.org" ];
    trusted-public-keys = [ "hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc=" ];
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
    git
    home-manager # Needed before user installs so that packages can be fetched
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

```

## File: hosts/hardware-configuration.nix

```
# Do not modify this file!  It was generated by ‘nixos-generate-config’
# and may be overwritten by future invocations.  Please make changes
# to /etc/nixos/configuration.nix instead.
{ config, lib, pkgs, modulesPath, ... }:

{
  imports =
    [ (modulesPath + "/installer/scan/not-detected.nix")
    ];

  boot.initrd.availableKernelModules = [ "xhci_pci" "ahci" "nvme" "usb_storage" "usbhid" "sd_mod" ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ "kvm-intel" ];
  boot.extraModulePackages = [ ];

  fileSystems."/" =
    { device = "/dev/disk/by-uuid/c0c54ce1-0324-4c07-ad96-8ef8990f5574";
      fsType = "ext4";
    };

  fileSystems."/boot" =
    { device = "/dev/disk/by-uuid/0763-B210";
      fsType = "vfat";
      options = [ "fmask=0077" "dmask=0077" ];
    };

  swapDevices = [ ];

  # Enables DHCP on each ethernet and wireless interface. In case of scripted networking
  # (the default) this is the recommended approach. When using systemd-networkd it's
  # still possible to use this option, but it's recommended to use it in conjunction
  # with explicit per-interface declarations with `networking.interfaces.<interface>.useDHCP`.
  networking.useDHCP = lib.mkDefault true;
  # networking.interfaces.enp3s0.useDHCP = lib.mkDefault true;
  # networking.interfaces.wlp4s0.useDHCP = lib.mkDefault true;

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
}
```

## File: setup/githubSsh.sh

````
#!/bin/bash


# ~/.ssh/github_id

# Define the SSH key file path
SSH_KEY="$HOME/.ssh/github_id"

# Check if the SSH key already exists
if [ -f "$SSH_KEY" ]; then
  echo "SSH key already exists at $SSH_KEY. Skipping key generation."
else
  echo "SSH key not found. Generating a new SSH key for GitHub..."

  # Generate the SSH key
  ssh-keygen -t ed25519 -C "aghornung@gmail.com" -f "$SSH_KEY" -N ""

  echo "SSH key generated at $SSH_KEY."
  echo "Adding the SSH key to the ssh-agent..."

  # Start the ssh-agent and add the key
  eval "$(ssh-agent -s)"
  ssh-add "$SSH_KEY"

  echo "SSH key added to the ssh-agent."
  echo "Copy the following public key to your GitHub account:"
  cat "${SSH_KEY}.pub"
fi```

## File: setup/googleDrive.md

````

# Setting up google drive

This will setup google drive with rclone.

1. run `rclone config`
2. scope = `drive`
3. Go to https://console.cloud.google.com/auth/clients?project=projectName and create a client and obtain the **Client ID** and **Client Secret**
4. run `mkdir ~/Drive`

```

## File: setup/llms.md

```

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

```

## System Overview

This NixOS configuration manages the system setup for user 'alex', including:
- System configurations in 'hosts/'
- Home-manager configurations in 'home/alex/'
- Various dotfiles in 'home/alex/dotfiles/'

## Key Components

1. **flake.nix**: The entry point for the NixOS configuration
2. **hosts/**: System-wide configurations
3. **home/alex/**: User-specific configurations managed by home-manager
4. **setup/**: Scripts for system setup and maintenance
```
