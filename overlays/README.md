# Overlays

To use these overlays you either can use the default export to get all of them

```nix
overlays = import ./overlays/default.nix {
    inherit inputs;
};

# ...

import nixpkgs {
    # ...
    overlays = [ overlays.default ];
}

```

or you can specify one or many to use

```nix
inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";
    nixos-config = {
        url = "github:ageorgeh/nixos";
        inputs.nixpkgs.follows = "nixpkgs";
    };
};

# ...

pkgs = import nixpkgs {
    # ...
    overlays = [ nixos-config.overlays.awsSam ];
};

```
