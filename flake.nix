{
  description = "A very basic flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.05";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixos-hardware.url = "github:RadxaYuntian/nixos-hardware/sky1";
  };

  outputs = inputs@{
    self,
    nixpkgs,
    nixpkgs-unstable,
    nixos-hardware,
    ...
  }: 
  let
    prepareNixpkgs = p: import p {
      system = "aarch64-linux";
      config.allowUnfree = true;
      overlays = [
        (import "${nixos-hardware}/cix/sky1/bsp/2025.04/overlay.nix")
        (import "${nixos-hardware}/cix/sky1/bsp/2025.09/overlay.nix")
      ];
    };

    nixpkgs-unfree = prepareNixpkgs nixpkgs;

    nixpkgs-unstable-unfree = prepareNixpkgs nixpkgs-unstable;

    pkgList = [
      "ubootRockPiE"
      "ubootRockPi4"
      "ubootRock4CPlus"
      "ubootRock5ModelB"
      "ubootRadxaZero3W"

      # ""
      # "linuxPackages_6_6_89"
      "cix_gpu_firmware_2025_09"
      "cix_vpu_firmware_2025_09"
    ];

    pkgListUnstable = pkgList ++ [
    ];

    pkgSet = pkgs: names: (nixpkgs.lib.genAttrs names (pkg: pkgs.${pkg}));
    renamePkgSet = prefix: set: (nixpkgs.lib.concatMapAttrs (name: value: {
      "${prefix}-${name}" = value;
    }) set);
    mkPkgSet = pkgs: names: prefix: (renamePkgSet prefix (pkgSet pkgs names));
  in
  {
    packages.aarch64-linux = {
      stable-linuxPackages_6_6_10_kernel = nixpkgs-unfree.linuxPackages_6_6_10.kernel;
      stable-linuxPackages_6_6_89_kernel = nixpkgs-unfree.linuxPackages_6_6_89.kernel;
      stable-linuxPackages_6_6_10_kernel_dev = nixpkgs-unfree.linuxPackages_6_6_10.kernel.dev;
      stable-linuxPackages_6_6_89_kernel_dev = nixpkgs-unfree.linuxPackages_6_6_89.kernel.dev;
      unstable-linuxPackages_6_6_10_kernel = nixpkgs-unstable-unfree.linuxPackages_6_6_10.kernel;
      unstable-linuxPackages_6_6_89_kernel = nixpkgs-unstable-unfree.linuxPackages_6_6_89.kernel;
      unstable-linuxPackages_6_6_10_kernel_dev = nixpkgs-unstable-unfree.linuxPackages_6_6_10.kernel.dev;
      unstable-linuxPackages_6_6_89_kernel_dev = nixpkgs-unstable-unfree.linuxPackages_6_6_89.kernel.dev;
    } // mkPkgSet nixpkgs-unfree pkgList "stable"
    // mkPkgSet nixpkgs-unstable-unfree pkgListUnstable "unstable";
  };
}
