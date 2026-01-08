{ lib, pkgs, ... }:

let
  isLinux = pkgs.stdenv.isLinux;
  isDarwin = pkgs.stdenv.isDarwin;
in
{
  programs.zsh.enable = true;
  programs.fzf.enable = true;

  home.shellAliases = {
    home-build = "home-manager switch --flake ~/nixos-config#alex";
    "firefox-devedition" = "firefox-devedition -P dev"; # Cant find the correct profile without this
    tmux-source = "tmux source-file ~/.tmux.conf";
    nvim = "~/scripts/nvim-listen.sh";
  }
  // lib.optionalAttrs isLinux {
    # nixos
    nixos-build = "sudo nixos-rebuild switch --flake ~/nixos-config#workstation";
    nixos-update = "sudo nix flake update --flake ~/nixos-config";

    # hyprland
    logout = "hyprctl dispatch exit";
    hypr-restart = "hyprctl reload";

    tofi = "tofi-drun | xargs -r hyprctl dispatch exec --"; # Plain tofi bricks the computer lmao
    tofi-clean = "rm -f ~/.cache/tofi-drun";

    # wayland
    code = "code --use-angle=vulkan";
  }
  // lib.optionalAttrs isDarwin {

  };

  # substituteStream() in derivation catppuccin-sddm-1.1.2: ERROR: pattern CustomBackground=\"false\" doesn't match anything in file '/nix/store/wr1wkhyni95kcnr3z3ax7zh06f7bzy0g-catppuccin-sddm-1.1.2/share/sddm/themes/catppuccin-mocha-mauve/theme.conf'
  #      For full logs, run:

  # Delete unreachable store paths: sudo nix-collect-garbage -d
  # Deduplicate the store: sudo nix store optimise

  programs.bash = {
    enable = true;
    bashrcExtra = ''
      eval "$(direnv hook bash)"
    '';
  };
}
