# NixOS Configuration Context for LLMs

Generated on Sun 27 Apr 2025 22:01:20 AEST

## Repository Structure

```
./flake.lock
./flake.nix
./.gitignore
./go.mod
./go.sum
./home/alex/cloud.nix
./home/alex/default.nix
./home/alex/dotfiles/config/Code/code-flags.conf
./home/alex/dotfiles/config/code-flags.conf
./home/alex/dotfiles/config/hypr/hyprpaper.conf
./home/alex/dotfiles/config/kitty/kitty.conf
./home/alex/dotfiles/config/mako/config
./home/alex/dotfiles/config/scripts/layout/launch.go
./home/alex/dotfiles/config/scripts/layout/layout
./home/alex/dotfiles/config/scripts/layout/main.go
./home/alex/dotfiles/config/scripts/layout/windows.go
./home/alex/dotfiles/config/scripts/quicksettings.sh
./home/alex/dotfiles/config/waybar/config
./home/alex/dotfiles/config/waybar/scripts/reload
./home/alex/dotfiles/config/waybar/style.css
./home/alex/dotfiles/config/wofi/style.css
./home/alex/hyprland.nix
./home/alex/programs.nix
./home/alex/shell.nix
./home/alex/ssh.nix
./home/alex/theme.nix
./hosts/configuration.nix
./hosts/hardware-configuration.nix
./node_modules/.modules.yaml
./node_modules/.pnpm/lock.yaml
./node_modules/.pnpm/@types+node@22.15.2/node_modules/@types/node/assert.d.ts
./node_modules/.pnpm/@types+node@22.15.2/node_modules/@types/node/assert/strict.d.ts
./node_modules/.pnpm/@types+node@22.15.2/node_modules/@types/node/async_hooks.d.ts
./node_modules/.pnpm/@types+node@22.15.2/node_modules/@types/node/buffer.buffer.d.ts
./node_modules/.pnpm/@types+node@22.15.2/node_modules/@types/node/buffer.d.ts
./node_modules/.pnpm/@types+node@22.15.2/node_modules/@types/node/child_process.d.ts
./node_modules/.pnpm/@types+node@22.15.2/node_modules/@types/node/cluster.d.ts
./node_modules/.pnpm/@types+node@22.15.2/node_modules/@types/node/compatibility/disposable.d.ts
./node_modules/.pnpm/@types+node@22.15.2/node_modules/@types/node/compatibility/indexable.d.ts
./node_modules/.pnpm/@types+node@22.15.2/node_modules/@types/node/compatibility/index.d.ts
./node_modules/.pnpm/@types+node@22.15.2/node_modules/@types/node/compatibility/iterators.d.ts
./node_modules/.pnpm/@types+node@22.15.2/node_modules/@types/node/console.d.ts
./node_modules/.pnpm/@types+node@22.15.2/node_modules/@types/node/constants.d.ts
./node_modules/.pnpm/@types+node@22.15.2/node_modules/@types/node/crypto.d.ts
./node_modules/.pnpm/@types+node@22.15.2/node_modules/@types/node/dgram.d.ts
./node_modules/.pnpm/@types+node@22.15.2/node_modules/@types/node/diagnostics_channel.d.ts
./node_modules/.pnpm/@types+node@22.15.2/node_modules/@types/node/dns.d.ts
./node_modules/.pnpm/@types+node@22.15.2/node_modules/@types/node/dns/promises.d.ts
./node_modules/.pnpm/@types+node@22.15.2/node_modules/@types/node/domain.d.ts
./node_modules/.pnpm/@types+node@22.15.2/node_modules/@types/node/dom-events.d.ts
./node_modules/.pnpm/@types+node@22.15.2/node_modules/@types/node/events.d.ts
./node_modules/.pnpm/@types+node@22.15.2/node_modules/@types/node/fs.d.ts
./node_modules/.pnpm/@types+node@22.15.2/node_modules/@types/node/fs/promises.d.ts
./node_modules/.pnpm/@types+node@22.15.2/node_modules/@types/node/globals.d.ts
./node_modules/.pnpm/@types+node@22.15.2/node_modules/@types/node/globals.typedarray.d.ts
./node_modules/.pnpm/@types+node@22.15.2/node_modules/@types/node/http2.d.ts
./node_modules/.pnpm/@types+node@22.15.2/node_modules/@types/node/http.d.ts
./node_modules/.pnpm/@types+node@22.15.2/node_modules/@types/node/https.d.ts
./node_modules/.pnpm/@types+node@22.15.2/node_modules/@types/node/index.d.ts
./node_modules/.pnpm/@types+node@22.15.2/node_modules/@types/node/inspector.d.ts
./node_modules/.pnpm/@types+node@22.15.2/node_modules/@types/node/LICENSE
./node_modules/.pnpm/@types+node@22.15.2/node_modules/@types/node/module.d.ts
./node_modules/.pnpm/@types+node@22.15.2/node_modules/@types/node/net.d.ts
./node_modules/.pnpm/@types+node@22.15.2/node_modules/@types/node/os.d.ts
./node_modules/.pnpm/@types+node@22.15.2/node_modules/@types/node/package.json
./node_modules/.pnpm/@types+node@22.15.2/node_modules/@types/node/path.d.ts
./node_modules/.pnpm/@types+node@22.15.2/node_modules/@types/node/perf_hooks.d.ts
./node_modules/.pnpm/@types+node@22.15.2/node_modules/@types/node/process.d.ts
./node_modules/.pnpm/@types+node@22.15.2/node_modules/@types/node/punycode.d.ts
./node_modules/.pnpm/@types+node@22.15.2/node_modules/@types/node/querystring.d.ts
./node_modules/.pnpm/@types+node@22.15.2/node_modules/@types/node/readline.d.ts
./node_modules/.pnpm/@types+node@22.15.2/node_modules/@types/node/readline/promises.d.ts
./node_modules/.pnpm/@types+node@22.15.2/node_modules/@types/node/README.md
./node_modules/.pnpm/@types+node@22.15.2/node_modules/@types/node/repl.d.ts
./node_modules/.pnpm/@types+node@22.15.2/node_modules/@types/node/sea.d.ts
./node_modules/.pnpm/@types+node@22.15.2/node_modules/@types/node/sqlite.d.ts
./node_modules/.pnpm/@types+node@22.15.2/node_modules/@types/node/stream/consumers.d.ts
./node_modules/.pnpm/@types+node@22.15.2/node_modules/@types/node/stream.d.ts
./node_modules/.pnpm/@types+node@22.15.2/node_modules/@types/node/stream/promises.d.ts
./node_modules/.pnpm/@types+node@22.15.2/node_modules/@types/node/stream/web.d.ts
./node_modules/.pnpm/@types+node@22.15.2/node_modules/@types/node/string_decoder.d.ts
./node_modules/.pnpm/@types+node@22.15.2/node_modules/@types/node/test.d.ts
./node_modules/.pnpm/@types+node@22.15.2/node_modules/@types/node/timers.d.ts
./node_modules/.pnpm/@types+node@22.15.2/node_modules/@types/node/timers/promises.d.ts
./node_modules/.pnpm/@types+node@22.15.2/node_modules/@types/node/tls.d.ts
./node_modules/.pnpm/@types+node@22.15.2/node_modules/@types/node/trace_events.d.ts
./node_modules/.pnpm/@types+node@22.15.2/node_modules/@types/node/ts5.6/buffer.buffer.d.ts
./node_modules/.pnpm/@types+node@22.15.2/node_modules/@types/node/ts5.6/globals.typedarray.d.ts
./node_modules/.pnpm/@types+node@22.15.2/node_modules/@types/node/ts5.6/index.d.ts
./node_modules/.pnpm/@types+node@22.15.2/node_modules/@types/node/tty.d.ts
./node_modules/.pnpm/@types+node@22.15.2/node_modules/@types/node/url.d.ts
./node_modules/.pnpm/@types+node@22.15.2/node_modules/@types/node/util.d.ts
./node_modules/.pnpm/@types+node@22.15.2/node_modules/@types/node/v8.d.ts
./node_modules/.pnpm/@types+node@22.15.2/node_modules/@types/node/vm.d.ts
./node_modules/.pnpm/@types+node@22.15.2/node_modules/@types/node/wasi.d.ts
./node_modules/.pnpm/@types+node@22.15.2/node_modules/@types/node/worker_threads.d.ts
./node_modules/.pnpm/@types+node@22.15.2/node_modules/@types/node/zlib.d.ts
./node_modules/.pnpm/undici-types@6.21.0/node_modules/undici-types/agent.d.ts
./node_modules/.pnpm/undici-types@6.21.0/node_modules/undici-types/api.d.ts
./node_modules/.pnpm/undici-types@6.21.0/node_modules/undici-types/balanced-pool.d.ts
./node_modules/.pnpm/undici-types@6.21.0/node_modules/undici-types/cache.d.ts
./node_modules/.pnpm/undici-types@6.21.0/node_modules/undici-types/client.d.ts
./node_modules/.pnpm/undici-types@6.21.0/node_modules/undici-types/connector.d.ts
./node_modules/.pnpm/undici-types@6.21.0/node_modules/undici-types/content-type.d.ts
./node_modules/.pnpm/undici-types@6.21.0/node_modules/undici-types/cookies.d.ts
./node_modules/.pnpm/undici-types@6.21.0/node_modules/undici-types/diagnostics-channel.d.ts
./node_modules/.pnpm/undici-types@6.21.0/node_modules/undici-types/dispatcher.d.ts
./node_modules/.pnpm/undici-types@6.21.0/node_modules/undici-types/env-http-proxy-agent.d.ts
./node_modules/.pnpm/undici-types@6.21.0/node_modules/undici-types/errors.d.ts
./node_modules/.pnpm/undici-types@6.21.0/node_modules/undici-types/eventsource.d.ts
./node_modules/.pnpm/undici-types@6.21.0/node_modules/undici-types/fetch.d.ts
./node_modules/.pnpm/undici-types@6.21.0/node_modules/undici-types/file.d.ts
./node_modules/.pnpm/undici-types@6.21.0/node_modules/undici-types/filereader.d.ts
./node_modules/.pnpm/undici-types@6.21.0/node_modules/undici-types/formdata.d.ts
./node_modules/.pnpm/undici-types@6.21.0/node_modules/undici-types/global-dispatcher.d.ts
./node_modules/.pnpm/undici-types@6.21.0/node_modules/undici-types/global-origin.d.ts
./node_modules/.pnpm/undici-types@6.21.0/node_modules/undici-types/handlers.d.ts
./node_modules/.pnpm/undici-types@6.21.0/node_modules/undici-types/header.d.ts
./node_modules/.pnpm/undici-types@6.21.0/node_modules/undici-types/index.d.ts
./node_modules/.pnpm/undici-types@6.21.0/node_modules/undici-types/interceptors.d.ts
./node_modules/.pnpm/undici-types@6.21.0/node_modules/undici-types/LICENSE
./node_modules/.pnpm/undici-types@6.21.0/node_modules/undici-types/mock-agent.d.ts
./node_modules/.pnpm/undici-types@6.21.0/node_modules/undici-types/mock-client.d.ts
./node_modules/.pnpm/undici-types@6.21.0/node_modules/undici-types/mock-errors.d.ts
./node_modules/.pnpm/undici-types@6.21.0/node_modules/undici-types/mock-interceptor.d.ts
./node_modules/.pnpm/undici-types@6.21.0/node_modules/undici-types/mock-pool.d.ts
./node_modules/.pnpm/undici-types@6.21.0/node_modules/undici-types/package.json
./node_modules/.pnpm/undici-types@6.21.0/node_modules/undici-types/patch.d.ts
./node_modules/.pnpm/undici-types@6.21.0/node_modules/undici-types/pool.d.ts
./node_modules/.pnpm/undici-types@6.21.0/node_modules/undici-types/pool-stats.d.ts
./node_modules/.pnpm/undici-types@6.21.0/node_modules/undici-types/proxy-agent.d.ts
./node_modules/.pnpm/undici-types@6.21.0/node_modules/undici-types/readable.d.ts
./node_modules/.pnpm/undici-types@6.21.0/node_modules/undici-types/README.md
./node_modules/.pnpm/undici-types@6.21.0/node_modules/undici-types/retry-agent.d.ts
./node_modules/.pnpm/undici-types@6.21.0/node_modules/undici-types/retry-handler.d.ts
./node_modules/.pnpm/undici-types@6.21.0/node_modules/undici-types/util.d.ts
./node_modules/.pnpm/undici-types@6.21.0/node_modules/undici-types/webidl.d.ts
./node_modules/.pnpm/undici-types@6.21.0/node_modules/undici-types/websocket.d.ts
./node_modules/.pnpm-workspace-state.json
./package.json
./pnpm-lock.yaml
./README.md
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
node_modules```

