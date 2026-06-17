final: prev: {
  aws-sam-cli = prev.aws-sam-cli.overridePythonAttrs (old: {
    patches =
      (old.patches or [ ])
      ++ [
        ./aws-sam-http-api-authorizer-cors.patch
      ];
  });
}
