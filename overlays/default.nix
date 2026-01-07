{ inputs }:
let
  awsSam = import ./aws-sam-pr.nix;
  nur = inputs.nur.overlays.default;

in
{
  inherit awsSam nur;

  default = [
    awsSam
    nur
  ];

}
