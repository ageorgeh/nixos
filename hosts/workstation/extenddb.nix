{ lib, pkgs, ... }:

let
  stateDir = "/var/lib/extenddb";
  configPath = "${stateDir}/extenddb.toml";
  adminPasswordPath = "${stateDir}/admin-password";
  caCertPath = "${stateDir}/.extenddb/tls/cert.pem";
  clientGroup = "extenddb-clients";
  initialize = pkgs.writeShellScript "extenddb-initialize" ''
    set -euo pipefail
    umask 077

    if [ ! -e ${configPath} ]; then
      if [ ! -s ${adminPasswordPath} ]; then
        ${pkgs.openssl}/bin/openssl rand -hex 32 > ${adminPasswordPath}
      fi

      EXTENDDB_ADMIN_USER=admin \
      EXTENDDB_ADMIN_PASSWORD="$(
        ${pkgs.coreutils}/bin/tr -d '\n' < ${adminPasswordPath}
      )" \
        ${pkgs.extenddb}/bin/extenddb init \
          --pg-host /run/postgresql \
          --pg-user extenddb \
          --extenddb-user extenddb_runtime \
          --config ${configPath} \
          --bind-addr 127.0.0.1
    fi


    ${pkgs.gnused}/bin/sed -Ei \
      -e 's|^#?[[:space:]]*pool_size[[:space:]]*=.*$|pool_size = 40|' \
      -e 's|^#?[[:space:]]*catalog_pool_size[[:space:]]*=.*$|catalog_pool_size = 10|' \
    ${configPath}

    # ${pkgs.extenddb}/bin/extenddb migrate \
    #   --config ${configPath}

    # Optional local-development behaviour.
    ${pkgs.extenddb}/bin/extenddb settings \
      --config ${configPath} \
      set control_plane_delay_seconds 0

    ${pkgs.extenddb}/bin/extenddb settings \
      --config ${configPath} \
      set gsi_propagation_delay_ms 0

    ${pkgs.extenddb}/bin/extenddb settings \
      --config ${configPath} \
      set throttling_enabled false

    ${pkgs.coreutils}/bin/chgrp ${clientGroup} \
      ${stateDir} \
      ${stateDir}/.extenddb \
      ${stateDir}/.extenddb/tls \
      ${adminPasswordPath} \
      ${caCertPath}

    ${pkgs.coreutils}/bin/chmod 0750 \
      ${stateDir} \
      ${stateDir}/.extenddb \
      ${stateDir}/.extenddb/tls

    ${pkgs.coreutils}/bin/chown extenddb:extenddb ${configPath}
    ${pkgs.coreutils}/bin/chmod 0600 ${configPath}
    ${pkgs.coreutils}/bin/chmod 0640 ${adminPasswordPath}
    ${pkgs.coreutils}/bin/chmod 0644 ${caCertPath}
  '';
in
{
  users.groups.extenddb = { };
  users.groups.${clientGroup} = { };
  users.users.extenddb = {
    isSystemUser = true;
    group = "extenddb";
    extraGroups = [ clientGroup ];
    home = stateDir;
    createHome = true;
  };
  users.users.alex.extraGroups = [ clientGroup ];
  users.users.github-runner.extraGroups = [ clientGroup ];

  services.postgresql = {
    enable = true;
    package = pkgs.postgresql_17;
    settings.listen_addresses = lib.mkForce "";
    authentication = lib.mkForce ''
      local all postgres         peer map=postgres
      local all extenddb         peer map=extenddb
      local all extenddb_runtime peer map=extenddb
      local all all              peer
    '';
    identMap = ''
      postgres postgres postgres
      extenddb extenddb extenddb
      extenddb extenddb extenddb_runtime
    '';
    ensureUsers = [
      {
        name = "extenddb";
        ensureClauses = {
          createdb = true;
          createrole = true;
        };
      }
    ];
  };

  environment.systemPackages = [ pkgs.extenddb ];
  environment.sessionVariables = {
    CMS_EXTENDDB_ENDPOINT = "https://localhost:8443";
    CMS_EXTENDDB_ADMIN_PASSWORD_PATH = adminPasswordPath;
    CMS_EXTENDDB_CA_CERT_PATH = caCertPath;
    NODE_EXTRA_CA_CERTS = caCertPath;
  };

  systemd.services.extenddb = {
    description = "ExtendDB DynamoDB-compatible service";
    wantedBy = [ "multi-user.target" ];
    after = [ "postgresql.service" ];
    requires = [ "postgresql.service" ];
    serviceConfig = {
      Type = "simple";
      User = "extenddb";
      Group = "extenddb";
      WorkingDirectory = stateDir;
      ExecStartPre = initialize;
      ExecStart = "${pkgs.extenddb}/bin/extenddb serve --config ${configPath} --port 8443 --foreground";
      Restart = "on-failure";
      RestartSec = 2;
      UMask = "0027";
    };
  };

  systemd.tmpfiles.rules = [
    "d ${stateDir} 0750 extenddb ${clientGroup} -"
  ];
}
