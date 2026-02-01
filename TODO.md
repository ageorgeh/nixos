- Darwin host
- Put floccus profile import thing in this repo
- Make it so that something like a github action or something runs periodically nixos-update to update the flake
    - Creates a PR with the update 
    - Checks that everything is cached and only creates the PR once everything is in the cache for all 3 systems
    - https://www.reddit.com/r/NixOS/comments/1bo8l1f/how_to_obtain_most_recent_cached_version_of/
- Self hosted github runners
    - https://github.com/juspay/github-nix-ci



nix path-info ".#darwinConfigurations.laptop.system" --system "aarch64-darwin"

nix path-info --derivation ".#darwinConfigurations.laptop.system"
nix-store -q --outputs /nix/store/czj8yigzkfpwlds06jbaqfyhxkr5jppv-darwin-system-26.05.0fc4e7a.drv
nix path-info -r "/nix/store/zndqfli07663g4f6f8jw9hqkg0krircn-darwin-system-26.05.0fc4e7a"