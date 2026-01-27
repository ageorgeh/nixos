{
  inputs,
  ...
}:
let
  user = "alex";
  secrets = inputs.self + "/secrets";
in
{
  # imports
  imports = [
    inputs.agenix.nixosModules.default

    ./users.nix
    ./dock.nix
  ];

 nix = {
    enable = false;
    package = pkgs.nix;
    settings = {
      trusted-users = [ "@admin" "${user}" ];
      substituters = [ "https://nix-community.cachix.org" "https://cache.nixos.org" ];
      trusted-public-keys = [ "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY=" ];
      experimental-features = [
      "nix-command"
      "flakes"
    ];
    };

  # https://nixos.wiki/wiki/Storage_optimization
gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 30d";
  };
  optimise = {
    automatic = true;
    dates = [ "weekly" ];
  };

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
    # sudo nix run nix-darwin/master#darwin-rebuild -- switch --flake ~/code/nixos-config#laptop
    nixos-build = "sudo darwin-rebuild switch --flake ~/code/nixos-config#laptop";
  };


  # Secrets
  age.identityPaths = [
    "${ssh}/id_ed25519_agenix"
  ];


  system = {
    checks.verifyNixPath = false;
    primaryUser = user;
    defaults = {
           LaunchServices = {
        LSQuarantine = false;
      };
      NSGlobalDomain = {
        AppleShowAllExtensions = true;
        ApplePressAndHoldEnabled = false;

        # 120, 90, 60, 30, 12, 6, 2
        KeyRepeat = 2;

        # 120, 94, 68, 35, 25, 15
        InitialKeyRepeat = 15;
        "com.apple.mouse.tapBehavior" = 1;
        "com.apple.sound.beep.volume" = 0.0;
        "com.apple.sound.beep.feedback" = 0;
      };
      dock = {
        autohide = false;
        show-recents = false;
        launchanim = true;
        mouse-over-hilite-stack = true;
        orientation = "left";
        tilesize = 48;
      };
      finder = {
        _FXShowPosixPathInTitle = false;
  FXPreferredViewStyle = "Nlsv";
          AppleShowAllExtensions = true;
      };
      trackpad = {
        Clicking = true;
        TrackpadThreeFingerDrag = true;
      };
    };
    keyboard = {
      enableKeyMapping = true;
      remapCapsLockToControl = true;
    };
  };

  system.stateVersion = "24.11";
}