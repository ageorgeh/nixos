{
  inputs,
  ...
}:
let
  ssh = "/home/alex/.ssh";
  secrets = inputs.self + "/secrets";
in
{
  # imports
  imports = [
    inputs.agenix.nixosModules.default

    ./hardware-configuration.nix
    ./networking.nix
    ./packages.nix
    ./services.nix
    ./users.nix

  ];

  # use iGPU instead of nvidia
  services.xserver.videoDrivers = [ "amdgpu" ];
  boot.blacklistedKernelModules = [
    "nvidia"
    "nvidia_drm"
    "nvidia_modeset"
    "nvidia_uvm"
  ];

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  security.sudo.wheelNeedsPassword = false; # TODO

  nix.settings = {
    experimental-features = [
      "nix-command"
      "flakes"
    ];
  };

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

  environment.shellAliases = {
    nixos-build = "sudo nixos-rebuild switch --flake ~/nixos-config#media";
  };

  systemd.tmpfiles.rules = [
    # d <path> <mode> <user> <group> <age> <argument>

    # media - media group has read, execute
    "d /srv/media 2750 root media - -"
    "d /srv/media/movies 2750 root media - -"
    "d /srv/media/tv 2750 root media - -"

    # downloads - downloads group has read, execute. qbittorrent owns
    "d /srv/downloads 2750 qbittorrent downloads - -"
    "d /srv/downloads/incomplete 2750 qbittorrent downloads - -"
    "d /srv/downloads/complete 2750 qbittorrent downloads - -"
  ];

  fileSystems = {
    # noexec on downloads
    "/srv/downloads" = {
      device = "/srv/downloads";
      fsType = "none";
      options = [
        "bind"
        "noexec"
        "nodev"
        "nosuid"
      ];
    };
    # noexec on media
    "/srv/media" = {
      device = "/srv/media";
      fsType = "none";
      options = [
        "bind"
        "noexec"
        "nodev"
        "nosuid"
      ];
    };
  };

  # Secrets
  age.identityPaths = [
    "${ssh}/id_ed25519_agenix"
  ];

  age.secrets."airvpn-private-key" = {
    file = secrets + "/airvpn-private-key.age";
    mode = "600";
  };
  age.secrets."airvpn-preshared-key" = {
    file = secrets + "/airvpn-preshared-key.age";
    mode = "600";
  };
  age.secrets."qbittorrent-password" = {
    file = secrets + "/qbittorrent-password.age";
    owner = "qbittorrent";
    group = "qbittorrent";
    mode = "0400";
  };

  # Power saving options
  powerManagement = {
    cpuFreqGovernor = "ondemand";
    powertop.enable = true;
  };
  services.xserver.enable = false;
  services.printing.enable = false;
  hardware.bluetooth.enable = false;

  # https://nixos.wiki/wiki/Storage_optimization
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 30d";
  };
  nix.optimise = {
    automatic = true;
    dates = [ "weekly" ];
  };

  system.stateVersion = "24.11";
}
