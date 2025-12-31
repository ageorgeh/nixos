{ inputs }:

[
  (import ./aws-sam-pr.nix {
    nixpkgs-sam-pr = inputs.nixpkgs-sam-pr;
  })
  inputs.nur.overlays.default
]
