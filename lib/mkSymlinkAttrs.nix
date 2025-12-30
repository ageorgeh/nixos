{ pkgs, hm, context, runtimeRoot, ... }:

let
  inherit (pkgs) lib;

  runtimePath = path:
    let
      rootStr = toString context;
      pathStr = toString path;
    in
    assert lib.assertMsg (lib.hasPrefix rootStr pathStr)
      "${pathStr} does not start with ${rootStr}";
    runtimeRoot + lib.removePrefix rootStr pathStr;

  mkOutOfStoreSymlink =
    let
      _mkOutOfStoreSymlink = path:
        let
          pathStr = toString path;
          name = hm.strings.storeFileName (baseNameOf pathStr);
        in
        pkgs.runCommandLocal name { } ''
          ln -s ${lib.strings.escapeShellArg pathStr} $out
        '';
    in
    file: _mkOutOfStoreSymlink (runtimePath file);

  # Recursively make OutOfStoreSymlinks for all files inside path.
  mkRecursiveOutOfStoreSymlink = path: link:
    builtins.listToAttrs (
      map
        (file: {
          name = link + "${lib.removePrefix (toString path) (toString file)}";
          value = { source = mkOutOfStoreSymlink file; };
        })
        (lib.filesystem.listFilesRecursive path)
    );

  # Recursively make *regular* symlinks (store paths are fine as-is).
  mkRecursiveSymlink = path: link:
    builtins.listToAttrs (
      map
        (file:
          let
            suffix = builtins.unsafeDiscardStringContext
              (lib.removePrefix (toString path) (toString file));
          in
          {
            name = link + suffix;
            value = { source = file; };
          })
        (lib.filesystem.listFilesRecursive path)
    );

  rmopts = attrs: builtins.removeAttrs attrs [ "source" "recursive" "outOfStoreSymlink" ];

in
fileAttrs:
lib.attrsets.concatMapAttrs
  (name: value:
  let
    recursive = value.recursive or false;
    oos = value.outOfStoreSymlink or false;
  in
  if recursive then
    if oos then
      lib.attrsets.mapAttrs (_: attrs: attrs // rmopts value)
        (mkRecursiveOutOfStoreSymlink value.source name)
    else
      lib.attrsets.mapAttrs (_: attrs: attrs // rmopts value)
        (mkRecursiveSymlink value.source name)
  else if oos then
    { "${name}" = { source = mkOutOfStoreSymlink value.source; } // rmopts value; }
  else
    { "${name}" = value; }
  )
  fileAttrs
