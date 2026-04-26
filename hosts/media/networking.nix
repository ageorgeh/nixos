{ config, pkgs, ... }:

{
  # escape hatch:
  # sudo sh -c 'printf "nameserver 8.8.8.8\nnameserver 8.8.4.4\n" > /etc/resolv.conf'

  networking = {
    hostName = "media-server";
    interfaces = {
      enp2s0.mtu = 1480;
      enp2s0.ipv4.addresses = [
        {
          address = "192.168.20.75";
          prefixLength = 24;
        }
      ];

    };

    # networkmanager.enable = true;

    defaultGateway = {
      address = "192.168.20.1";
      interface = "enp2s0";
    };
    nameservers = [
      "8.8.8.8"
      "8.8.4.4"
      "2001:4860:4860::8888"
      "2001:4860:4860::8844"
    ];

    firewall = {
      enable = true;
      allowedTCPPorts = [
        22
        32400 # plex
        8080 # qbittorrent web ui

        # Monitoring
        9090
        3000
        # 5201 # iperf
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
      # dns = [
      #   "10.128.0.1"
      #   "fd7d:76ee:e68f:a993::1"
      # ];

      postUp = ''
        ${pkgs.iproute2}/bin/ip route add default dev wg0 table 200
        ${pkgs.iproute2}/bin/ip rule add from 10.139.52.237/32 table 200

        ${pkgs.iproute2}/bin/ip -6 route add default dev wg0 table 200
        ${pkgs.iproute2}/bin/ip -6 rule add from fd7d:76ee:e68f:a993:97df:96cb:44e6:32e7/128 table 200
      '';

      preDown = ''
        ${pkgs.iproute2}/bin/ip rule del from 10.139.52.237/32 table 200 || true
        ${pkgs.iproute2}/bin/ip route del default dev wg0 table 200 || true

        ${pkgs.iproute2}/bin/ip -6 rule del from fd7d:76ee:e68f:a993:97df:96cb:44e6:32e7/128 table 200 || true
        ${pkgs.iproute2}/bin/ip -6 route del default dev wg0 table 200 || true
      '';

      privateKeyFile = config.age.secrets."airvpn-private-key".path;
      mtu = 1320;

      # do not replace system default route
      table = "off";

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
