final: prev: {
  extenddb = prev.rustPlatform.buildRustPackage {
    pname = "extenddb";
    version = "0.1.2";
    src = prev.fetchFromGitHub {
      owner = "ExtendDB";
      repo = "extenddb";
      rev = "ecc69e3cc4470019a0bcfb7e5192238aea8b0841";
      hash = "sha256-ocQirI8EHh7gvRd8DRGEzA2fiFHhLiaAAkns5SWr048=";
    };
    cargoHash = "sha256-kW/fd+hZedM11FSjkxNL9lJv7hcl5MMZTbuRIV7wjUo=";
    nativeBuildInputs = with prev; [
      cmake
      perl
      pkg-config
    ];
  };
}
