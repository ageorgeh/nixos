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
  # services.xserver.displayManager.gdm.enable = false;
  # services.xserver.desktopManager.gnome.enable = true;
  services.displayManager.sddm.enable = true;
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

  environment.systemPackages = with pkgs; [ ];

  environment.sessionVariables = {
    # Needed for wayland vscode
    ELECTRON_OZONE_PLATFORM_HINT = "wayland";
    NIXOS_OZONE_WL = "1";
    EDITOR = "code --ozone-platform=x11 --wait";
  };


  system.stateVersion = "24.11";
}

