let
  workstation = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJ0+Pfnxj/rrpUtn9YXFrdFD3s2Wgsy1F8Wz/qFowy0U agenix-workstation";
  media = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBTetQKk5C2s9nQOELtx6FFdEGb6cVQZcPW4Ne4JmwH6 agenix-media";
  laptop = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILG/A1/9NKzvBVm4R7Az+iyzRFx7TegRBhrwi/cbPhsl agenix-laptop";
in
{
  "github-ssh-key.age".publicKeys = [
    workstation
    media
    laptop
  ];
  "npm-access-key.age".publicKeys = [
    workstation
    laptop
  ];

  "media-ssh-key.age".publicKeys = [
    workstation
    laptop
  ];

  "airvpn-private-key.age".publicKeys = [
    workstation
    media
    laptop
  ];
  "airvpn-preshared-key.age".publicKeys = [
    workstation
    media
    laptop
  ];

  "qbittorrent-password.age".publicKeys = [
    workstation
    media
  ];

  "floccus.export.json.age".publicKeys = [
    workstation
    laptop
  ];

  "github-nix-ci/ageorgeh.token.age".publicKeys = [
    workstation
    laptop
  ];
}
