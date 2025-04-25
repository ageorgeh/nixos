{ config, pkgs, ... }:

{
  programs.bash.enable = true;
  programs.zsh.enable = true;
  programs.fzf.enable = true;

  home.shellAliases = {
    code = "code --ozone-platform=x11";
    nixos-build = "sudo nixos-rebuild switch --flake ~/nixos-config#nixos";
    home-build = "home-manager switch --flake ~/nixos-config#alex";
    logout = "hyprctl dispatch exit";
  };
}