## File: .vscode/settings.json

```
{
  // "editor.fontFamily": "'JetBrainsMono Nerd Font', 'monospace'",
  "editor.fontLigatures": true,
  "typescript.tsserver.nodePath": "/home/alex/.nix-profile/bin/node"
}
```

## File: README.md

```
# NixOS Config: NVIDIA + GNOME + Hyprland + Home Manager

This repository contains a complete NixOS configuration for a modern desktop environment with NVIDIA GPU support, GNOME keyring integration, Hyprland (with hy3 tiling), and Home Manager for user-level package and dotfile management.

## Features

- **NVIDIA GPU**: Out-of-the-box support with modesetting, power management, and `nvidia-settings`.
- **Hyprland**: Next-gen Wayland compositor with hy3 tiling plugin and custom keybindings.
- **GNOME Keyring**: Secure credential storage, integrated with `greetd`, Hyprland, and SDDM.
- **Home Manager**: User environment management, including dotfiles, shell, and user packages.
- **Wayland Apps**: Waybar, mako notifications, wofi launcher, hyprpaper, hyprpolkitagent, and more.
- **Development Tools**: Go, Node.js, pnpm, jq, VSCode (with FHS), Kitty terminal.
- **Google Drive**: Rclone-based mounting with systemd user service.
- **XFCE Thunar**: File manager with thumbnails, volume management, and GVFS.
- **Theming**: Adw-gtk3-dark, Papirus-Dark icons, Bibata cursor.
- **Other**: Printing, Pipewire audio, NetworkManager, timezone/locale for Australia/Melbourne.

## Installation

1.  **Prerequisites**
    - A fresh NixOS installation (x86_64).
    - Internet connection.
    - NVIDIA GPU.
2.  **Clone the Repository**
    ```bash
    git clone <repository-url> nixos-config
    cd nixos-config
    ```
3.  **Edit Hardware Configuration**

    - Copy or symlink your generated `hardware-configuration.nix` to `/home/alex/nixos-config/hardware-configuration.nix` if not already present.

4.  **Build and Switch to the Configuration**

    ```bash
    sudo nixos-rebuild switch --flake .#<your-hostname>
    ```

    _(Replace `<your-hostname>` with your actual system hostname)_

5.  **Set Up Home Manager**

    - Home Manager is integrated via the NixOS module. After the system rebuild, log out and log back in for user-level changes to take effect.

6.  **(Optional) Set Up Google Drive**

    - Configure your rclone remote named `gdrive`.
    - The systemd user service (`services.rclone-mount`) will attempt to mount Google Drive at `~/Drive` on login. Enable it if needed: `systemctl --user enable --now rclone-mount@gdrive.service`.

7.  **SSH and GitHub**
    - SSH config for GitHub is managed in `ssh.nix`.
    - Run `githubSsh.sh` (if available and configured in your Home Manager setup) to assist with setting up your GitHub SSH key.

## Usage

- **Login Manager**: SDDM (auto-login disabled by default).
- **Session**: Hyprland (Wayland).
- **Keybindings**: See `home/alex/dotfiles/config/hypr/hyprland.nix` for custom shortcuts.
- **Automated Layout**: A custom Go script (`home/alex/dotfiles/config/scripts/layout/layout`) runs on startup (or manually) to launch specific applications onto designated monitors and arrange them into a predefined layout (e.g., creating tab groups, setting floating status, resizing specific windows). See the script source `home/alex/dotfiles/config/scripts/layout/main.go` for details on the target layout.
- **VSCode**: Launch with the `code` alias (configured for Wayland/X11 compatibility).
- **Shell**: Zsh (with fzf), Bash also enabled.
- **Dotfiles**: Managed in `home/alex/dotfiles/`.

## Customization

- **User Packages**: Edit `home-manager/default.nix` to add/remove user packages.
- **System Configuration**: Edit `configuration.nix` for system-wide changes.
- **Theming**: Modify `theme.nix`.
- **Hyprland Config**: Adjust settings in `home/alex/dotfiles/config/hypr/`.

## Troubleshooting

- **NVIDIA/Wayland**: Ensure kernel parameters (`nvidia-drm.modeset=1`) and modules are correctly loaded. Check `boot.kernelModules` and `boot.extraModprobeConfig` in `configuration.nix`.
- **Rclone/Google Drive**: Verify your `rclone.conf` and check the systemd user service status: `systemctl --user status rclone-mount@gdrive.service`. Check logs: `journalctl --user -u rclone-mount@gdrive.service`.
- **Home Manager**: Ensure you are using the correct flake inputs and that the Home Manager module is correctly imported in `configuration.nix`. Run `home-manager switch --flake .#<your-username>@<your-hostname>` for debugging user configurations directly.
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

    hyprland-plugins = {
      url = "github:hyprwm/hyprland-plugins";
      inputs.hyprland.follows = "hyprland";
    };

    hy3 = {
      url = "github:outfoxxed/hy3"; # where {version} is the hyprland release version
      # or "github:outfoxxed/hy3" to follow the development branch.
      # (you may encounter issues if you dont do the same for hyprland)
      inputs.hyprland.follows = "hyprland";
    };
  };

  outputs = { self, nixpkgs, flake-utils, home-manager, hy3, ... }@inputs:
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
        extraSpecialArgs = { inherit inputs; inherit hy3; };
        modules = [
          ./home/alex/default.nix
        ];
      };

    };
}

