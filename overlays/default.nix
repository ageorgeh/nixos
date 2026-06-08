{ inputs }:
let
  nur = inputs.nur.overlays.default;

in
{
  inherit nur;

  # function form (what consumers expect)
  default = final: prev: (nur final prev);

}
