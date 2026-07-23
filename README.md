# Nix config

## Structure

### Hosts

Each of these is a physical machine and contains machine specific setup

Some aspects may be shared on multiple machines, e.g. nvidia config. Shared config is present in modules

### Home

Each of these is a home configuration. Think of this as representing a role, e.g. the `alex` home config is specifially a setup for programming. It can be used on different machines and OS'. On occasion this requires host specific or OS specific conditionals in the config e.g. hyprland config is not required when this config is used on nix-darwin (macOS)

### [Overlays](./overlays/README.md)

## Secret management

This means that I only need a single service secret for anything and then I manage access to that secret through this repo

Instructions [here](./secrets/README.md)

## Project structure

```bash
nixos-config/
├── bun.lock
├── flake.lock
├── flake.nix
├── go.mod
├── go.sum
├── home/
│   └── alex/
│       ├── default.nix  # entrypoint
│       ├── desktop.nix  # xdg desktop entries
│       ├── dotfiles/
│       │   ├── config/  # symlinked to ~/.config - config files
│       │   └── scripts/  # symlinked to ~/scripts - random scripts
│       ├── environment.nix  # environment variables
│       ├── filesystem.nix  # home filesystem symlinks
│       ├── hyprland.nix  # hyprland config
│       ├── packages.nix  # list of packages
│       ├── programs.nix  # programs with options
│       ├── secrets.nix  # age secret management
│       ├── shell.nix
│       ├── ssh.nix  # ssh config
│       ├── systemd.nix  # user daemons
│       ├── theme.nix  # gtk theme
│       └── wallpapers/
├── hosts/
│   ├── latptop/
│   │   └── default.nix
│   ├── media/
│   │   └── default.nix
│   └── workstation/
│       ├── default.nix
│       ├── dyn-libs.nix  # dynamic libraries unavailable to non native nix programs
│       ├── hardware/
│       │   └── input.nix  # keyboard mappings
│       ├── hardware-configuration.nix
│       └── user.nix  # home manager
├── lib/
│   ├── default.nix
│   ├── mkSymlinkAttrs.nix  # symlinking non store files
│   └── paths.nix  # path constants
├── modules/
│   ├── home/
│   └── nixos/
│       └── hardware/
│           └── nvidia.nix
├── overlays/
│   ├── aws-sam-pr.nix  # replace the aws sam pkg to the updated one from a pr
│   └── default.nix
├── package.json
├── scripts/
│   └── tree/
│       ├── comments.txt
│       ├── ignore.txt
│       ├── make_readme_tree.sh
│       └── stop.txt
├── secrets/
│   ├── github-ssh-key.age
│   ├── README.md
│   └── secrets.nix  # service secret management
└── shells/  # quick access dev shells
    └── python.nix
```

`./scripts/tree/make_readme_tree.sh -C ./scripts/tree/comments.txt -S ./scripts/tree/stop.txt -I ./scripts/tree/ignore.txt --markdown`

## Manual steps

### [Google Drive sync](./extras/googleDrive.md)

### Floccus

- Import the profile for bookmarks syncing. The file can be found at `~/floccus.export.json` as defined [here](home/alex/secrets.nix)