```

## File: go.mod

```
module hyprland-scripts

go 1.24.2

require github.com/thiagokokada/hyprland-go v0.4.1
```

## File: go.sum

```
github.com/thiagokokada/hyprland-go v0.4.1 h1:yHHZ86ysUzfcQQBPZkGcxMBH591bmuVzy3LTAIuizUY=
github.com/thiagokokada/hyprland-go v0.4.1/go.mod h1:gUGbdxhD7QdvPpdEwsB09x0HzICPkhKAuCeY+LVx5YM=
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
{ config, inputs, pkgs, hy3, ... }:

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
    tidal-hifi
    # File system tools
    xfce.thunar
    xfce.tumbler
    xfce.thunar-volman
    gvfs
    # Application launcher
    wofi
    # Notificaiton daemon
    mako
    # Auth agent
    hyprpolkitagent
    # Wallpaper
    hyprpaper
    # Settings
    wdisplays # display settings
    networkmanagerapplet
    pavucontrol # volume manager
    wlogout # logout/lock GUI
    firefox-devedition
    # Development
    jq
    nodejs_23
    pnpm
    socat
    # Go
    go # Go programming language
    gopls # Go language server
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

## File: home/alex/dotfiles/config/Code/code-flags.conf

```
--enable-features=UseOzonePlatform 
--ozone-platform=wayland 
```

