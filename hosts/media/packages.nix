{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    vim
    curl
    git
    btop
    ripgrep
    ethtool
    iperf
    sysstat
    toybox

    #
    # ssh tools
    #

    # lsp
    nixd
    nixfmt

    kitty.terminfo # lets you run `clear` when ssh over kitty
  ];

  programs.nix-ld.enable = true;
  programs.nix-ld.libraries = with pkgs; [
    stdenv.cc.cc
    zlib
    openssl
    curl
    icu
  ];
}
