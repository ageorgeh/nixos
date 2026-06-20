final: prev: {
  aws-sam-cli = prev.aws-sam-cli.overridePythonAttrs (old:
    let
      tomlkit = prev.python313Packages.tomlkit.overridePythonAttrs (_: {
        version = "0.15.0";
        src = prev.fetchPypi {
          pname = "tomlkit";
          version = "0.15.0";
          hash = "sha256-fRqey6MIZjghGxOBTqeckN1U3RGZNWQ3bzqpInH1x6M=";
        };
      });
    in
    {
      patches =
        (old.patches or [ ])
        ++ [
          ./aws-sam-http-api-authorizer-cors.patch
        ];

      dependencies = builtins.map
        (pkg:
          if (pkg.pname or "") == "tomlkit" then tomlkit else pkg
        )
        old.dependencies;

      propagatedBuildInputs = builtins.map
        (pkg:
          if (pkg.pname or "") == "tomlkit" then tomlkit else pkg
        )
        (old.propagatedBuildInputs or [ ]);
    });
}
