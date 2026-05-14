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
    rclone-gdrive = {
      Unit = {
        Description = "Mount Google Drive with rclone.";
        After = [
          "graphical-session.target"
          "default.target"
        ];
        Wants = [ "graphical-session.target" ];
      };

      Service = {
        Type = "simple";
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
        WantedBy = [ "graphical-session.target" ];
      };
    };

    # Install global pnpm packages
    pnpm-global = {
      Unit = {
        Description = "Install pnpm global packages";
      };
      Service = {
        Type = "oneshot";
        Environment = [
          # Should match the variable in ./environment.nix
          "PNPM_HOME = ${config.home.homeDirectory}/.local/share/pnpm"
        ];
        ExecStart = "${pkgs.pnpm}/bin/pnpm add -g @samuelfaj/distill";
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
