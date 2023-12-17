{ pkgs }:
let
  uboot = pkgs.callPackage ./uboot { };
  atf = pkgs.callPackage ./arm-trusted-firmware.nix { inherit (uboot) ubootBananaPiR3; };
  linux = pkgs.callPackage ./linux.nix { };
in
{
  inherit (uboot) ubootBananaPiR3;
  inherit (atf) armTrustedFirmwareMT7986;
} // linux
