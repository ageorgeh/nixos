final: prev: {
  extenddb = prev.rustPlatform.buildRustPackage {
    pname = "extenddb";
    version = "0.1.11";
    src = prev.fetchFromGitHub {
      owner = "ExtendDB";
      repo = "extenddb";
      tag = "v0.1.11";
      hash = "sha256-3EF8iModRtt2XmrQl6Q+kefwipGOZru1BOjjBaDTJCo=";
    };
    cargoHash = "sha256-xDHwICEKy0+mv6TA0+id5ekR8lGwb15oCHTx+FtxabE=";
    nativeBuildInputs = with prev; [
      cmake
      perl
      pkg-config
    ];
  };
}
