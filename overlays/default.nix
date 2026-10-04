{ inputs }:
let
  nur = inputs.nur.overlays.default;
  awsSam = import ./aws-sam-pr.nix;
  extenddb = import ./extenddb.nix;
  gortex = import ./gortex.nix;

in
{
  inherit
    nur
    awsSam
    extenddb
    gortex
    ;

  default =
    final: prev:
    (nur final prev) // (awsSam final prev) // (extenddb final prev) // (gortex final prev);
}
