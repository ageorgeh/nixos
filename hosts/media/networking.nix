{ ... }:

{
  networking = {
    hostName = "media-server";
    interfaces = {
      # Might need dk yet
      # enp2s0.mtu = 1480;
    };
    networkmanager = {
      enable = true;
      ensureProfiles.profiles.media-lan = {
        connection = {
          id = "media-lan";
          type = "ethernet";
          interface-name = "enp2s0";
          autoconnect = true;
        };
        ipv4 = {
          method = "manual";
          addresses = [
            "192.168.20.75/24"
          ];
          gateway = "192.168.20.1";
          dns = [
            "192.168.20.1"
            "1.1.1.1"
          ];
        };
      };
    };

    firewall = {
      enable = true;
      allowedTCPPorts = [
        22
        32400 # plex
        8080 # qbittorrent web ui
      ];

      interfaces = {
        wg0 = {
          # TODO update this once the name of the vpn interface is known
          allowedTCPPorts = [ 20882 ];
          allowedUDPPorts = [ 20882 ];
        };
      };

    };

  };
}