## File: home/alex/dotfiles/config/code-flags.conf

```
--enable-features=UseOzonePlatform 
--ozone-platform=wayland ```

## File: home/alex/dotfiles/config/hypr/hyprpaper.conf

```
wallpaper = HDMI-A-1,solid_color=1e1e2e
wallpaper = DP-3,solid_color=1e1e2e
```

## File: home/alex/dotfiles/config/kitty/kitty.conf

```
# Fonts
font_family      JetBrainsMono Nerd Font
bold_font        auto
italic_font      auto
bold_italic_font auto
font_size        13.0

# Colors (match your Waybar/GTK theme)
background       #1e1e2e
background_opacity 0.9
borderless_window yes
foreground       #cdd6f4
selection_background #313244
selection_foreground #cdd6f4
cursor           #89b4fa

# Window Decorations
hide_window_decorations yes
window_padding_width 8

# Scrollback
scrollback_lines 10000

# Performance tweaks
enable_audio_bell no
repaint_delay 7
input_delay 1
```

## File: home/alex/dotfiles/config/mako/config

```
background-color=#1e1e2e
text-color=#cdd6f4
border-color=#89b4fa
border-size=2
padding=10
margin=10
font=JetBrainsMono Nerd Font 12
icons=true
max-history=50
default-timeout=5000
```

## File: home/alex/dotfiles/config/scripts/layout/launch.go

```
package main

import (
	"context"
	"fmt"
	"os"
	"path/filepath"
	"strings"
	"time"

	"github.com/thiagokokada/hyprland-go/event"
)

func launchApps(apps map[int][]string) {
	for window, list := range apps {
		for _, app := range list {
			if isRunning(app) {
				fmt.Printf("%s is already running\n", app)
				continue
			}

			ctx, cancel := context.WithTimeout(context.Background(), 5*time.Second)
			done := make(chan struct{}) // channel to signal window opened

			go func(appName string) {
				go func() {
					e.Subscribe(ctx, &ev{
						onOpen: func(w event.OpenWindow) {
							if isRunning(appName) {
								close(done) // window opened, signal done
							}
						},
					}, event.EventOpenWindow)
				}()

				c.Dispatch("focusmonitor " + fmt.Sprint(window))
				c.Dispatch("exec " + appName)
				fmt.Println("Launching", appName)
			}(app)

			select {
			case <-done:
				fmt.Printf("%s launched successfully\n", app)
			case <-ctx.Done():
				fmt.Printf("Timeout launching %s\n", app)
			}

			cancel() // cancel the subscription ctx manually after select
		}
	}
}

func isRunning(app string) bool {
	clients, err := c.Clients()
	if err != nil {
		return false
	}
	for _, client := range clients {
		clientAppName, err := AppNameFromPid(client.Pid)
		if err != nil {
			continue
		}
		if clientAppName == getAppName(app) {
			return true
		}

	}
	return false
}

func AppNameFromPid(pid int) (string, error) {
	cmdlinePath := fmt.Sprintf("/proc/%d/cmdline", pid)
	cmdlineBytes, err := os.ReadFile(cmdlinePath)
	if err != nil {
		return "", err
	}
	appName := getAppName(string(cmdlineBytes))
	if appName == "" {
		return "", fmt.Errorf("could not get app name from pid %d", pid)
	}
	return appName, nil
}

func getAppName(app string) string {
	// First, replace null bytes (from /proc/cmdline) with spaces
	app = strings.ReplaceAll(app, "\x00", " ")
	// Trim leading/trailing spaces (just in case)
	app = strings.TrimSpace(app)
	// If there's a space, cut at first space (only keep command)
	if idx := strings.Index(app, " "); idx != -1 {
		app = app[:idx]
	}
	// If there's a slash, take only the basename
	if strings.Contains(app, "/") {
		app = filepath.Base(app)
	}
	// This is nixos specific
	app = strings.TrimPrefix(app, ".")
	app = strings.TrimSuffix(app, "-wrapped")

	// Final cleanup: trim again (paranoia, but cheap)
	return strings.TrimSpace(app)
}
```

## File: home/alex/dotfiles/config/scripts/layout/layout
**Note**: File too large to include (3932651 bytes)

