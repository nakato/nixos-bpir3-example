{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
  };

  outputs =
    { self
    , nixpkgs
    , ...
    }@attrs:
    let
      systems = [ "x86_64-linux" "aarch64-linux" ];
      forAllSystems = f: nixpkgs.lib.genAttrs systems (system: f system);
    in
    {
      formatter = forAllSystems (system:
        nixpkgs.legacyPackages.${system}.nixpkgs-fmt
      );

      packages = forAllSystems (system:
        let
          pkgs = nixpkgs.legacyPackages.${system};
        in
        import ./pkgs { inherit pkgs; }
      );

      nixosModules = import ./modules;

      nixosConfigurations = {
        bpir3 = nixpkgs.lib.nixosSystem {
          system = "aarch64-linux";
          specialArgs = {
            inherit self;
            armTrustedFirmwareMT7986 = self.packages.aarch64-linux.armTrustedFirmwareMT7986;
          };
          modules = [
            ./lib/sd-image-mt7986.nix
            ({ config, lib, self, ...}: {
              # Needs to be updated, a number of patches made it into 6.3
              boot.kernelPackages = self.packages.aarch64-linux.linuxPackages_bpir3;
              # We exclude a number of modules included in the default list. A non-insignificant amount do
              # not apply to embedded hardware like this, so simply skip the defaults.
              #
              # Custom kernel is required as a lot of MTK components misbehave when built as modules.
              # They fail to load properly, leaving the system without working ethernet, they'll oops on
              # remove. MTK-DSA parts and PCIe were observed to do this.
              boot.initrd.includeDefaultModules = false;
              boot.initrd.kernelModules = [ "rfkill" "cfg80211" "mt7915e" ];
              hardware.enableRedistributableFirmware = true;
              # Wireless hardware exists, regulatory database is essential.
              hardware.wirelessRegulatoryDatabase = true;

              # Extlinux compatible with custom uboot patches in this repo, which also provide unique
              # MAC addresses instead of the non-unique one that gets used by a lot of MTK devices...
              boot.loader.grub.enable = false;
              boot.loader.generic-extlinux-compatible.enable = true;
               # Known to work with u-boot; bz2, lzma, and lz4 should be safe too, need to test.
               boot.initrd.compressor = "gzip";
               hardware.deviceTree.filter = "mt7986a-bananapi-bpi-r3.dtb";

               hardware.deviceTree.overlays = [
                 {
                   name = "bpir3-sd-enable";
                   dtsFile = ./bpir3-dts/mt7986a-bananapi-bpi-r3-sd.dts;
                 }
                 {
                   name = "bpir3-nand-enable";
                   dtsFile = ./bpir3-dts/mt7986a-bananapi-bpi-r3-nand.dts;
                 }
                 {
                   name = "bpi-r3 wifi training data";
                   dtsFile = ./bpir3-dts/mt7986a-bananapi-bpi-r3-wirless.dts;
                 }
                 {
                   name = "reset button disable";
                   dtsFile = ./bpir3-dts/mt7986a-bananapi-bpi-r3-pcie-button.dts;
                 }
                 {
                   name = "mt7986a efuses";
                   dtsFile = ./bpir3-dts/mt7986a-efuse-device-tree-node.dts;
                 }
                 {
                   name = "i2c on expansion header";
                   dtsFile = ./bpir3-dts/mt7986a-i2c-gpio-exphdr.dts;
                 }
               ];
            })
            ({lib, ...}: {
              system.stateVersion = lib.mkDefault "22.11";
              networking.hostName = "bpir3";
            })
          ];
        };
      };
    };
}
