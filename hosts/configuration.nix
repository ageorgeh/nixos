{ config, inputs, pkgs, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ./hardware/input.nix
    ./dyn-libs.nix
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
  networking.nameservers = [
    "8.8.8.8"
    "8.8.4.4"
    "2001:4860:4860::8888"
    "2001:4860:4860::8844"
  ];
  networking.hosts = {
    "127.0.0.1" = [ "localhost" "development.roshandhillonart.com" ];
  };
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




  services.xserver.enable = true;
  services.displayManager.sddm = {
    enable = true;
    theme = "catppuccin-mocha";
    package = pkgs.kdePackages.sddm;
  };
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
    clipse # Clipboard manager - not working right now
    wl-clipboard # Used by clipse
    inputs.rose-pine-hyprcursor.packages.${pkgs.system}.default
    (catppuccin-sddm.override {
      flavor = "mocha";
      font = "Noto Sans";
      fontSize = "9";
      background = "${../home/alex/wallpapers/field_3440x1440.png}";
      loginBackground = true;
    })
  ];

  # https://github.com/dnut/clipboard-sync  
  services.clipboard-sync.enable = true;

  environment.sessionVariables = {
    #   ELECTRON_OZONE_PLATFORM_HINT = "wayland";
    # NIXOS_OZONE_WL = "1";
    #   EDITOR = "code --use-angle=vulkan --wait";
    # The following is good for vscode to pick up the correct keychain 
    XDG_CURRENT_DESKTOP = "GNOME";
    DESKTOP_SESSION = "gnome";
  };


  environment.etc."fuse.conf".text = ''
    user_allow_other
  '';

  # Just allows node to bind to lower ports with node (good for proxy servers)
  security.wrappers.node = {
    owner = "root";
    group = "root";
    capabilities = "cap_net_bind_service=+ep";
    source = "${pkgs.nodejs_23}/bin/node";
  };

  system.stateVersion = "24.11";
}
