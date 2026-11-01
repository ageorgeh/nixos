{ inputs }:
let
  nur = inputs.nur.overlays.default;
  awsSam = import ./aws-sam-pr.nix;
  extenddb = import ./extenddb.nix;
  gortex = import ./gortex.nix;
  davinciResolveStudio = import ./davinci-resolve-studio.nix;

in
{
  inherit
    nur
    awsSam
    extenddb
    gortex
    davinciResolveStudio
    ;

  default =
    final: prev:
    (nur final prev)
    // (awsSam final prev)
    // (extenddb final prev)
    // (gortex final prev)
    // (davinciResolveStudio final prev);
}
