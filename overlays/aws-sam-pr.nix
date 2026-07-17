final: prev: {
  aws-sam-cli = prev.aws-sam-cli.overridePythonAttrs (old:
    let
      upgradeTomlkit = pkg:
        if (pkg.pname or "") == "tomlkit" then
          pkg.overridePythonAttrs (_: {
            version = "0.15.0";
            src = prev.fetchPypi {
              pname = "tomlkit";
              version = "0.15.0";
              hash = "sha256-fRqey6MIZjghGxOBTqeckN1U3RGZNWQ3bzqpInH1x6M=";
            };
          })
        else
          pkg;
    in
    {
      patches =
        (old.patches or [ ])
        ++ [
          ./aws-sam-http-api-authorizer-cors.patch
        ];

      dependencies = builtins.map upgradeTomlkit old.dependencies;

      propagatedBuildInputs = builtins.map upgradeTomlkit
        (old.propagatedBuildInputs or [ ]);

      disabledTests =
        (old.disabledTests or [ ])
        ++ [
          # Flaky wall-clock assertion: the operation must finish in strictly less than 4s.
          "test_wait_for_operation"
        ];
    });
}