## File: home/alex/dotfiles/config/scripts/layout/main.go

```
// GOOS=linux GOARCH=amd64 go build -o layout .

package main

import (
	"flag"
	"io"

	"github.com/thiagokokada/hyprland-go"
	"github.com/thiagokokada/hyprland-go/event"
)

var (
	c *hyprland.RequestClient
	// default error/usage output
	out io.Writer = flag.CommandLine.Output()
)

var (
	e *event.EventClient
	// default error/usage output
	eventsOut io.Writer = flag.CommandLine.Output()
)

type ev struct {
	event.DefaultEventHandler
	onOpen func(w event.OpenWindow)
}

func (e *ev) OpenWindow(w event.OpenWindow) {
	if e.onOpen != nil {
		e.onOpen(w)
	}
}

func must[T any](input T, err error) T {
	if err != nil {
		panic(err)
	}
	return input
}

func main() {
	c = hyprland.MustClient()
	e = event.MustClient()
	apps := map[int][]string{
		0: {"code --ozone-platform=x11"},
		1: {"firefox-devedition",
			"firefox",
			"thunar",
			"keepassxc",
			"tidal-hifi"},
	}
	launchApps(apps)

	processWindows(WindowsOptions{
		Command: "hy3:changegroup untab",
		Monitor: 1,
	})

	processWindows(WindowsOptions{
		UseAddress: true,
		Command:    "togglefloating",
		Monitor:    1,
	})

	processWindows(WindowsOptions{
		UseAddress: true,
		Command:    "togglefloating",
		Monitor:    1,
		AppOrder:   []string{"firefox-devedition", "firefox", "thunar", "keepassxc", "tidal-hifi"},
	})

	// Focus thunar and make it a tab group
	thunar := must(AddressFromAppName("thunar"))
	println("Focusing and making tab group for thunar: ", thunar)
	c.Dispatch("focuswindow address:" + thunar)
	c.Dispatch("hy3:makegroup tab, toggle")

	// Moves all the windows after thunar into the tab group
	processWindows(WindowsOptions{
		After:   "thunar",
		Command: "hy3:movewindow l",
		Monitor: 1,
	})

	c.Dispatch("focusmonitor 0")

	firefoxDev := must(AddressFromAppName("firefox-devedition"))
	firefox := must(AddressFromAppName("firefox"))
	c.Dispatch("resizewindowpixel exact 80% 100%, address:" + firefoxDev)
	c.Dispatch("resizewindowpixel exact 60% 100%, address:" + firefox)

}
```

## File: home/alex/dotfiles/config/scripts/layout/windows.go

```
package main

import (
	"fmt"

	"github.com/thiagokokada/hyprland-go"
)

type WindowsOptions struct {
	UseAddress bool
	AppOrder   []string
	After      string
	Command    string
	Monitor    int
}

func processWindows(args WindowsOptions) {
	if args.Command == "" {
		panic("Command is required")
	}
	if args.UseAddress {
		clients, err := c.Clients()
		if err != nil {
			return
		}
		var windowsOnMonitor []hyprland.Client
		for _, client := range clients {
			if client.Monitor == args.Monitor {
				windowsOnMonitor = append(windowsOnMonitor, client)
			}
		}

		var orderedClients []hyprland.Client
		for _, app := range args.AppOrder {
			for i, client := range windowsOnMonitor {
				clientAppName, err := AppNameFromPid(client.Pid)
				if err != nil {
					continue
				}
				if clientAppName == app {
					orderedClients = append(orderedClients, client)
					// Remove client from windowsOnMonitor
					windowsOnMonitor = append(windowsOnMonitor[:i], windowsOnMonitor[i+1:]...)
					break
				}
			}
		}
		// Add any remaining windows to the end of the list
		orderedClients = append(orderedClients, windowsOnMonitor...)

		var startProcessing bool = args.After == ""
		for _, client := range orderedClients {
			clientAppName, err := AppNameFromPid(client.Pid)
			if err != nil {
				continue
			}
			if !startProcessing {
				if clientAppName == args.After {
					// Can start processing from the next client
					startProcessing = true
					continue
				}
			} else {
				cmd := fmt.Sprintf("%s address:%s", args.Command, client.Address)
				println("Dispatching: ", cmd)
				c.Dispatch(cmd)
			}
		}

	} else {
		c.Dispatch("focusmonitor " + fmt.Sprint(args.Monitor))
		var startProcessing bool = args.After == ""
		var activeWindow, err = c.ActiveWindow()
		if err != nil {
			return
		}
		var prevWindow string = ""

		var iteration int = 0
		maxIterations := 50
		for iteration < maxIterations {
			if activeWindow.Address == prevWindow {
				// Reached the end of the monitor
				break
			}
			iteration++
			clientAppName, err := AppNameFromPid(activeWindow.Pid)
			if err != nil {
				println("Error getting app name: ", err)
				continue
			}
			if !startProcessing {
				println("Skipping: ", clientAppName)
				if clientAppName == args.After {
					// Can start processing from the next client
					startProcessing = true
				}
			} else {
				println("Dispatching: ", args.Command)
				c.Dispatch(args.Command)
			}

			prevWindow = activeWindow.Address

			c.Dispatch("hy3:movefocus r, visible, nowrap")
			activeWindow, err = c.ActiveWindow()
			if err != nil {
				return
			}
		}
	}
}

func AddressFromAppName(app string) (string, error) {
	clients, err := c.Clients()
	if err != nil {
		return "", err
	}
	for _, client := range clients {
		clientAppName, err := AppNameFromPid(client.Pid)
		if err != nil {
			continue
		}
		if clientAppName == getAppName(app) {
			return client.Address, nil
		}
	}
	return "", fmt.Errorf("could not find address for app %s", app)
}
```

## File: home/alex/dotfiles/config/scripts/quicksettings.sh

