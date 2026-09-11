{ nixpkgs, rust-overlay }:
final: prev:
let
  fetchCargoVendor = import "${nixpkgs.outPath}/pkgs/build-support/rust/fetch-cargo-vendor.nix" {
    inherit (final) lib stdenvNoCC runCommand writers python3Packages cargo gitMinimal cacert;
    nix-prefetch-git = final.nix-prefetch-git.override { git-lfs = null; };
  };
in
{
  zizmor = final.callPackage ../packages/zizmor/default.nix {
    inherit fetchCargoVendor;
    inherit (final) rust-bin makeRustPlatform;
  };
}
