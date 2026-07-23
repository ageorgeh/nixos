final: prev: {
  extenddb = prev.rustPlatform.buildRustPackage {
    pname = "extenddb";
    version = "0.1.1";
    src = prev.fetchFromGitHub {
      owner = "ExtendDB";
      repo = "extenddb";
      rev = "40ae1e1292dc0e689a1bb02b7df89846c1ff504e";
      hash = "sha256-cJ9ZkJ/1yJmbzhSC+XV2LS1jk/mOh5u+fUOP5BjTS3I=";
    };
    cargoHash = "sha256-QRLKwuTSKnOmTXmP00y3rmxKqqT80UIUNRXCDSDjK24=";
    nativeBuildInputs = with prev; [
      cmake
      perl
      pkg-config
    ];
  };
}
