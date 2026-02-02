# Instructions for setting up Ugoos AM6B+

## First install steps

### Write the image to the USB

2. Identify your USB `lsblk -o NAME,SIZE,MODEL,MOUNTPOINT`
3. Unmount it `sudo umount /dev/sda*`
4. Write the image to the USB `gunzip -c CoreELEC-Amlogic-ng.arm-21.3-Omega-Generic.img.gz | sudo dd of=/dev/sda bs=4M status=progress conv=fsync`
5. Run `sync` and remove the USB.

### Add files

1. Reinsert the USB.
2. Mount and open `COREELEC` and copy `g12b_s922x_ugoos_am6b.dtb` into the root of COREELEC.
   - Rename it `dtb.img`
3. Copy `dovi.ko` and `remote.conf` into the root of COREELEC
4. Run `sync` and remove the USB

### Install

- Remove power from Ugoos
- Insert USB and HDMI to screen. Put toothpick into **recovery** hole (on the bottom).
- Plug in and power on, release the toothpick once the coreelec boot screen is visible
- Do the setup and note the ssh ip address

### Move CoreELEC to eMMC

- `ssh root@ip.address` pw: coreelec.
- Install to the emmc: `ceemmc -x`, `y`, `1`, `y`
- Remove USB. Reboot.
- To speed up CoreELEC go to Settings > CoreELEC > Hardware > eMMMC speed mode > change to `HS200, HS400`

## Update to avdvplus steps

As per the instructions [here](https://github.com/avdvplus/Builds/releases/tag/avdvplus_R1)

- Download the latest `.tar` and move it into the `/storage/.update` folder
- On reboot it will install the update, go to Settings > System > CoreELEC > Reset above settings to default

## Links

### References

- [Notion install guide](https://bossanova808.notion.site/CoreElec-Ugoos-AM6B-with-DV-Install-Notes-1ad88d41a19280ff9846d37d5227a32e)
- [CoreELEC forum install guide](https://discourse.coreelec.org/t/guide-s922x-j-ugoos-am6b-coreelec-ng-installation-and-faqs/51231)

### Operating System

- Official [Releases](https://github.com/coreelec/coreelec/releases)
  - Look for `CoreELEC-Amlogic-ng.arm-21.3-Omega-Generic.img.gz`
- Latest avdvplus release [Builds](https://github.com/avdvplus/Builds/releases)
- pannal [releases](https://github.com/pannal/CoreELEC/releases)
  - Another fork, seems to focus on GUI speed more than playback stuff which avdvplus does. Promising though
  - Look out for T2 which is coming out very soon

### Extras

- Ugoos UR-02 (2nd gen remote) config file: [`remote.conf`](https://github.com/CoreELEC/remotes/blob/master/AmRemote/Ugoos%20UR-02/remote.conf)
- Dolby Vision drivers [dovi.ko](https://dumps.tadiphone.dev/dumps/stream/dv8555-altice/-/raw/franklin-user-12-STTC.220815.001-20230722-release-keys/odm/lib/modules/dovi.ko)

### Useful related links

- [List of P7-FEL films](https://www.reddit.com/r/CoreElecOS/comments/1j3lgw2/list_of_dolby_vision_p7fel_films/?share_id=VqrtTivOgn6yfaB-w6pSD&utm_medium=android_app&utm_name=androidcss&utm_source=share&utm_term=1)
- [Best device for CoreELEC](https://discourse.coreelec.org/t/best-device-for-coreelec-in-2025-and-2026/52405)
- [Good guide on settings](https://markdownpastebin.com/?id=6b43d7751fe24d4d80a9e13257e0b187)
