## Check

- `sudo ncdu --exclude /home/alex/Drive /`

- Delete unreachable store paths: `sudo nix-collect-garbage -d`
- Deduplicate the store: `sudo nix store optimise`

## Docker

- `docker container prune` - remove all stopped containers
- `docker image prune` - remove all
