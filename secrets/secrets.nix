let
  workstation = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJ0+Pfnxj/rrpUtn9YXFrdFD3s2Wgsy1F8Wz/qFowy0U agenix-workstation";
  media = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBTetQKk5C2s9nQOELtx6FFdEGb6cVQZcPW4Ne4JmwH6 agenix-media";
in
{
  "github-ssh-key.age".publicKeys = [
    workstation
    media
  ];
  "media-ssh-key.age".publicKeys = [ workstation ];
}
