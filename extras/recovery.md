# Recovery

## First steps

- Try booting the previous NixOS generation.
- If in emergency mode, check:
  - `df -h`
  - `systemctl --failed`

If emergency mode says the root account is locked, edit the NixOS boot entry with `e` and append:

`rescue systemd.setenv=SYSTEMD_SULOGIN_FORCE=1`

## Live USB recovery

Root partition: `/dev/nvme0n1p5`
Boot/EFI partition: `/dev/nvme0n1p4`

Boot into the NixOS live USB:

```sh
sudo mount /dev/nvme0n1p5 /mnt
sudo mount /dev/nvme0n1p4 /mnt/boot

sudo git config --global --add safe.directory /mnt/home/alex/nixos-config

sudo nixos-install --root /mnt \
  --flake /mnt/home/alex/nixos-config#workstation \
  --no-root-password
```

Then reboot

## Bootloader repair

If NixOS is running but the boot menu is stale/broken:

sudo nixos-rebuild --install-bootloader boot --flake .#workstation

Verify:

findmnt /boot
sudo efibootmgr
sudo bootctl list

/boot should be /dev/nvme0n1p4.

## UEFI boot order

View entries:

`sudo efibootmgr`

Change order, for example:

`sudo efibootmgr -o 0004,0003`

Delete a stale entry:

`sudo efibootmgr -b 0001 -B`
