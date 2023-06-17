{ buildUBoot
, fetchurl
, pkg-config
, ncurses
, ...
}:
let
  extraPatches = [
      ./mt7986-persistent-mac-from-cpu-uid.patch
      ./mt7986-persistent-wlan-mac-from-cpu-uid.patch
    ];
in
{
  ubootBananaPiR3 = (buildUBoot {
    defconfig = "mt7986a_bpir3_sd_defconfig";
    extraMeta.platforms = ["aarch64-linux"];
    extraPatches = extraPatches;
    postPatch = ''
      cp ${./mt7986-nixos.env} board/mediatek/mt7986/mt7986-nixos.env
    '';
    extraConfig = ''
      CONFIG_AUTOBOOT=y
      CONFIG_BOOTDELAY=1
      CONFIG_USE_BOOTCOMMAND=y
      # Use bootstd and bootflow over distroboot for extlinux support
      CONFIG_BOOTSTD_DEFAULTS=y
      CONFIG_BOOTSTD_FULL=y
      CONFIG_CMD_BOOTFLOW_FULL=y
      CONFIG_DEVICE_TREE_INCLUDES="${./mt7986-mmcboot.dtsi}"
      CONFIG_ENV_SOURCE_FILE="mt7986-nixos"
      # Unessessary as it's not actually used anywhere, value copied verbatum into env
      CONFIG_DEFAULT_FDT_FILE="mediatek/mt7986a-bananapi-bpi-r3.dtb"
      # Big kernels
      CONFIG_SYS_BOOTM_LEN=0x6000000
      # Disable saving env, it isn't tested and probably doesn't work.
      CONFIG_ENV_IS_NOWHERE=y
      CONFIG_LZ4=y
      CONFIG_BZIP2=y
      CONFIG_ZSTD=y
      # The following are used in the tooling to fixup MAC addresses
      CONFIG_BOARD_LATE_INIT=y
      CONFIG_SHA1=y
      CONFIG_OF_BOARD_SETUP=y
    '';
    filesToInstall = [ "u-boot.bin" ];
    src = fetchurl {
      url = "ftp://ftp.denx.de/pub/u-boot/u-boot-2023.07-rc3.tar.bz2";
      hash = "sha256-QuwINnS9MPpMFueMP19FPAjZ9zdZWne13aWVrDoJ2C8=";
    };
    version = "2023.07-rc3";
  }).overrideAttrs (oldAttrs: {
    nativeBuildInputs = oldAttrs.nativeBuildInputs ++ [ pkg-config ncurses ];
    # Wipe out RPi patches; they won't apply.
    patches = extraPatches;
  });
}
