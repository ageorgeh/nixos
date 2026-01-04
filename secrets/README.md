# nix-secrets

This folder contains **encrypted secrets** managed with **agenix**.
All sensitive material is stored as `.age` files and can only be decrypted by authorized machines.

The config repo defines _where_ secrets are deployed; this folder controls _who can decrypt them_.

---

## Core model

- Each machine has its own **identity keypair** (SSH ed25519, used by agenix)
- Each secret is encrypted to one or more **public keys**
- Machines can only decrypt secrets whose `.age` files include their public key
- Service credentials (GitHub, media servers, API tokens, etc.) live **only** as encrypted files here in this repo

No private keys are ever committed in plaintext.

---

## Terminology

| Term         | Meaning                                                |
| ------------ | ------------------------------------------------------ |
| Identity key | Per-machine SSH key used to decrypt `.age` files       |
| Service key  | Credential used to authenticate to an external service |
| Recipient    | A public key allowed to decrypt a secret               |
| `.age` file  | Encrypted secret                                       |

---

## Prerequisites (trusted machine)

- Nix installed
- agenix available
- Access to this repository
  - New machine use https auth
  - Existing setup use the github ssh key stored in this repo
- At least one identity key already authorized

Run agenix via:

```
nix run github:ryantm/agenix
```

---

# Adding a new secret

This process applies to **any secret** (GitHub, media server, API token, etc.).

## 1. Generate the service credential

Example: GitHub SSH key

```
ssh-keygen -t ed25519 -f github-ssh-key -C "github"
chmod 600 github-ssh-key
```

Example: media server key

```
ssh-keygen -t ed25519 -f media-server-key -C "media-server"
chmod 600 media-server-key
```

Register the **public key** (`.pub`) with the external service.

---

## 2. Encrypt the private key

From this folder:

```
nix run github:ryantm/agenix -- -e github-ssh-key.age
```

When prompted, paste the **private key contents**.

Repeat for additional secrets:

```
nix run github:ryantm/agenix -- -e media-server-key.age
```

After verifying encryption, securely delete plaintext keys:

```
shred -u github-ssh-key media-server-key
```

---

## 3. Declare recipients in `secrets.nix`

Example:

```
let
  laptop = "ssh-ed25519 AAAA... laptop";
  server = "ssh-ed25519 AAAA... server";
in {
  "github-ssh-key.age".publicKeys = [ laptop server ];
  "media-server-key.age".publicKeys = [ server ];
}
```

This controls **which machines can decrypt each secret**.

---

## 4. Re-encrypt and commit

```
nix run github:ryantm/agenix -- -r --identity ~/.ssh/id_ed25519_agenix
git add .
git commit -m "Add new secrets"
git push
```

---

# Adding a new machine

Grant a new machine access **without copying private keys**.

## 1. Generate an identity key on the new machine

```
ssh-keygen -t ed25519 -f ~/.ssh/id_ed25519_agenix -C "agenix-$(hostname)"
chmod 600 ~/.ssh/id_ed25519_agenix
```

Copy the public key:

```
cat ~/.ssh/id_ed25519_agenix.pub
```

---

## 2. Add the new public key (trusted machine)

Edit `secrets.nix`:

```
let
  laptop = "ssh-ed25519 AAAA... laptop";
  server = "ssh-ed25519 AAAA... server";
  newbox = "ssh-ed25519 AAAA... newbox";
in {
  "github-ssh-key.age".publicKeys = [ laptop newbox ];
  "media-server-key.age".publicKeys = [ server ];
}
```

---

## 3. Re-encrypt and push

```
nix run github:ryantm/agenix -- -r --identity ~/.ssh/id_ed25519_agenix
git commit -am "Authorize new machine"
git push
```

---

## 4. Bootstrap the new machine

- Clone this repo using **HTTPS** (PAT or GitHub CLI)
- Ensure `age.identityPaths` points to `~/.ssh/id_ed25519_agenix`
- Build/activate the Nix configuration

Secrets will decrypt automatically.

Once the GitHub SSH key secret is deployed, switch git remotes back to SSH.

`git remote set-url origin git@github.com:ageorgeh/nixos.git`

---

## Security notes

- Public keys are safe to commit
- Private keys must never be committed in plaintext
- Compromising one machine does not unlock others
- Secrets can be scoped per-machine via recipient lists

---

## Summary

- Add secret → encrypt once, choose recipients
- Add machine → add one public key, re-encrypt
- No key copying between machines
- Public config stays public
- Secrets repo remains encrypted
