{ lib
, linuxKernel
, linux_6_4
, ...
}:
let
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

  linux_bpir3 = linux_6_4.override {
    inherit kernelPatches;

    # This will take ~22GB to build.  /tmp better be big.
    structuredExtraConfig = with lib.kernel; {
      # Disable extremely unlikely features to reduce build time and storage requirements
      # DRM takes a substantual amount of storage during build
      DRM = no;
      SOUND = no;
      # Where would you attach an IB interface?
      INFINIBAND = lib.mkForce no;

      # Build-in BPiR3 support, many misbehave when compiled as modules.
      # Known problematic drivers are MT7530/DSA and PCIe.

      # PCIe
      PCIE_MEDIATEK = yes;
      PCIE_MEDIATEK_GEN3 = yes;
      # SD/eMMC
      MTD_NAND_ECC_MEDIATEK = yes;
      # Net
      BRIDGE = yes;
      HSR = yes;
      NET_DSA = yes;
      NET_DSA_TAG_MTK = yes;
      NET_DSA_MT7530 = yes;
      NET_VENDOR_MEDIATEK = yes;
      PCS_MTK_LYNXI = yes;
      NET_MEDIATEK_SOC_WED = yes;
      NET_MEDIATEK_SOC = yes;
      NET_MEDIATEK_STAR_EMAC = yes;
      MEDIATEK_GE_PHY = yes;
      # WLAN
      WLAN = yes;
      WLAN_VENDOR_MEDIATEK = yes;
      MT76_CORE  = module;
      MT76_LEDS = yes;
      MT76_CONNAC_LIB = module;
      MT7815E = module;
      MT7986_WMAC = yes;
      # Pinctrl
      EINT_MTK = yes;
      PINCTRL_MTK = yes;
      PINCTRL_MT7986 = yes;
      # Thermal
      MTK_THERMAL = yes;
      MTK_SOC_THERMAL = yes;
      MTK_LVTS_THERMAL = yes;
      # Clk
      COMMON_CLK_MEDIATEK = yes;
      COMMON_CLK_MEDIATEK_FHCTL = yes;
      COMMON_CLK_MT7986 = yes;
      COMMON_CLK_MT7986_ETHSYS = yes;
      # other
      MEDIATEK_WATCHDOG = yes;
      REGULATOR_MT6380 = yes;
    };
  };
in
{
  linuxPackages_bpir3 = linuxKernel.packagesFor linux_bpir3;
}
