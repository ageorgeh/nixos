{
  inputs,
  pkgs,
  ...
}:

{
  # imports
  imports = [
    ./hardware-configuration.nix
    ./hardware/input.nix
    ./dyn-libs.nix
    ./user.nix

    ../../modules/nixos/hardware/nvidia.nix
  ];

  nix.settings = {
    experimental-features = [
      "nix-command"
      "flakes"
    ];
    substituters = [
      "https://hyprland.cachix.org"
      "https://nix-community.cachix.org"
      "https://cache.nixos-cuda.org"
    ];
    trusted-substituters = [
      "https://hyprland.cachix.org"
      "https://nix-community.cachix.org"
      "https://cache.nixos-cuda.org"
    ];
    trusted-public-keys = [
      "hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc="
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      "cache.nixos-cuda.org:74DUi4Ye579gUqzH4ziL9IyiJBlDpMRn9MBN8oNan9M="
    ];
  };

  # boot
  boot.loader.systemd-boot.enable = true;
  boot.loader.systemd-boot.configurationLimit = 3;
  boot.loader.efi.canTouchEfiVariables = true;

  # services
  services.gnome.gnome-keyring.enable = true;
  services.clipboard-sync.enable = true; # https://github.com/dnut/clipboard-sync

  # xserver + sddm used as it looks good and works with minimal config
  services.xserver = {
    enable = true;
    # keyboard layout
    xkb = {
      layout = "au";
      variant = "";
    };
  };

  services.displayManager = {
    sddm = {
      enable = true;
      wayland.enable = false;
      theme = "catppuccin-mocha-peach";
      package = pkgs.kdePackages.sddm;
    };
    defaultSession = "hyprland";
    autoLogin.enable = false;
  };

  # network discovery
  services.gvfs.enable = true;
  services.dbus.enable = true;
  services.samba.enable = true;
  services.avahi = {
    enable = true;
    nssmdns4 = true;
  };

  # security
  security.pam.services.hyprland.enableGnomeKeyring = true;
  security.pam.services.sddm.enableGnomeKeyring = true;

  # networking
  networking.hostName = "workstation";
  networking.nameservers = [
    "8.8.8.8"
    "8.8.4.4"
    "2001:4860:4860::8888"
    "2001:4860:4860::8844"
  ];
  networking.hosts = {
    "127.0.0.1" = [
      "localhost"
      "development.roshandhillonart.com"
    ];
  };
  networking.firewall.allowedTCPPorts = [
    5174
    8000
  ];
  # nixos quirk with the ISP, higher or default mtu don't work
  networking.interfaces.enp3s0.mtu = 1480;

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

  # programs
  programs.hyprland = {
    enable = true;
    package = inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.default;
    portalPackage =
      inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.xdg-desktop-portal-hyprland;
  };

  programs.dconf.enable = true;

  services.printing.enable = true;

  # Not required with pipewire
  services.pulseaudio.enable = false;
  # rtkit (optional, recommended) allows Pipewire to use the realtime scheduler for increased performance.
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

  environment.systemPackages = with pkgs; [
    git
    seahorse # GUI for managing stored keyring secrets
    nvidia-vaapi-driver
    clipse # Clipboard manager - not working right now
    wl-clipboard # Used by clipse
    wsdd

    # Compilers - remove??
    cmake
    extra-cmake-modules
    pkg-config
    openblas
    gcc
    libgcc
    libcxx
    gnumake
    gfortran
    zlib
    libjpeg
    libffi

    inputs.rose-pine-hyprcursor.packages.${pkgs.stdenv.hostPlatform.system}.default

    # https://github.com/catppuccin/sddm?tab=readme-ov-file#nixos
    (catppuccin-sddm.override {
      flavor = "mocha";
      accent = "peach";
      font = "Noto Sans";
      fontSize = "9";
      background = "${../../home/alex/wallpapers/gruvbox-nix.png}";
      loginBackground = false;
    })
  ];

  environment.sessionVariables = {
    # Required for vscode to pick up the correct keychain
    XDG_CURRENT_DESKTOP = "GNOME";
    DESKTOP_SESSION = "gnome";
  };

  environment.etc."pkgconfig/openblas.pc".source = "${pkgs.openblas.dev}/lib/pkgconfig/openblas64.pc";

  environment.variables = { };

  environment.etc."fuse.conf".text = ''
    user_allow_other
  '';

  # Just allows node to bind to lower ports (good for proxy servers)
  security.wrappers.node = {
    owner = "root";
    group = "root";
    capabilities = "cap_net_bind_service=+ep";
    source = "${pkgs.nodejs_24}/bin/node";
  };

  # run ./setup/setup-smb.sh to create the credentials file
  # potentially just move it to agenix
  fileSystems."/mnt/media" = {
    device = "//192.168.20.75/media";
    fsType = "cifs";

    options = [
      "credentials=/etc/nixos/secret/smb-credentials"
      "iocharset=utf8"
      "x-systemd.automount"
      "noatime"
      "_netdev"
      "serverino"

      "uid=1003" # alex
      "gid=100"
      "file_mode=0664"
      "dir_mode=0775"
    ];
  };

  system.stateVersion = "24.11";
}
