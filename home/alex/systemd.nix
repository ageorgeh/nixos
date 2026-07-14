{
  config,
  pkgs,
  lib,
  ...
}:

{
  systemd.user.services = lib.mkIf pkgs.stdenv.isLinux {
    # Google drive
    # journalctl --user -u rclone-gdrive.service -b -n 100 --no-pager

    # TODO this might be failing on startup cause of this new systemd stage one thing
    rclone-gdrive = {
      Unit = {
        Description = "Mount Google Drive with rclone.";
        After = [ "network-online.target" ];
        Wants = [ "network-online.target" ];
      };

      Service = {
        Type = "simple";
        ExecStartPre = "${pkgs.coreutils}/bin/mkdir -p ${config.home.homeDirectory}/Drive";
        ExecStart = ''
          ${pkgs.rclone}/bin/rclone mount \
            --vfs-cache-mode full \
            --vfs-cache-max-age 12h \
            --vfs-cache-max-size 512M \
            --vfs-write-back 10s \
            --poll-interval 10s \
            --dir-cache-time 1m \
            --allow-other \
            gdrive: ${config.home.homeDirectory}/Drive
        '';
        ExecStop = "${pkgs.fuse}/bin/fusermount -u ${config.home.homeDirectory}/Drive";
        Restart = "on-failure";
        RestartSec = 5;
      };

      Install = {
        WantedBy = [ "default.target" ];
      };
    };

    # Install the latest global pnpm packages at login.
    pnpm-global = {
      Unit = {
        Description = "Install global pnpm packages";
      };
      Service = {
        Type = "oneshot";
        Environment = [
          # Should match the variable in ./environment.nix
          "PNPM_HOME=${config.home.homeDirectory}/.local/share/pnpm"
          "PNPM_CONFIG_MINIMUM_RELEASE_AGE=0"
        ];
        ExecStart = "${pkgs.pnpm}/bin/pnpm add --global @openai/codex@latest";
        RemainAfterExit = true;
      };
      Install.WantedBy = [ "default.target" ];
    };

    nosql-workbench-credentials = {
      Unit = {
        Description = "Refresh NoSQL Workbench credentials";
        After = "network.target";
      };

      Service = {
        Type = "oneshot";
        ExecStart = "/home/alex/scripts/write-aws-credentials.sh";
      };
    };

  };

  systemd.user.timers = {

  };
}
