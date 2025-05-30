{ config, pkgs, ... }:

{
  systemd.user.services.verdaccio = {
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

}
