# Media server 

This host is a media server running plex, airvpn, qbittorrent


## Summary

### Filesystem

Generic downloads use `/srv/downloads/` and media is stored in `/srv/media`.

### Secrets

Secrets are stored in `.age` files as part of the global setup in the `/secrets` folder of this repo. 

The following secrets are used by this host

- Airvpn private key
- Airvpn preshare key
- Qbittorrent admin password


## Monitoring
Grafana setup:
- http://192.168.20.75:3000
- Connections > Data sources 
    - Add data source prometheus: http://localhost:9090
- Dashboards > Import
    - Dashboard id: 1860


## Verification
### iperf 
Check ethernet connection over LAN. 

First allow the 5201 port in the firewall in networking.nix.

Run `iperf -s` on the media server

Run `iperf -c 192.168.20.75` on the client 


### disk
Server:

`dd if=/srv/media/... of=/dev/null bs=1M status=progress`

Client:

`dd if=/dev/zero of=./2025-05-05-123105_hyprshot.png bs=1M count=4096 status=progress`