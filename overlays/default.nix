{ inputs }:
let
  awsSam = (
    import ./aws-sam-pr.nix {
      inherit (inputs) nixpkgs-sam-pr;
    }
  );
  nur = inputs.nur.overlays.default;

in
{
  inherit awsSam nur;

  default = [
    awsSam
    nur
  ];

}
