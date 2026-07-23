{ inputs }:
let
  nur = inputs.nur.overlays.default;
  awsSam = import ./aws-sam-pr.nix;
  extenddb = import ./extenddb.nix;

in
{
  inherit nur awsSam extenddb;

  # function form (what consumers expect)
  default = final: prev: (nur final prev) // (awsSam final prev) // (extenddb final prev);

}
