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
