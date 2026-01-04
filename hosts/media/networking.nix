{ ... }:

{
  networking = {
    hostName = "media-server";
    interfaces = {
      # Might need dk yet
      # enp2s0.mtu = 1480;
      enp2s0.ipv4.addresses = [
        {
          address = "192.168.20.75";
          prefixLength = 24;
        }
      ];

    };

    networkmanager.enable = true;

    defaultGateway = "192.168.20.1";
    nameservers = [
      "192.168.20.1"
      "1.1.1.1"
    ];

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
