{ config, pkgs, ... }:

{
  programs.zsh.enable = true;
  programs.fzf.enable = true;

  home.shellAliases = {
    nixos-build = "sudo nixos-rebuild switch --flake ~/nixos-config#nixos";
    home-build = "home-manager switch --flake ~/nixos-config#alex";
    logout = "hyprctl dispatch exit";
    code = "code --use-angle=vulkan";
    hypr-restart = "hyprctl reload";
    tofi = "tofi-drun | xargs -r hyprctl dispatch exec --"; # Plain tofi bricks the computer lmao
    tofi-clean = "rm -f ~/.cache/tofi-drun";
    tmux-source = "tmux source-file ~/.tmux.conf";
  };


  programs.bash = {
    enable = true;
    initExtra = ''
      export PNPM_HOME="/home/alex/.local/share/pnpm"
      export PATH="$PNPM_HOME:$PATH"
    '';
  };
}
