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
    version = "6.3.0-rc2";
    modDirVersion = "6.3.0-rc2";
    src = fetchurl {
      url = "https://git.kernel.org/torvalds/t/linux-6.3-rc2.tar.gz";
      hash = "sha256-n7H6ZIxhUImpfAKlJqr/OCGx/5KpGCKbTQHVqHYL4eg=";
    };
    kernelPatches = [
      { name = "mtk-various-01"; patch =
      (fetchpatch {
        url = "https://lore.kernel.org/netdev/6c9cda3ba51d8f72c63369ec53fe16833db61762.1678357225.git.daniel@makrotopia.org/raw";
        hash = "sha256-2qg77QVlsl4ej5s7mdMoptmE2N69U92fRpE8hWfJ1lo=";
      });}
      { name = "mtk-various-02"; patch =
      (fetchpatch {
        url = "https://lore.kernel.org/netdev/60ec18e3e31a9e639f1b66e354daa150e23b97e3.1678357225.git.daniel@makrotopia.org/raw";
        hash = "sha256-kPSkvlLBi3xYXsElfp+F1F7aOQy9Rj3rjuzEmp1bRrk=";
      });}
      { name = "mtk-various-03"; patch =
      (fetchpatch {
        url = "https://lore.kernel.org/netdev/d4cbd610bda36b8aaeb8dae8386220265098aa09.1678357225.git.daniel@makrotopia.org/raw";
        hash = "sha256-M+Q/ksSekojvZtovzzLQC9wlsCozKYXXlHG+cbnAvJ0=";
      });}
      { name = "mtk-various-04"; patch =
      (fetchpatch {
        url = "https://lore.kernel.org/netdev/defb7b63540a5e56482dace9a30658aa651d6127.1678357225.git.daniel@makrotopia.org/raw";
        hash = "sha256-anVFb8aqfA6BCDtdlbiQh2GUvU/tEtzCTkN5/9Mp0Fo=";
      });}
      { name = "mtk-various-05"; patch =
      (fetchpatch {
        url = "https://lore.kernel.org/netdev/689e941a0408e5a54466d28d22c9130c0599cd0d.1678357225.git.daniel@makrotopia.org/raw";
        hash = "sha256-XT6A2B85BOA+lDgXs4pybUL+H+vQiaUR3JHHbBdg1kk=";
      });}
      { name = "mtk-various-06"; patch =
      (fetchpatch {
        url = "https://lore.kernel.org/netdev/cbfe6670096563a3ee98fb363447a80fe896084a.1678357225.git.daniel@makrotopia.org/raw";
        hash = "sha256-PG+tAtv4s5udeHw4dc2OlWyRyOWFjqxL+7Lzkuaqs30=";
      });}
      { name = "mtk-various-07"; patch =
      (fetchpatch {
        url = "https://lore.kernel.org/netdev/a8102c27d735c0b46eccb739c7a76b76fe20d87d.1678357225.git.daniel@makrotopia.org/raw";
        hash = "sha256-bXhnXCE56Hrx+oDcKCK17lr826uD0A6XOW+s0jopuYk=";
      });}
      { name = "mtk-various-08"; patch =
      (fetchpatch {
        url = "https://lore.kernel.org/netdev/ac3be86c2d25b2b122779eba1ccbc6383d21729b.1678357225.git.daniel@makrotopia.org/raw";
        hash = "sha256-xKp7sV8zm2Q7r0eFqTSO0ZDjVdK1dItflwnKPBA+1Eg=";
      });}
      { name = "mtk-various-09"; patch =
      (fetchpatch {
        url = "https://lore.kernel.org/netdev/3701c3917a6f43d6e5615feaff21a70c68b52371.1678357225.git.daniel@makrotopia.org/raw";
        hash = "sha256-X8IiHQh7PwwygpTHrSzNjejftWG2VSz4bAijW+V22+k=";
      });}
      { name = "mtk-various-10"; patch =
      (fetchpatch {
        url = "https://lore.kernel.org/netdev/b61d952d5e0719e0fc6cc3b1d3576ce9aa1444f5.1678357225.git.daniel@makrotopia.org/raw";
        hash = "sha256-yW7Sk9BIdwTJZDbHT+ZhM/8FVtWprS6zwCXOmY0U4QQ=";
      });}
      { name = "mtk-various-11"; patch =
      (fetchpatch {
        url = "https://lore.kernel.org/netdev/2ac2ee40d3b0e705461b50613fda6a7edfdbc4b3.1678357225.git.daniel@makrotopia.org/raw";
        hash = "sha256-19DjJ1vz3zfTyAkHNcYHdblK1UmEo7y3gqEJVXuZ9JQ=";
      });}
      { name = "mtk-various-12"; patch =
      (fetchpatch {
        url = "https://lore.kernel.org/netdev/ede6bd8c19e232bf3c3898d7b86824b16145b44a.1678357225.git.daniel@makrotopia.org/raw";
        hash = "sha256-iVyYJ1HXMVVuT3eLohclJp5iGSvxS9rDALxOD73vukI=";
      });}
      { name = "mtk-various-13"; patch =
      (fetchpatch {
        url = "https://lore.kernel.org/netdev/effed17bf1932f27f4472ad4e493f2642b12910c.1678357225.git.daniel@makrotopia.org/raw";
        hash = "sha256-jKcNyHLnYg9oBHUdRKuf60T9ICzu1jtS1z1lA1fWpHQ=";
      });}
      { name = "mtk-various-14"; patch =
      (fetchpatch {
        url = "https://lore.kernel.org/netdev/539c90308a48fe9e2be4e8935c582bbded69f71b.1678357225.git.daniel@makrotopia.org/raw";
        hash = "sha256-EZNZKN26pH+73jgZ6BMLS/dLv2p25kJvVnTxPFFahMU=";
      });}
      { name = "mtk-various-15"; patch =
      (fetchpatch {
        url = "https://lore.kernel.org/netdev/89e3ee07b988801b1237af3c93d08386d456d87a.1678357225.git.daniel@makrotopia.org/raw";
        hash = "sha256-xAjdXdXH9sq+ZHrTDU8sshMrebjeXXucc3t/vNS6+S0=";
      });}
      { name = "mtk-various-16"; patch =
      (fetchpatch {
        url = "https://lore.kernel.org/netdev/2d10d7a2de2a94f475c5134868580ddef4852c11.1678357225.git.daniel@makrotopia.org/raw";
        hash = "sha256-lKwee00h12kYNjXNwwdmgutSUO7aqayEw3mmQTnFZ4o=";
      });}
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
