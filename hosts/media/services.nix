{
  config,
  pkgs,
  lib,
  ...
}:
let
  qbConf = "/var/lib/qBittorrent/qBittorrent/config/qBittorrent.conf";

  categoriesJson = pkgs.writeText "categories.json" (
    builtins.toJSON {
      movies = {
        save_path = "/srv/media/movies";
      };
      tv = {
        save_path = "/srv/media/tv";
      };
    }
  );
in
{
  services.openssh = {
    enable = true;
    settings = {
      PasswordAuthentication = false;
      KbdInteractiveAuthentication = false;
      PermitRootLogin = "no";
    };
  };

  services.jellyfin = {
    enable = true;
    openFirewall = true; # http://192.168.20.75:8096
    user = "plex";
    group = "plex";
  };

  services.samba = {
    enable = true;
    openFirewall = true;

    # Info testparm -s
    # List users: sudo pdbedit -L
    # Create user: sudo smbpasswd -a <user>

    settings = {
      global = {
        "server string" = "Media Server";
        "workgroup" = "WORKGROUP";
        "security" = "user";
        "map to guest" = "never";

        # performance / sanity
        "socket options" = "TCP_NODELAY SO_RCVBUF=131072 SO_SNDBUF=131072";
        "use sendfile" = "yes";

        # permissions
        "unix extensions" = "no";
      };

      media = {
        path = "/srv/media";
        browseable = "yes";
        writable = "yes";
        "read only" = "no";
        "guest ok" = "no";
        "valid users" = "alex";
        "force group" = "media";
        "create mask" = "0664";
        "directory mask" = "0775";
      };

      downloads = {
        path = "/srv/downloads";
        browseable = "yes";
        writable = "yes";
        "read only" = "no";
        "guest ok" = "no";
        "valid users" = "alex";
        "force group" = "media";
        "create mask" = "0664";
        "directory mask" = "0775";
      };

      backups = {
        path = "/srv/backups";
        browseable = "yes";
        writeable = "yes";
        "read only" = "no";
        "guest ok" = "no";
        "valid users" = "kodi";
        "force group" = "backup";
        "create mask" = "0664";
        "directory mask" = "0775";
      };
    };
  };

  services.qbittorrent = {
    enable = true;
    user = "qbittorrent";
    group = "qbittorrent";
    openFirewall = true;
    serverConfig = {
      # https://github.com/qbittorrent/qBittorrent/wiki/Explanation-of-Options-in-qBittorrent
      LegalNotice.Accepted = true;
      Application = {
        MemoryWorkingSetLimit = "2048";
      };
      BitTorrent = {
        Session = {
          DefaultSavePath = "/srv/downloads/complete";
          DisableAutoTMMByDefault = "false"; # enable auto management by default
          DisableAutoTMMTriggers = {
            # move files when category/default save path changes
            CategorySavePathChanged = "false";
            DefaultSavePathChanged = "false";
          };
          Interface = "wg0"; # kill switch
          InterfaceAddress = "10.139.52.237"; # second kill switch
          InterfaceName = "wg0";
          MaxUploads = "30";
          MaxUploadsPerTorrent = "8";
          Port = "20882";
          # TempPath = "/srv/downloads/incomplete";
          # TempPathEnabled = "true";
        };
      };
      Preferences = {
        WebUI = {
          Username = "user";
        };
      };
    };
  };
  systemd.services.qbittorrent.preStart = ''
    set -euo pipefail
    echo "Prestart"

    # Find actual conf if the module writes it elsewhere:
    if [ ! -f ${qbConf} ]; then
      conf="$(find /var/lib -name qBittorrent.conf -print -quit || true)"
      if [ -n "$conf" ]; then
        qbConf="$conf"
      else
        qbConf="${qbConf}"
      fi
    else
      qbConf="${qbConf}"
    fi

    pw="$(cat ${config.age.secrets."qbittorrent-password".path} | tr -d '\n')"

    # Ensure the key exists under [Preferences] as WebUI\Password_PBKDF2=
    # If it exists, replace; if not, append under [Preferences].
    if grep -q '^WebUI\\Password_PBKDF2=' "$qbConf"; then
      echo "Replacing password"
      ${pkgs.gnused}/bin/sed -i "s|^WebUI\\\\Password_PBKDF2=.*$|WebUI\\\\Password_PBKDF2=\"$pw\"|" "$qbConf"
    else
      # insert after [Preferences] header if present, else append
      if grep -q '^\[Preferences\]' "$qbConf"; then
        echo "Appending password to preferences section"
        ${pkgs.gnused}/bin/sed -i "/^\[Preferences\]/a WebUI\\\\Password_PBKDF2=\"$pw\"" "$qbConf"
      else
        echo "Appending preferences section with password"
        printf '\n[Preferences]\nWebUI\\Password_PBKDF2=\"%s\"\n' "$pw" >> "$qbConf"
      fi
    fi

    # chown qbittorrent:qbittorrent "$qbConf"
    # chmod 0600 "$qbConf"
  '';

  systemd.tmpfiles.settings.qbittorrent."/var/lib/qBittorrent/qBittorrent/config/categories.json"."C+" =
    {
      mode = "0644";
      user = "qbittorrent";
      group = "qbittorrent";
      argument = "${categoriesJson}";
    };
  systemd.services.qbittorrent.restartTriggers = lib.mkAfter [ categoriesJson ];

  # monitoring
  services.prometheus.exporters.node = {
    enable = true;
    openFirewall = true;
    port = 9100;
    enabledCollectors = [
      "systemd"
      "filesystem"
      "diskstats"
      "netdev"
      "meminfo"
      "cpu"
      "loadavg"
    ];
  };

  services.prometheus = {
    enable = true;

    scrapeConfigs = [
      {
        job_name = "node";
        static_configs = [
          { targets = [ "127.0.0.1:9100" ]; }
        ];
      }
    ];
  };

  services.grafana = {
    enable = true;
    settings = {
      server = {
        http_addr = "0.0.0.0";
        http_port = 3000;
      };
      security = {
        admin_user = "admin";
      };
    };
  };
}
