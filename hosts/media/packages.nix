{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    vim
    curl
    git
    btop
  ];
}
