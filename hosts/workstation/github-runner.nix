{ inputs, ... }:

# Configures the service for github action to be able to use this machine as the runner
# Creates runners with the labels 'workstation' and 'x86_64-linux'. These labels should be specified to use these runners
{
  imports = [
    inputs.agenix.nixosModules.default
    inputs.github-nix-ci.nixosModules.default
  ];

  age.identityPaths = [
    "/home/alex/.ssh/id_ed25519_agenix"
  ];
  services.github-nix-ci = {
    age.secretsDir = ../../secrets;
    personalRunners = {
      "ageorgeh/cms".num = 1;
    };
  };

}