```
#!/usr/bin/env bash

choice=$(printf "Displays\nNetwork\nAudio\nLogout\n" | wofi --dmenu --prompt "Quick Settings")
choice=$(echo "$choice" | tr '[:upper:]' '[:lower:]')

case "$choice" in
  disp*) wdisplays ;;
  net*) nm-connection-editor ;;
  aud*) pavucontrol ;;
  log*) wlogout ;;
esac
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
    "on-click": "/home/alex/.nix-profile/bin/code --use-angle=vulkan",
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

## File: home/alex/dotfiles/config/wofi/style.css

```
* {
  font-family: "JetBrainsMono Nerd Font", "Sans";
  font-size: 14px;
  color: #cdd6f4;
  background-color: transparent;
  border: none;
}

window {
  margin: 0px;
  border: 2px solid #89b4fa;
  background-color: #1e1e2e;
  border-radius: 12px;
}

#input {
  padding: 6px 12px;
  margin: 8px;
  background-color: #313244;
  border-radius: 8px;
  border: none;
  color: #f5f5f5;
}

#entry {
  padding: 8px 12px;
  margin: 4px 8px;
  border-radius: 8px;
  background-color: transparent;
}

#entry:selected {
  background-color: #370617;
  color: #89b4fa;
}

#text {
  margin: 0px;
}

#scroll {
  margin: 4px;
}
```

## File: home/alex/hyprland.nix

```
{ config, inputs, pkgs, hy3, ... }:

