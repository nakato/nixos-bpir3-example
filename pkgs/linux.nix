{ fetchurl
, fetchpatch
, lib
, linuxKernel
, buildLinux
, recurseIntoAttrs
, copyPathToStore
, ...
}:
let
  # customPackage closure copied from: nixpkgs/pkgs/top-level/linux-kernels.nix
  customPackage = { version, src, modDirVersion ? lib.versions.pad 3 version, configfile, allowImportFromDerivation ? true, kernelPatches }:
    recurseIntoAttrs (linuxKernel.packagesFor (linuxKernel.manualConfig {
      inherit version src modDirVersion configfile allowImportFromDerivation kernelPatches;
    }));

  # Issues:
  # /sys/bus/nvmem/devices/nvmem0/nvmem does not exist; it should
  linux_bpir3 = customPackage {
    version = "6.4.0-rc2";
    modDirVersion = "6.4.0-rc2";
    src = fetchurl {
      url = "https://git.kernel.org/torvalds/t/linux-6.4-rc2.tar.gz";
      hash = "sha256-s/0Lwidxfrspxs/wSpypQNjDQKTG2jJ5KujZFl6R8hM=";
    };
    kernelPatches = [
    ];
    # A working config cannot be built with structedExtraConfig...
    # To disable, say, NET_DSA_TAG_BRCM, B53 needs to first be disabled, which has not yet been prompted for yet.
    # To disable B53, B53_SRAB_DRIVER needs to be disabled, which is prompted afterwards.
    configfile = copyPathToStore ./bpir3_kernel.config;
  };
in
{
  linuxPackages_bpir3 = linux_bpir3;
}
