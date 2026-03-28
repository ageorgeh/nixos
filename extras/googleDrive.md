# Google drive

TODO the config can be stored in this repo rather than requiring this manual setup

- Store the info from /home/alex/.config/rclone/rclone.conf in a agenix secret and load it and create the config file from that info
  - Probably store the info as JSON and build the conf file from that?

### Setup

This will setup google drive with rclone.

1. run `rclone config`
2. scope = `drive`
3. Go to https://console.cloud.google.com/auth/clients?project=projectName and create a client and obtain the **Client ID** and **Client Secret**
4. run `mkdir ~/Drive`

### Not working

Try `rclone config reconnect gdrive`
