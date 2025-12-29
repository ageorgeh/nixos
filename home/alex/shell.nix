{ config, pkgs, ... }:

{
  programs.zsh.enable = true;
  programs.fzf.enable = true;

  home.shellAliases = {
    nixos-build = "sudo nixos-rebuild switch --flake ~/nixos-config#workstation";
    nixos-update = "sudo nix flake update --flake ~/nixos-config";
    home-build = "home-manager switch --flake ~/nixos-config#alex";
    logout = "hyprctl dispatch exit";
    code = "code --use-angle=vulkan";
    hypr-restart = "hyprctl reload";
    tofi = "tofi-drun | xargs -r hyprctl dispatch exec --"; # Plain tofi bricks the computer lmao
    tofi-clean = "rm -f ~/.cache/tofi-drun";
    tmux-source = "tmux source-file ~/.tmux.conf";
    nvim = "~/scripts/nvim-listen.sh";
  };

  # substituteStream() in derivation catppuccin-sddm-1.1.2: ERROR: pattern CustomBackground=\"false\" doesn't match anything in file '/nix/store/wr1wkhyni95kcnr3z3ax7zh06f7bzy0g-catppuccin-sddm-1.1.2/share/sddm/themes/catppuccin-mocha-mauve/theme.conf'
  #      For full logs, run:

  # Delete unreachable store paths: sudo nix-collect-garbage -d
  # Deduplicate the store: sudo nix store optimise


  programs.bash = {
    enable = true;
    initExtra = ''
      export POMO="/home/alex/.config/pomo"
      export PNPM_HOME="/home/alex/.local/share/pnpm"
      export PATH="$POMO:$PNPM_HOME:$PATH"
      export PLAYWRIGHT_BROWSERS_PATH=${pkgs.playwright-driver.browsers}
      export PLAYWRIGHT_SKIP_VALIDATE_HOST_REQUIREMENTS=true
    '';
  };
}
