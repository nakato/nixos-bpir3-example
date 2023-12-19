# NixOS on BPi-R3

This respository contains community supported patches that are necessary to run NixOS on BananaPi-R3 and use it as a fully fledget router.

## Getting started

Build an SD-Image with:

```
$ nix build -L '.#nixosConfigurations.bpir3.config.system.build.sdImage'
```

## Features

wifi:

- [x] 2.4 Ghz
- [x] 5 Ghz
  - [x] 160 MHz channel width
  - [x] beam forming
- [x] dual radios
- [ ] Wireless Event Dispatcher (WED) (see #2)
- [ ] vlans

ethernet:

- [x] hardware offloading
- [x] vlans

## u-boot

### u-boot patches

Deriving random static MAC addresses for interfaces is done via patches
applied in the custom u-boot of this repository. This can be pulled in as
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

## real configs

- https://github.com/ghostbuster91/nixos-router
  (bridge eth ports, hw offload, dnsmasq, prometheus, promtail, sops)
