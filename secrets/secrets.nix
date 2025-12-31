let
  workstation = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJ0+Pfnxj/rrpUtn9YXFrdFD3s2Wgsy1F8Wz/qFowy0U agenix-workstation";
in
{
  "github-ssh-key.age".publicKeys = [ workstation ];
}
