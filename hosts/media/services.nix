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

  services.plex = {
    enable = true;
    openFirewall = true; # TCP 32400
    user = "plex";
    group = "plex";
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
          TempPath = "/srv/downloads/incomplete";
          TempPathEnabled = "true";
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
}
# sudo rg "srv" /var/lib/qBittorrent/qBittorrent/
# sudo rg "srv" /var/lib/qBittorrent/qBittorrent/config/ -L
# /var/lib/qBittorrent/qBittorrent/config/categories.json

# wrong: -rw------- 1 qbittorrent qbittorrent   77 Jan  1  1970 categories.json
# correct: -rw-r--r-- 1 qbittorrent qbittorrent    4 Jan  5 10:34 categories.json
