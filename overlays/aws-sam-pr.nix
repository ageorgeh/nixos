# Overrides the aws-sam-cli package to the one from the PR passed in
# also overrides the python packages in the PR for safety 

{ nixpkgs-sam-pr }:
final: prev:
let
  pkgsPr = import nixpkgs-sam-pr {
    inherit (final) system;
    config.allowUnfree = true;
  };
in
{
  aws-sam-cli = pkgsPr.aws-sam-cli;

  # keep python set consistent with the PR
  python312Packages = prev.python312Packages.override (pyFinal: pyPrev: {
    aws-lambda-builders = pkgsPr.python312Packages.aws-lambda-builders;
    ruamel-yaml = pkgsPr.python312Packages.ruamel-yaml;
  });
}
