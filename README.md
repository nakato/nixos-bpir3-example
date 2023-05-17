# NixOS on BPi-R3 Example

This is an example of booting NixOS on a BPi-R3.

Build an SD-Image with:

```
$ nix build -L '.#nixosConfigurations.bpir3.config.system.build.sdImage'
```
