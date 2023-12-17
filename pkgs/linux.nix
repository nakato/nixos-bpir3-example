{ lib
, linuxKernel
, linux_6_6
, copyPathToStore
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

  linux_bpir3_6_6 = linux_6_6.override {
    inherit kernelPatches;

    ignoreConfigErrors = false;
    # there's probably more enabled-by-default configs that are better left disabled, but whatever
    structuredExtraConfig = with lib.kernel; {
      /* "Select this option if you are building a kernel for a server or
          scientific/computation system, or if you want to maximize the
          raw processing power of the kernel, irrespective of scheduling
          latencies." */
      PREEMPT_NONE = yes;
      # disable the other preempts
      PREEMPT_VOLUNTARY = lib.mkForce no;
      PREEMPT = no;

      CPU_FREQ_GOV_ONDEMAND = yes;
      CPU_FREQ_DEFAULT_GOV_ONDEMAND = yes;
      CPU_FREQ_DEFAULT_GOV_PERFORMANCE = lib.mkForce no;
      CPU_FREQ_GOV_CONSERVATIVE = yes;
      # disable virtualisation stuff
      VIRTUALIZATION = no;
      XEN = lib.mkForce no;
      # zstd
      # MODULE_COMPRESS_ZSTD = yes;
      MODULE_DECOMPRESS = yes;
      FW_LOADER_COMPRESS_ZSTD = yes;
      # zram
      ZRAM_DEF_COMP_ZSTD = yes;
      CRYPTO_ZSTD = yes;
      ZRAM_MEMORY_TRACKING = yes;
      # router stuff
      IP_FIB_TRIE_STATS = yes;
      IP_ROUTE_CLASSID = yes;
      # adds sysctl net.ipv4.tcp_syncookies
      SYN_COOKIES = yes;
      WIREGUARD = yes;
      INET = yes;
      # stuff for ss
      NETLINK_DIAG = yes;
      # nftables features
      IP_SET = module;
      NF_CONNTRACK = module;
      NF_CONNTRACK_BRIDGE = module;
      NF_CONNTRACK_MARK = yes;
      NF_NAT = module;
      NF_FLOW_TABLE = module;
      NF_FLOW_TABLE_INET = module;
      NF_LOG_ARP = module;
      NF_LOG_IPV4 = module;
      NF_LOG_IPV6 = module;
      NETFILTER_NETLINK_QUEUE = module;
      NFT_BRIDGE_META = module;
      NFT_BRIDGE_REJECT = module;
      NFT_CONNLIMIT = module;
      NFT_CT = module;
      NFT_DUP_IPV4 = module;
      NFT_DUP_IPV6 = module;
      NFT_DUP_NETDEV = module;
      NFT_FIB = module;
      NFT_FIB_IPV4 = module;
      NFT_FIB_IPV6 = module;
      NFT_FIB_INET = module;
      NFT_FIB_NETDEV = module;
      NFT_FLOW_OFFLOAD = module;
      NFT_FWD_NETDEV = module;
      NFT_HASH = module;
      NFT_LIMIT = module;
      NFT_LOG = module;
      NFT_MASQ = module;
      NFT_NAT = module;
      NFT_NUMGEN = module;
      NFT_OSF = module;
      NFT_QUEUE = module;
      NFT_QUOTA = module;
      NFT_REDIR = module;
      NFT_REJECT = module;
      NFT_REJECT_IPV4 = module;
      NFT_REJECT_IPV6 = module;
      NFT_REJECT_INET = module;
      NFT_SOCKET = module;
      NFT_SYNPROXY = module;
      NFT_TPROXY = module;
      NFT_TUNNEL = module;

      BRIDGE = yes;
      HSR = no;
      NET_DSA = yes;

      # packet CLaSsification
      NET_CLS_ROUTE4 = module;
      NET_CLS_FW = module;
      NET_CLS_U32 = module;
      NET_CLS_FLOW = module;
      NET_CLS_CGROUP = module;
      NET_CLS_FLOWER = module;
      NET_CLS_MATCHALL = module;
      NET_EMATCH = yes;
      NET_EMATCH_CMP = module;
      NET_EMATCH_NBYTE = module;
      NET_EMATCH_U32 = module;
      NET_EMATCH_META = module;
      NET_EMATCH_TEXT = module;
      NET_EMATCH_IPSET = module;

      # packet actions
      NET_CLS_ACT = yes;
      NET_ACT_POLICE = module;
      NET_ACT_GACT = module;
      NET_ACT_SAMPLE = module;
      NET_ACT_NAT = module;
      NET_ACT_PEDIT = module;
      NET_ACT_SKBEDIT = module;
      NET_ACT_CSUM = module;
      NET_ACT_MPLS = module;
      NET_ACT_VLAN = module;
      NET_ACT_CONNMARK = module;
      NET_ACT_CTINFO = module;
      NET_ACT_SKBMOD = module;
      NET_ACT_IFE = module;
      NET_ACT_TUNNEL_KEY = module;
      NET_ACT_CT = module;

      # random stuff
      PSAMPLE = module;
      RFKILL = yes;
      CRYPTO_SHA256 = yes;

      # hardware specific stuff
      FB = lib.mkForce no;
      DRM = no;
      SOUND = no;
      INFINIBAND = lib.mkForce no;
      CFG80211 = module;
      MAC80211 = module;
      WLAN = yes;

      NR_CPUS = lib.mkForce (freeform "4");
      SMP = yes;

      SFP = yes;
      ARCH_MEDIATEK = yes;
      COMMON_CLK_MEDIATEK = yes;
      COMMON_CLK_MEDIATEK_FHCTL = yes;
      COMMON_CLK_MT7986 = yes;
      COMMON_CLK_MT7986_ETHSYS = yes;
      CPU_THERMAL = yes;
      THERMAL_OF = yes;
      EINT_MTK = yes;
      MEDIATEK_GE_PHY = yes;
      MEDIATEK_WATCHDOG = yes;
      MTD_NAND_ECC_MEDIATEK = yes;
      MTD_NAND_ECC_SW_HAMMING = yes;
      MTD_NAND_MTK = yes;
      MTD_SPI_NAND = yes;
      MTD_UBI = yes;
      MTD_UBI_BLOCK = yes;
      NVMEM_MTK_EFUSE = yes;
      MTK_HSDMA = yes;
      MTK_INFRACFG = yes;
      MTK_PMIC_WRAP = yes;
      MTK_LVTS_THERMAL = yes;
      MTK_SOC_THERMAL = yes;
      MTK_THERMAL = yes;
      MTK_TIMER = yes;
      NET_DSA_MT7530 = yes;
      NET_DSA_MT7530_MDIO = yes;
      NET_DSA_MT7530_MMIO = yes;
      NET_DSA_TAG_MTK = yes;
      NET_MEDIATEK_SOC = yes;
      NET_MEDIATEK_SOC_WED = yes;
      NET_MEDIATEK_STAR_EMAC = yes;
      NET_SWITCHDEV = yes;
      NET_VENDOR_MEDIATEK = yes;
      PCIE_MEDIATEK = yes;
      PCIE_MEDIATEK_GEN3 = yes;
      PCS_MTK_LYNXI = yes;
      PINCTRL_MTK = yes;
      PINCTRL_MT7986 = yes;
      PWM_MEDIATEK = yes;
      REGULATOR_MT6380 = yes;
      MT76_CORE  = module;
      MT76_LEDS = yes;
      MT76_CONNAC_LIB = module;
      MT7915E = module;
      MT798X_WMAC = yes;
      SPI_MT65XX = yes;
      SPI_MTK_NOR = yes;
      SPI_MTK_SNFI = yes;
      MMC_MTK = yes;

      # keys that are unused in this case
      # used because i got bitten by config keys changing once
      "9P_FSCACHE".tristate = lib.mkForce null; CROS_EC_ISHTP.tristate = lib.mkForce null; CROS_EC_LPC.tristate = lib.mkForce null;
      DRM_AMDGPU_CIK.tristate = lib.mkForce null; DRM_AMDGPU_SI.tristate = lib.mkForce null; DRM_AMDGPU_USERPTR.tristate = lib.mkForce null;
      DRM_AMD_DC_FP.tristate = lib.mkForce null; DRM_AMD_DC_SI.tristate = lib.mkForce null; DRM_DP_AUX_CHARDEV.tristate = lib.mkForce null;
      DRM_FBDEV_EMULATION.tristate = lib.mkForce null; DRM_GMA500.tristate = lib.mkForce null; DRM_LEGACY.tristate = lib.mkForce null;
      DRM_LOAD_EDID_FIRMWARE.tristate = lib.mkForce null; DRM_SIMPLEDRM.tristate = lib.mkForce null; DRM_VBOXVIDEO.tristate = lib.mkForce null;
      DRM_VC4_HDMI_CEC.tristate = lib.mkForce null; FB_3DFX_ACCEL.tristate = lib.mkForce null; FB_ATY_CT.tristate = lib.mkForce null;
      FB_ATY_GX.tristate = lib.mkForce null; FB_EFI.tristate = lib.mkForce null; FB_NVIDIA_I2C.tristate = lib.mkForce null;
      FB_RIVA_I2C.tristate = lib.mkForce null; FB_SAVAGE_ACCEL.tristate = lib.mkForce null; FB_SAVAGE_I2C.tristate = lib.mkForce null;
      FB_SIMPLE.tristate = lib.mkForce null; FB_SIS_300.tristate = lib.mkForce null; FB_SIS_315.tristate = lib.mkForce null;
      FB_VESA.tristate = lib.mkForce null; FONTS.tristate = lib.mkForce null; FONT_8x8.tristate = lib.mkForce null;
      FONT_TER16x32.tristate = lib.mkForce null; FRAMEBUFFER_CONSOLE.tristate = lib.mkForce null;
      FRAMEBUFFER_CONSOLE_DEFERRED_TAKEOVER.tristate = lib.mkForce null;
      FRAMEBUFFER_CONSOLE_DETECT_PRIMARY.tristate = lib.mkForce null; FRAMEBUFFER_CONSOLE_ROTATION.tristate = lib.mkForce null;
      HMM_MIRROR.tristate = lib.mkForce null; HSA_AMD.tristate = lib.mkForce null; HYPERVISOR_GUEST.tristate = lib.mkForce null;
      INFINIBAND_IPOIB.tristate = lib.mkForce null; INFINIBAND_IPOIB_CM.tristate = lib.mkForce null;
      IP_MROUTE_MULTIPLE_TABLES.tristate = lib.mkForce null; JOYSTICK_PSXPAD_SPI_FF.tristate = lib.mkForce null;
      KERNEL_ZSTD.tristate = lib.mkForce null; KEYBOARD_APPLESPI.tristate = lib.mkForce null; KVM_ASYNC_PF.tristate = lib.mkForce null;
      KVM_GENERIC_DIRTYLOG_READ_PROTECT.tristate = lib.mkForce null; KVM_GUEST.tristate = lib.mkForce null; KVM_MMIO.tristate = lib.mkForce null;
      KVM_VFIO.tristate = lib.mkForce null; LOGO.tristate = lib.mkForce null; MICROCODE.tristate = lib.mkForce null;
      MOUSE_PS2_VMMOUSE.tristate = lib.mkForce null; MTRR_SANITIZER.tristate = lib.mkForce null; NFS_FSCACHE.tristate = lib.mkForce null;
      PINCTRL_BAYTRAIL.tristate = lib.mkForce null;
      PINCTRL_CHERRYVIEW.tristate = lib.mkForce null; PM_ADVANCED_DEBUG.tristate = lib.mkForce null; PM_TRACE_RTC.tristate = lib.mkForce null;
      SND_AC97_POWER_SAVE.tristate = lib.mkForce null; SND_DYNAMIC_MINORS.tristate = lib.mkForce null;
      SND_HDA_INPUT_BEEP.tristate = lib.mkForce null; SND_HDA_PATCH_LOADER.tristate = lib.mkForce null;
      SND_HDA_RECONFIG.tristate = lib.mkForce null; SND_OSSEMUL.tristate = lib.mkForce null; SND_USB_CAIAQ_INPUT.tristate = lib.mkForce null;
      VFIO_PCI_VGA.tristate = lib.mkForce null; VGA_SWITCHEROO.tristate = lib.mkForce null; X86_AMD_PLATFORM_DEVICE.tristate = lib.mkForce null;
      X86_CHECK_BIOS_CORRUPTION.tristate = lib.mkForce null; X86_MCE.tristate = lib.mkForce null;
      X86_PLATFORM_DRIVERS_DELL.tristate = lib.mkForce null; X86_PLATFORM_DRIVERS_HP.tristate = lib.mkForce null;
      JOYSTICK_XPAD_FF.tristate = lib.mkForce null; JOYSTICK_XPAD_LEDS.tristate = lib.mkForce null; KEXEC_JUMP.tristate = lib.mkForce null;
      PERF_EVENTS_AMD_BRS.tristate = lib.mkForce null; HVC_XEN.tristate = lib.mkForce null; HVC_XEN_FRONTEND.tristate = lib.mkForce null;
      PARAVIRT_SPINLOCKS.tristate = lib.mkForce null; PCI_XEN.tristate = lib.mkForce null; SWIOTLB_XEN.tristate = lib.mkForce null;
      VBOXGUEST.tristate = lib.mkForce null; XEN_BACKEND.tristate = lib.mkForce null; XEN_BALLOON.tristate = lib.mkForce null;
      XEN_BALLOON_MEMORY_HOTPLUG.tristate = lib.mkForce null; XEN_DOM0.tristate = lib.mkForce null; XEN_EFI.tristate = lib.mkForce null;
      XEN_HAVE_PVMMU.tristate = lib.mkForce null; XEN_MCE_LOG.tristate = lib.mkForce null; XEN_PVH.tristate = lib.mkForce null;
      XEN_PVHVM.tristate = lib.mkForce null; XEN_SAVE_RESTORE.tristate = lib.mkForce null; XEN_SYS_HYPERVISOR.tristate = lib.mkForce null;
    };
  };

  linuxPackages_bpir3_6_6 = linuxKernel.packagesFor linux_bpir3_6_6;
in
{
  inherit
    linuxPackages_bpir3_6_6
    ;

  linuxPackages_bpir3 = linuxPackages_bpir3_6_6;
}
