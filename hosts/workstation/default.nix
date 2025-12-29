{ config, inputs, pkgs, ... }:

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
    experimental-features = [ "nix-command" "flakes" ];
    substituters = [ "https://cache.nixos.org/" "https://hyprland.cachix.org" ];
    trusted-substituters = [ "https://cache.nixos.org/" "https://hyprland.cachix.org" ];
    trusted-public-keys = [ "hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc=" ];
  };

  # boot
  boot.loader.systemd-boot.enable = true;
  boot.loader.systemd-boot.configurationLimit = 3;
  boot.loader.efi.canTouchEfiVariables = true;


  # services 
  services.gnome.gnome-keyring.enable = true;
  services.clipboard-sync.enable = true; # https://github.com/dnut/clipboard-sync  

  services.xserver.enable = true;
  services.displayManager.sddm = {
    enable = true;
    theme = "catppuccin-mocha";
    package = pkgs.kdePackages.sddm;
  };
  services.displayManager.defaultSession = "hyprland";
  services.displayManager.sddm.autoLogin.enable = false;

  # security
  security.pam.services.greetd.enableGnomeKeyring = true;
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
    "127.0.0.1" = [ "localhost" "development.roshandhillonart.com" ];
  };
  networking.firewall.allowedTCPPorts = [ 5174 8000 ];
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
  # programs.hyprland.enable = true;
  programs.hyprland = {
    enable = true;
    package = inputs.hyprland.packages.${pkgs.system}.default;
    portalPackage = inputs.hyprland.packages.${pkgs.system}.xdg-desktop-portal-hyprland;
  };
  programs.firefox.enable = true;

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


  environment.systemPackages = with pkgs; [
    git
    # TODO remove
    home-manager # Needed before user installs so that packages can be fetched
    seahorse # GUI for managing stored keyring secrets
    nvidia-vaapi-driver
    clipse # Clipboard manager - not working right now
    wl-clipboard # Used by clipse

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

    inputs.rose-pine-hyprcursor.packages.${pkgs.system}.default
    (catppuccin-sddm.override {
      flavor = "mocha";
      font = "Noto Sans";
      fontSize = "9";
      background = "${../../home/alex/wallpapers/field_3440x1440.png}";
      loginBackground = true;
    })
  ];



  environment.sessionVariables = {
    # The following is good for vscode to pick up the correct keychain 
    XDG_CURRENT_DESKTOP = "GNOME";
    DESKTOP_SESSION = "gnome";
  };


  environment.etc."pkgconfig/openblas.pc".source =
    "${pkgs.openblas.dev}/lib/pkgconfig/openblas64.pc";

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

  system.stateVersion = "24.11";
}