{



  # Hyprland
  wayland.windowManager.hyprland = {
    enable = true;
    # package = null; # use the system-installed Hyprland
    package = inputs.hyprland.packages.${pkgs.system}.default;
    portalPackage = inputs.hyprland.packages.${pkgs.system}.xdg-desktop-portal-hyprland;
    systemd.variables = [ "--all" ]; # Fixes missing PATH in services

    plugins = [
      # inputs.hyprland-plugins.packages.${pkgs.system}.hyprtrails
      # inputs.hyprland-plugins.packages.${pkgs.stdenv.hostPlatform.system}.hyprbars
      inputs.hy3.packages.x86_64-linux.hy3
    ];

    extraConfig = ''
      plugin {
        hy3 {
          no_gaps_when_only = 1
          node_collapse_policy = 2
          group_inset = 10

          autotile {
            enable = false
            trigger_width = 800
            trigger_height = 600
          }
        }
      }
    '';

    settings =
      {

        env = [
          "NIXOS_OZONE_WL, 1"
          "NIXPKGS_ALLOW_UNFREE, 1"
          "XDG_CURRENT_DESKTOP, Hyprland"
          "XDG_SESSION_TYPE, wayland"
          "XDG_SESSION_DESKTOP, Hyprland"
          "GDK_BACKEND, wayland, x11"
          "CLUTTER_BACKEND, wayland"
          "QT_QPA_PLATFORM=wayland;xcb"
          "QT_WAYLAND_DISABLE_WINDOWDECORATION, 1"
          "LIBVA_DRIVER_NAME, nvidia"
          "__GLX_VENDOR_LIBRARY_NAME, nvidia"
          "QT_AUTO_SCREEN_SCALE_FACTOR, 1"
          "SDL_VIDEODRIVER, x11"
          "MOZ_ENABLE_WAYLAND, 1"
          "AQ_DRM_DEVICES,/dev/dri/card0:/dev/dri/card1"
          "GDK_SCALE,1"
          "QT_SCALE_FACTOR,1"
          "ELECTRON_OZONE_PLATFORM_HINT, auto"
          "NVD_BACKEND, direct"
          # "EDITOR,nvim"
        ];



        general = {
          layout = "hy3";
          gaps_in = 4;
          gaps_out = 4;
          border_size = 1;
          resize_on_border = true;
          "col.active_border" = "rgb(89b4fa) rgb(f5c2e7) 45deg";
          "col.inactive_border" = "rgb(313244)";
        };

        decoration = {
          rounding = 10;
          blur = {
            enabled = true;
            size = 5;
            passes = 3;
            ignore_opacity = false;
            new_optimizations = true;
          };
          shadow = {
            enabled = true;
            range = 4;
            render_power = 3;
            color = "rgba(1a1a1aee)";
          };
        };

        ecosystem = {
          no_donation_nag = true;
        };

        input = {
          sensitivity = -0.2;
        };


        exec-once = [
          "waybar"
          "mako"
          "hyprpolkitagent"
          "hyprpaper"
          "sleep 1 && ~/.config/scripts/layout/layout"
        ];
        animations = {
          enabled = true;

          bezier = [
            "ease, 0.2, 0.0, 0.2, 1.0"
          ];

          animation = [
            "windows, 1, 1, ease"
            "windowsOut, 1, 1, ease"
            "border, 1, 1, ease"
            "fade, 1, 1, ease"
            "workspaces, 1, 1, ease"
          ];
        };
        "$mod" = "SUPER";
        bind =
          [
            "$mod, V, exec, code --use-angle=vulkan"
            "$mod, RETURN, exec, kitty"
            "$mod, F, exec, firefox"
            "$mod, A, exec, wofi --show drun"
            "$mod, Q, killactive"
            "$mod, S, exec, ~/.config/scripts/quicksettings.sh"
            "$mod, U, exec, ~/.config/scripts/layout/layout"
            "$mod, G, hy3:makegroup, tab, toggle"
            "$mod, TAB, hy3:focustab, r, wrap"
            "$mod SHIFT, TAB, hy3:focustab, l, wrap"
            "$mod SHIFT, F, togglefloating"
            "$mod SHIFT, H, hy3:movewindow, l"
            "$mod SHIFT, L, hy3:movewindow, r"
            "$mod SHIFT, J, hy3:movewindow, d"
            "$mod SHIFT, K, hy3:movewindow, u"
            "$mod, H, hy3:movefocus, l, visible"
            "$mod, L, hy3:movefocus, r, visible"
            "$mod, J, hy3:movefocus, d, visible"
            "$mod, K, hy3:movefocus, u, visible"
            "$mod, mouse_down, exec, hyprctl -q keyword cursor:zoom_factor $(hyprctl getoption cursor:zoom_factor | awk '/^float.*/ {print $2 * 1.1}')"
            "$mod, mouse_up, exec, hyprctl -q keyword cursor:zoom_factor $(hyprctl getoption cursor:zoom_factor | awk '/^float.*/ {print $2 * 0.9}')"
            "$mod, equal, exec, hyprctl -q keyword cursor:zoom_factor $(hyprctl getoption cursor:zoom_factor | awk '/^float.*/ {print $2 * 1.1}')"
            "$mod, minus, exec, hyprctl -q keyword cursor:zoom_factor $(hyprctl getoption cursor:zoom_factor | awk '/^float.*/ {print $2 * 0.9}')"
            "$mod, KP_ADD, exec, hyprctl -q keyword cursor:zoom_factor $(hyprctl getoption cursor:zoom_factor | awk '/^float.*/ {print $2 * 1.1}')"
            "$mod, KP_SUBTRACT, exec, hyprctl -q keyword cursor:zoom_factor $(hyprctl getoption cursor:zoom_factor | awk '/^float.*/ {print $2 * 0.9}')"
            "$mod SHIFT, mouse_up, exec, hyprctl -q keyword cursor:zoom_factor 1"
            "$mod SHIFT, mouse_down, exec, hyprctl -q keyword cursor:zoom_factor 1"
            "$mod SHIFT, minus, exec, hyprctl -q keyword cursor:zoom_factor 1"
            "$mod SHIFT, KP_SUBTRACT, exec, hyprctl -q keyword cursor:zoom_factor 1"
            "$mod SHIFT, 0, exec, hyprctl -q keyword cursor:zoom_factor 1"
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
  # Git
  programs.git = {
    enable = true;
    userName = "Alexander Hornung";
    userEmail = "aghornung@gmail.com";
  };

  # KeepassXC
  programs.keepassxc.enable = true;

  # VScode
  programs.vscode = {
    enable = true;
    package = pkgs.vscode.fhs;
    profiles.default.extensions = with pkgs.vscode-extensions; [ ];
  };

  # Vim
  programs.vim.enable = true;

  # Kitty
  programs.kitty.enable = true;

  # Waybar
  programs.waybar = {
    enable = true;
    package = pkgs.waybar;
  };


  # Wlsunset
  services.wlsunset = {
    enable = true;
    latitude = "-37.813629";
    longitude = "144.963058";
    temperature = {
      day = 5500;
      night = 3700;
    };
  };

  # Moves all config files to ~/.config
  xdg.configFile."" = {
    source = ./dotfiles/config;
    recursive = true;
  };
}
```

## File: home/alex/shell.nix

```
{ config, pkgs, ... }:

{
  programs.zsh.enable = true;
  programs.fzf.enable = true;

  home.shellAliases = {
    nixos-build = "sudo nixos-rebuild switch --flake ~/nixos-config#nixos";
    home-build = "home-manager switch --flake ~/nixos-config#alex";
    logout = "hyprctl dispatch exit";
    code = "code --use-angle=vulkan";
  };


  programs.bash = {
    enable = true;
    initExtra = ''
      export PNPM_HOME="/home/alex/.local/share/pnpm"
      export PATH="$PNPM_HOME:$PATH"
    '';
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
      package = pkgs.adw-gtk3;
      name = "adw-gtk3-dark";
    };
    iconTheme = {
      package = pkgs.papirus-icon-theme;
      name = "Papirus-Dark";
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

  # https://nixos.wiki/wiki/Docker
  virtualisation.docker = {
    enable = true;
    package = pkgs.docker_28;
  };
  hardware.nvidia-container-toolkit.enable = true; # Use --device=nvidia.com/gpu=all when running containers needing GPU access


  # TODO move to its own file
  # https://search.nixos.org/options?channel=unstable&show=services.kanata.package&from=0&size=50&sort=relevance&type=packages&query=services.kanata
  services.kanata = {
    enable = true;
    keyboards = {
      "annePro" = {
        # https://github.com/jtroo/kanata/blob/main/docs/config.adoc
        extraDefCfg = ''
          concurrent-tap-hold yes
        '';
        config = ''
          (defchordsv2
            (q w e r) (layer-switch emergency) 200 all-released ()
            (q w e r t) (layer-switch default) 200 all-released ()
          )

          (defsrc
            esc  1    2    3    4    5    6    7    8    9    0    -    =    bspc
            tab  q    w    e    r    t    y    u    i    o    p    [    ]    \
            caps a    s    d    f    g    h    j    k    l    ;    '    ret
            lsft z    x    c    v    b    n    m    ,    .    /    rsft
            lctl lmet lalt           spc            ralt rmet rctl
          )

          (defalias
            capAsEsc (tap-hold 200 200 esc lctl)
          )

          (deflayer default
            caps 1    2    3    4    5    6    7    8    9    0    -    =    bspc
            tab  q    w    e    r    t    y    u    i    o    p    [    ]    \
            @capAsEsc  a    s    d    f    g    h    j    k    l    ;    '    ret
            lsft z    x    c    v    b    n    m    ,    .    /    rsft
            lctl lmet lalt           spc            ralt rmet rctl
          )

          ;; If something fucks up and i need to reset press q w e r at once
          (deflayer emergency
            esc  1    2    3    4    5    6    7    8    9    0    -    =    bspc
            tab  q    w    e    r    t    y    u    i    o    p    [    ]    \
            caps a    s    d    f    g    h    j    k    l    ;    '    ret
            lsft z    x    c    v    b    n    m    ,    .    /    rsft
            lctl lmet lalt           spc            ralt rmet rctl
          )
        '';
      };
    };
  };

  users.users.alex = {
    isNormalUser = true;
    description = "Alexander Hornung";
    extraGroups = [ "networkmanager" "wheel" "docker" "input" ];
    packages = with pkgs; [ ];
  };

  programs.firefox.enable = true;

  environment.systemPackages = with pkgs; [
    git
    home-manager # Needed before user installs so that packages can be fetched
    seahorse # GUI for managing stored keyring secrets
    nvidia-vaapi-driver
    kanata
  ];

  environment.sessionVariables = {
    #   ELECTRON_OZONE_PLATFORM_HINT = "wayland";
    # NIXOS_OZONE_WL = "1";
    #   EDITOR = "code --use-angle=vulkan --wait";
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

## File: package.json

```
{
  "name": "nixos-config",
  "version": "1.0.0",
  "description": "NixOS configuration files",
  "scripts": {
    "test": "echo \"Error: no test specified\" && exit 1"
  },
  "keywords": [
    "nixos",
    "config"
  ],
  "author": "",
  "license": "MIT",
  "type": "module",
  "dependencies": {
    "@types/node": "^22.15.2"
  }
}
```

## File: pnpm-lock.yaml

```
lockfileVersion: '9.0'

settings:
  autoInstallPeers: true
  excludeLinksFromLockfile: false

importers:

  .:
    dependencies:
      '@types/node':
        specifier: ^22.15.2
        version: 22.15.2

packages:

  '@types/node@22.15.2':
    resolution: {integrity: sha512-uKXqKN9beGoMdBfcaTY1ecwz6ctxuJAcUlwE55938g0ZJ8lRxwAZqRz2AJ4pzpt5dHdTPMB863UZ0ESiFUcP7A==}

  undici-types@6.21.0:
    resolution: {integrity: sha512-iwDZqg0QAGrg9Rav5H4n0M64c3mkR59cJ6wQp+7C4nI0gsmExaedaYLNO44eT4AtBBwjbTiGPMlt2Md0T9H9JQ==}

snapshots:

  '@types/node@22.15.2':
    dependencies:
      undici-types: 6.21.0

  undici-types@6.21.0: {}
```

## File: setup/githubSsh.sh

```
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

```
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

## File: setup/llms.sh

```
#!/bin/bash

# Script to generate a markdown file with the content of all tracked files in the nixos-config

# Set variables
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(dirname "$SCRIPT_DIR")"
OUTPUT_FILE="$SCRIPT_DIR/nixos-config-context.md"

# Create or truncate the output file
echo "# NixOS Configuration Context for LLMs" > "$OUTPUT_FILE"
echo "" >> "$OUTPUT_FILE"
echo "Generated on $(date)" >> "$OUTPUT_FILE"
echo "" >> "$OUTPUT_FILE"

# Function to add a file's content to the markdown
add_file_to_md() {
    local file_path="$1"
    local rel_path="$(realpath --relative-to="$ROOT_DIR" "$file_path")"
    
    # Skip binary files and very large files
    if [[ -f "$file_path" && "$(file --mime-type -b "$file_path")" != binary* ]]; then
        file_size=$(wc -c < "$file_path")
        if [[ $file_size -gt 500000 ]]; then
            echo "Skipping large file: $rel_path ($file_size bytes)"
            echo "## File: $rel_path" >> "$OUTPUT_FILE"
            echo "**Note**: File too large to include ($file_size bytes)" >> "$OUTPUT_FILE"
            echo "" >> "$OUTPUT_FILE"
            return
        fi
        
        echo "## File: $rel_path" >> "$OUTPUT_FILE"
        echo "" >> "$OUTPUT_FILE"
        echo '```' >> "$OUTPUT_FILE"
        cat "$file_path" >> "$OUTPUT_FILE"
        echo '```' >> "$OUTPUT_FILE"
        echo "" >> "$OUTPUT_FILE"
    fi
}

# Add overall repository structure
echo "## Repository Structure" >> "$OUTPUT_FILE"
echo "" >> "$OUTPUT_FILE"
echo '```' >> "$OUTPUT_FILE"
cd "$ROOT_DIR" && find . -type f -not -path "*/\.git/*" | sort >> "$OUTPUT_FILE"
echo '```' >> "$OUTPUT_FILE"
echo "" >> "$OUTPUT_FILE"

# Get list of all git tracked files
echo "Collecting tracked files..."
cd "$ROOT_DIR" || exit 1
tracked_files=$(git ls-files)

# Add a section for the flake files
echo "## NixOS Configuration Files" >> "$OUTPUT_FILE"
echo "" >> "$OUTPUT_FILE"

# Process each tracked file
total_files=$(echo "$tracked_files" | wc -l)
current=0
echo "Processing $total_files files..."

for file in $tracked_files; do
    # Skip flake.lock file
    if [[ "$file" == "flake.lock" ]]; then
        echo "Skipping flake.lock file"
        continue
    fi
    
    current=$((current + 1))
    if [[ $((current % 10)) -eq 0 ]]; then
        echo "Progress: $current/$total_files files"
    fi
    
    full_path="$ROOT_DIR/$file"
    if [[ -f "$full_path" ]]; then
        add_file_to_md "$full_path"
    fi
done

echo "## System Overview" >> "$OUTPUT_FILE"
echo "" >> "$OUTPUT_FILE"
echo "This NixOS configuration manages the system setup for user 'alex', including:" >> "$OUTPUT_FILE"
echo "- System configurations in 'hosts/'" >> "$OUTPUT_FILE"
echo "- Home-manager configurations in 'home/alex/'" >> "$OUTPUT_FILE"
echo "- Various dotfiles in 'home/alex/dotfiles/'" >> "$OUTPUT_FILE"
echo "" >> "$OUTPUT_FILE"

# Add info about the overall structure
cat >> "$OUTPUT_FILE" << 'EOF'
## Key Components

1. **flake.nix**: The entry point for the NixOS configuration
2. **hosts/**: System-wide configurations
3. **home/alex/**: User-specific configurations managed by home-manager
4. **setup/**: Scripts for system setup and maintenance
EOF

echo "Done! Context file generated at $OUTPUT_FILE"
echo "File size: $(du -h "$OUTPUT_FILE" | cut -f1)"```

## File: setup/nixos-config-context.md

```
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
