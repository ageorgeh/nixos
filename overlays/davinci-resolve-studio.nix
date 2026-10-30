final: prev:
let
  version = "21.1.2";
  # Temporary: remove the version override once nixpkgs provides 21.1.2 or newer.
  resolve =
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
in
{
  # Keep the GUI, ResolvePython and ResolveMCP in the same runtime. Their FHS
  # overrides must use this builder to retain the OGraf Chromium dependencies.
  buildDavinciResolveFHSEnv =
    args:
    prev.buildFHSEnv (
      args
      // {
        # Fusion scans paths independently of fontconfig. Derive its search path
        # from the current user's fontconfig set so system, Home Manager and
        # manually installed fonts work without a Resolve-specific font list.
        profile = (args.profile or "") + ''
          resolveFontDirs="$(${prev.lib.getBin prev.fontconfig}/bin/fc-list --format '%{file|dirname}\n' \
            | ${prev.coreutils}/bin/sort -u \
            | ${prev.coreutils}/bin/paste -sd ';' -)"
          if [ -n "$resolveFontDirs" ]; then
            export FUSION_FONTS="$resolveFontDirs"
          fi
          unset resolveFontDirs

          # Resolve ships only an X11 Qt plugin. Its OGraf Chromium backend
          # connects to Wayland but returns black frames and fails Deliver on
          # this installation, including with explicit frame requests enabled.
          # Scope XWayland selection to Resolve's FHS runtime, not the desktop.
          export QT_QPA_PLATFORM=xcb
          export XDG_SESSION_TYPE=x11
          unset WAYLAND_DISPLAY
        '';

        targetPkgs =
          pkgs:
          args.targetPkgs pkgs
          ++ (with pkgs; [
            at-spi2-core # libatk, libatk-bridge and libatspi
            libgbm
            cairo
            pango
            cups.lib
          ]);
      }
    );

  davinci-resolve-studio = resolve.override {
    buildFHSEnv = final.buildDavinciResolveFHSEnv;
  };
}
