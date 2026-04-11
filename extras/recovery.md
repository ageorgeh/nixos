# Recovery

If something happens to boot entries follow these steps

- Boot into live usb

```
sudo mount /dev/nvme0n1p5 /mnt
sudo mount /dev/nvme0n1p1 /mnt/boot

sudo git config --global --add safe.directory /mnt/home/alex/nixos-config
sudo nixos-install --root /mnt --flake /mnt/home/alex/nixos-config#workstation --no-root-password
```

- Reboot into BIOS settings and put linux first

- If that doesnt work have a look at `sudo efibootmgr` and change the order with `sudo efibootmgr 0001` etc if required
