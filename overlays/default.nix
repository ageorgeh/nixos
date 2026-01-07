{ inputs }:
let
  awsSam = import ./aws-sam-pr.nix;
  nur = inputs.nur.overlays.default;

in
{
  inherit awsSam nur;

  # function form (what many consumers expect)
  default = final: prev: (awsSam final prev) // (nur final prev);

}
