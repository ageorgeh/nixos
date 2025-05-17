{ pkgs }:


pkgs.mkShell
{
  packages = with pkgs; [
    uv # Alternative to pip https://docs.astral.sh/uv/
  ];
  buildInputs = with pkgs; [
    python313
    pythonManylinuxPackages.manylinux2014Package
    cmake
    ninja
    imagemagick
  ];

  shellHook = ''
    export LD_LIBRARY_PATH="${pkgs.stdenv.cc.cc.lib.outPath}/lib:${pkgs.pythonManylinuxPackages.manylinux2014Package}/lib:$LD_LIBRARY_PATH";
    echo "🐍 Python dev shell loaded"
  '';
}
