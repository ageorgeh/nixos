{ config, inputs, ... }:


{
  boot.kernelParams = [ "nvidia-drm.modeset=1" ];

  services.xserver.videoDrivers = [ "nvidia" ];

  hardware.nvidia = {
    modesetting.enable = true;
    powerManagement.enable = true;
    powerManagement.finegrained = false;
    open = false;
    nvidiaSettings = true;
  };

  hardware.nvidia-container-toolkit.enable = true; # Use --device=nvidia.com/gpu=all when running containers needing GPU access
}
