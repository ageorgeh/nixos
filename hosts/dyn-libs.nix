{ config, pkgs, ... }:

# This makes sure that dynamic libraries are available to non native nix programs
# For example dart-sass which expects to find glibc and libcxx in the system path 
# but dart-sass is installed in node_modules and not through nixpkgs
# https://github.com/sass/embedded-host-node/issues/334 look for siggerajamae
{
  programs.nix-ld.enable = true;
  programs.nix-ld.libraries = with pkgs; [
    glibc
    libcxx
  ];

}
