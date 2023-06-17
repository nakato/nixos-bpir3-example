# NixOS on BPi-R3 Example

This is an example of booting NixOS on a BPi-R3.

Build an SD-Image with:

```
$ nix build -L '.#nixosConfigurations.bpir3.config.system.build.sdImage'
```


## u-boot

### u-boot patches

Deriving random static MAC addresses for interfaces is done via patches
applied in the custom u-boot of this repository.  This can be pulled in as
an input if desired.

```nix
{
  inputs = {
    bpir3.url = "github:nakato/nixos-bpir3-example";
  };

  # And used somewhere
  firmware = bpir3.packages.aarch64-linux.armTrustedFirmwareMT7986;
}
```

### Notes on upgrading u-boot

Updated u-boot builds use bootstd instead of distroboot to achieve extlinux
booting.  This change requires an update to the partition table of the SD
card.

```
# nix shell nixpkgs#gptfdisk
# sgdisk -t 4:8300 -t 5:EF00 /dev/mmcblk0
```

After this is completed, `bl2.img` can be written to parition 1, and
`fip.bin` to partition 4.
