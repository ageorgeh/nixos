{
  config,
  pkgs,
  lib,
  ...
}:

{
  systemd.user.services = lib.mkIf pkgs.stdenv.isLinux {
    # Google drive
    rclone-gdrive = {
      Unit = {
        Description = "Mount Google Drive with rclone";
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

    # Verdaccio local npm proxy repo
    verdaccio = {
      Unit = {
        Description = "Verdaccio - A lightweight private npm proxy registry";
        After = "network.target";
      };

      Service = {
        # Check if Verdaccio is installed, if not, install it
        ExecStartPre = "${pkgs.bash}/bin/bash -c '${pkgs.pnpm}/bin/pnpm list -g verdaccio || ${pkgs.pnpm}/bin/pnpm install -g verdaccio'";
        # Start Verdaccio using the globally installed binary
        ExecStart = "/home/alex/.local/share/pnpm/verdaccio";
        Restart = "on-failure";
      };

      Install = {
        WantedBy = [ "default.target" ];
      };
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
