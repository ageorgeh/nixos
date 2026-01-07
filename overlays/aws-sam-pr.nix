# Overrides the aws-sam-cli package to the one from the PR passed in
# also overrides the python packages in the PR for safety

final: prev:
let

  nixPkgsSamPrSrc = builtins.fetchTarball {
    url = "https://github.com/NixOS/nixpkgs/archive/refs/pull/459380/head.tar.gz";
    sha256 = "sha256-9IWfeom+DIki1RiF55tjXRsBtFV0Bnqs8pYkXUZrPpk=";
  };
  pkgsPr = import nixPkgsSamPrSrc {
    inherit (final) system;
    config.allowUnfree = true;
  };
in

{
  aws-sam-cli = pkgsPr.aws-sam-cli;

  # keep python set consistent with the PR
  python312Packages = prev.python312Packages.override (
    pyFinal: pyPrev: {
      aws-lambda-builders = pkgsPr.python312Packages.aws-lambda-builders;
      ruamel-yaml = pkgsPr.python312Packages.ruamel-yaml;
    }
  );
}
