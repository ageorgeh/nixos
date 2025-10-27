# https://airvpn.org/generator/

# Copy the resulting file from ^ to the server
scp /home/alex/Downloads/AirVPN_Oceania_UDP-443-Entry3.ovpn media-server:/tmp/
ssh media-server
sudo mv /tmp/AirVPN_Oceania_UDP-443-Entry3.ovpn /etc/openvpn/client/airvpn.ovpn

# Create this at /etc/systemd/system/airvpn.service
[Unit]
Description=AirVPN OpenVPN connection
After=network-online.target
Wants=network-online.target

[Service]
ExecStart=/usr/sbin/openvpn --config /etc/openvpn/client/airvpn.ovpn
Restart=on-failure

[Install]
WantedBy=multi-user.target

# Run it 
sudo systemctl enable --now airvpn.service


# Create a forwarded port
# https://airvpn.org/ports/

# In the qbitorrent settings set the Connection>Listening port to this port
