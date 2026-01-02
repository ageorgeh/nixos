{ ... }:
{
  mkSymlinkAttrs = import ./mkSymlinkAttrs.nix;
  paths = import ./paths.nix;
}
