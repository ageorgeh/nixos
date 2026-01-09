{ inputs }:
let
  awsSam = import ./aws-sam-pr.nix;
  nur = inputs.nur.overlays.default;
  nix-vscode-extensions = inputs.nix-vscode-extensions.overlays.default;

in
{
  inherit awsSam nur nix-vscode-extensions;

  # function form (what many consumers expect)
  default =
    final: prev: (awsSam final prev) // (nur final prev) // (nix-vscode-extensions final prev);

}
