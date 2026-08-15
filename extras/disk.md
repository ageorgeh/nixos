## Check

- `sudo ncdu --exclude /home/alex/Drive /`

- Delete unreachable store paths: `sudo nix-collect-garbage -d`
- Deduplicate the store: `sudo nix store optimise`

## Docker

- `docker system prune` - removes stopped containers, unused networks, dangling images and unused build cache
- `docker builder prune -a` - prune build cache
- `docker buildx prune -a` - prune buildx cache
- `docker container prune` - remove all stopped containers
- `docker image prune` - remove all
