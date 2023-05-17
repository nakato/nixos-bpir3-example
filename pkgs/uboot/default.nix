{ buildUBoot
, fetchurl
, pkg-config
, ncurses
, ...
}:
{
  ubootBananaPiR3 = (buildUBoot {
    defconfig = "mt7986a_bpir3_sd_defconfig";
    extraMeta.platforms = ["aarch64-linux"];
    extraPatches = [
      ./mt7986-default-bootcmd.patch
      ./mt7986-persistent-mac-from-cpu-uid.patch
      ./mt7986-persistent-wlan-mac-from-cpu-uid.patch
    ];
    extraConfig = ''
      CONFIG_DISTRO_DEFAULTS=y
      CONFIG_CMD_SYSBOOT=y
      CONFIG_AUTOBOOT=y
      CONFIG_BOOTDELAY=2
      CONFIG_USE_BOOTCOMMAND=y
      CONFIG_DISTRO_DEFAULTS=y
      CONFIG_DEFAULT_FDT_FILE="mediatek/mt7986a-bananapi-bpi-r3.dtb"
      # Big kernels
      CONFIG_SYS_BOOTM_LEN=0x6000000
      # FIXME: CONFIG_DEFAULT_DEVICE_TREE needs BPi R3 DTS created
      CONFIG_CMD_ERASEENV=y
      CONFIG_CMD_UNLZ4=y
      CONFIG_CMD_UNZIP=y
      CONFIG_CMD_CAT=y
      CONFIG_XXHASH=y
      CONFIG_LZ4=y
      CONFIG_BZIP2=y
      CONFIG_ZSTD=y
      SYS_MALLOC_LEN=400000
      # If setting ethaddr via scripts
      # CONFIG_CMD_SHA1SUM=y
      # If we do it ourself instead of setting env
      # Not sure if this is u-boot fdt or boot fdt.
      # CONFIG_OF_BOARD_FIXUP=y
      # Set the envvars: board_late_init
      CONFIG_BOARD_LATE_INIT=y
      CONFIG_SHA1=y
      # CONFIG_LAST_STAGE_INIT=y Even later
      CONFIG_OF_BOARD_SETUP=y
    '';
    filesToInstall = [ "u-boot.bin" ];
    src = fetchurl {
      url = "ftp://ftp.denx.de/pub/u-boot/u-boot-2023.01.tar.bz2";
      hash = "sha256-aUI7rTgPiaCRZjbonm3L0uRRLVhDCNki0QOdHkMxlQ8=";
    };
    version = "2023.01";
  }).overrideAttrs (oldAttrs: {
    nativeBuildInputs = oldAttrs.nativeBuildInputs ++ [ pkg-config ncurses ];
  });
}
