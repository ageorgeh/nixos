{ config, ... }:

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
          allowedTCPPorts = [ 20882 ];
          allowedUDPPorts = [ 20882 ];
        };
      };
    };

    # wireguard vpn interface
    wg-quick.interfaces.wg0 = {
      autostart = true;
      address = [
        "10.139.52.237/32"
        "fd7d:76ee:e68f:a993:97df:96cb:44e6:32e7/128"
      ];
      dns = [
        "10.128.0.1"
        "fd7d:76ee:e68f:a993::1"
      ];

      privateKeyFile = config.age.secrets."airvpn-private-key".path;
      mtu = 1320;

      peers = [
        {
          publicKey = "PyLCXAQT8KkM4T+dUsOQfn+Ub3pGxfGlxkIApuig+hk=";
          presharedKeyFile = config.age.secrets."airvpn-preshared-key".path;

          endpoint = "oceania3.vpn.airdns.org:1637";
          allowedIPs = [
            "0.0.0.0/0"
            "::/0"
          ];
          persistentKeepalive = 15;
        }
      ];
    };
  };
}
