{
  config,
  pkgs,
  inputs,
  ...
}:
let
  stateRoot = "/var/lib/cms-illustrations";
  artistRoot = "/srv/illustrations";
  runtime = "/var/lib/cms-illustration-runtime/current/worker.mjs";
  profile = pkgs.writeText "illustration-transfer-profile.json" (
    builtins.toJSON {
      tenantId = "1eaf4a1b-918c-4744-8280-a115fe93587f";
      clientId = "3ef61bb2-1a9b-42b4-9392-9d20a5f91e79";
      siteId = "withtabstop.sharepoint.com,eeff3ce1-ac52-4fec-980f-d7cf467430c7,355f64b2-2f17-4a1f-9e05-39261e070254";
      driveId = "b!4Tz_7lKs7E-YD9fPRnQwx7JkXzUXLx9KngU5Jh4HAlSOOWs2tTGCT4MqitElZCBZ";
      siteUrl = "https://withtabstop.sharepoint.com/sites/Illustrations";
      credentialPath = "/run/credentials/cms-illustrations.service/m365.pfx";
      certificateThumbprint = "C0B0DD65B903DD863136FA998688FFFB0B3FD56F";
      smbStatusSocket = "/run/cms-illustration-smb/status.sock";
      smbStatusPath = "${pkgs.samba}/bin/smbstatus";
      inherit stateRoot artistRoot;
      pollSeconds = 15;
      cacheMaxBytes = 4294967296;
      minFreeBytes = 8589934592;
    }
  );
in
{
  users.groups.illustrations = { };
  users.groups.illustration-artists = { };
  users.users.illustrations = {
    isSystemUser = true;
    group = "illustrations";
    extraGroups = [ "illustration-artists" ];
  };
  users.users.roshan = {
    isSystemUser = true;
    group = "illustration-artists";
  };
  age.secrets.illustration-m365-credential = {
    file = inputs.self + "/secrets/illustration-m365-credential.pfx.age";
    mode = "0400";
  };
  age.secrets.illustration-samba-password = {
    file = inputs.self + "/secrets/illustration-samba-password.age";
    mode = "0400";
  };
  systemd.tmpfiles.rules = [
    "d ${stateRoot} 0700 illustrations illustrations - -"
    "d ${stateRoot}/incoming 0700 illustrations illustrations - -"
    "d ${artistRoot} 0755 illustrations illustrations - -"
    "d ${artistRoot}/Packs 0755 illustrations illustrations - -"
    "d ${artistRoot}/Returns 2770 illustrations illustration-artists - -"
    "d /var/lib/cms-illustration-runtime 0755 root root - -"
  ];
  environment.etc."cms/illustration-transfer.json".source = profile;
  services.samba.settings.illustrations = {
    path = artistRoot;
    # Advertise named streams for Apple Files metadata without changing filesystem access rights.
    "vfs objects" = "streams_xattr";
    browseable = "yes";
    "read only" = "no";
    "guest ok" = "no";
    "valid users" = "roshan alex";
    "force group" = "illustration-artists";
    "create mask" = "0660";
    "directory mask" = "2770";
    "force directory mode" = "2770";
    "follow symlinks" = "no";
    "wide links" = "no";
  };
  systemd.services.illustration-samba-account = {
    description = "Configure the illustration-only Samba account";
    wantedBy = [ "multi-user.target" ];
    after = [ "samba-smbd.service" ];
    serviceConfig = {
      Type = "oneshot";
      LoadCredential = [ "password:${config.age.secrets.illustration-samba-password.path}" ];
    };
    script = ''
      set -euo pipefail
      { cat "$CREDENTIALS_DIRECTORY/password"; cat "$CREDENTIALS_DIRECTORY/password"; } | ${pkgs.samba}/bin/smbpasswd -s -a roshan > /dev/null
    '';
  };
  systemd.services.cms-illustrations = {
    description = "Validated illustration transfer and M365 reconciliation";
    wantedBy = [ "multi-user.target" ];
    wants = [
      "network-online.target"
      "cms-illustration-smb-status.service"
    ];
    after = [
      "network-online.target"
      "cms-illustration-smb-status.service"
    ];
    path = [ pkgs.openssl ];
    unitConfig.ConditionPathExists = runtime;
    serviceConfig = {
      User = "illustrations";
      Group = "illustrations";
      SupplementaryGroups = [ "illustration-artists" ];
      ExecStart = "${pkgs.nodejs_24}/bin/node ${runtime} ${profile}";
      LoadCredential = [ "m365.pfx:${config.age.secrets.illustration-m365-credential.path}" ];
      Restart = "on-failure";
      RestartSec = 5;
      TimeoutStopSec = 180;
      UMask = "0022";
      NoNewPrivileges = true;
      PrivateTmp = true;
      ProtectSystem = "strict";
      ProtectHome = true;
      ReadWritePaths = [
        stateRoot
        artistRoot
      ];
      MemoryMax = "4G";
    };
  };
  # This root helper only reports active data writers under Returns over a restricted Unix socket.
  systemd.services.cms-illustration-smb-status = {
    description = "Share-scoped SMB completion observations for illustration intake";
    wantedBy = [ "multi-user.target" ];
    after = [ "samba-smbd.service" ];
    unitConfig.ConditionPathExists = runtime;
    serviceConfig = {
      User = "root";
      Group = "illustrations";
      ExecStart = "${pkgs.nodejs_24}/bin/node ${runtime} ${profile} --smb-status-server";
      RuntimeDirectory = "cms-illustration-smb";
      RuntimeDirectoryMode = "0750";
      UMask = "0027";
      Restart = "on-failure";
      RestartSec = 2;
      NoNewPrivileges = true;
      PrivateTmp = true;
      ProtectSystem = "strict";
      ProtectHome = true;
      # smbstatus initializes Samba's messaging context and lock databases even for a read-only query.
      ReadWritePaths = [
        "/run/cms-illustration-smb"
        "/var/lib/samba/private/msg.sock"
        "/var/lock/samba"
      ];
      MemoryMax = "256M";
    };
  };
}
