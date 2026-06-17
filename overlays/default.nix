{ inputs }:
let
  nur = inputs.nur.overlays.default;
  awsSam = import ./aws-sam-pr.nix;

in
{
  inherit nur awsSam;

  # function form (what consumers expect)
  default = final: prev: (nur final prev) // (awsSam final prev);

}
