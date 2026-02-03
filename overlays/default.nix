{ inputs }:
let
  nur = inputs.nur.overlays.default;
  nix-vscode-extensions = inputs.nix-vscode-extensions.overlays.default;

in
{
  inherit nur nix-vscode-extensions;

  # function form (what consumers expect)
  default = final: prev: (nur final prev) // (nix-vscode-extensions final prev);

}
