final: prev:
let
  version = "21.1.2";
in
# Temporary: remove this overlay once the pinned nixpkgs provides 21.1.2 or newer.
{
  davinci-resolve-studio =
    if prev.lib.versionAtLeast prev.davinci-resolve-studio.version version then
      prev.davinci-resolve-studio
    else
      prev.davinci-resolve-studio.override {
        # Override the inner application derivation so the upstream FHS environment,
        # wrappers, GPU dependencies and Studio license binds use the new package.
        stdenv = prev.stdenv // {
          mkDerivation =
            args:
            prev.stdenv.mkDerivation (
              args
              // {
                inherit version;
                src = args.src.overrideAttrs {
                  VERSION = version;
                  # Recursive (NAR) hash of Blackmagic's Linux Studio ZIP.
                  outputHash = "sha256-65cKds8/Sf9OcLIvgoX8mDSUIv2wjq/bicgS7RdEapY=";
                };
                # Upstream uses a recursive attrset, so installPhase captured its version.
                installPhase = prev.lib.replaceStrings [ args.version ] [ version ] args.installPhase;
              }
            );
        };
      };
}
