final: prev:

let
  version = "0.64.7";
in
{
  gortex = prev.stdenvNoCC.mkDerivation {
    pname = "gortex";
    inherit version;

    src = prev.fetchurl {
      url = "https://github.com/zzet/gortex/releases/download/v${version}/gortex_linux_amd64.tar.gz";
      hash = "sha256-XYeJTZ+gnWX460hlfRTdFu1c4Q3VoDB3zHmY+4V0ANQ=";
    };

    sourceRoot = ".";
    dontBuild = true;

    installPhase = ''
      runHook preInstall

      install -Dm755 gortex "$out/bin/gortex"

      runHook postInstall
    '';

    meta = {
      description = "Code intelligence engine that indexes repositories into a knowledge graph";
      homepage = "https://github.com/zzet/gortex";
      mainProgram = "gortex";
      platforms = [ "x86_64-linux" ];
    };
  };
}
