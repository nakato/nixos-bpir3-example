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

  linux_bpir3 = customPackage {
    version = "6.4.0-rc2";
    modDirVersion = "6.4.0-rc2";
    src = fetchurl {
      url = "https://git.kernel.org/torvalds/t/linux-6.4-rc2.tar.gz";
      hash = "sha256-s/0Lwidxfrspxs/wSpypQNjDQKTG2jJ5KujZFl6R8hM=";
    };
    kernelPatches = [
      {
        # Cold boot PCIe/NVMe have stability issues.
        # See: https://forum.banana-pi.org/t/bpi-r3-problem-with-pcie/15152
        #
        # FrankW's first patch added a 100ms sleep, this was rejected upstream.
        # Jianjun posted a patch to the forum for testing, and it appears to me
        # to have accidentally missed a write to the registers between the two
        # sleeps.  This version is modified to include the write, and results
        # in the PCI bridge appearing reliably, but not the NVMe device.
        #
        # Without this patch, the PCI bridge is not present, and rescan does
        # not discover it.  Removing the bridge and then rescanning repeatably
        # gets the NVMe working on cold-boot.
        name = "PCI: mediatek-gen3: handle PERST after reset";
        patch = ./linux-mtk-pcie.patch;
      }
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
