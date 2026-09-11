{
  description = "throwparty/nix";

  inputs = {
    encore = {
      url = "github:encoredev/encore-flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    flake-utils.url = "github:numtide/flake-utils";
    nixpkgs.url = "github:NixOS/nixpkgs/release-26.05";
    rust-overlay = {
      url = "github:oxalica/rust-overlay";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      encore,
      flake-utils,
      nixpkgs,
      rust-overlay,
      ...
    }@attrs:
    let
      lib = import ./lib.nix { lib = nixpkgs.lib; };
      customOverlay = import ./overlays/default.nix { inherit nixpkgs rust-overlay; };
    in
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = import nixpkgs {
          inherit system;
          overlays = [
            (import rust-overlay)
            customOverlay
          ];
        };
      in
      {
        packages.zizmor = pkgs.zizmor;
        devShells = import ./shells/default.nix {
          inherit pkgs;
          inherit encore;
          lib = pkgs.lib // lib;
        };
      }
    )
    // {
      inherit lib;
      overlays.default = customOverlay;
      nixosConfigurations.builder-aarch64 = nixpkgs.lib.nixosSystem {
        system = "aarch64-linux";
        specialArgs = attrs;
        modules = [
          ./builder/lima.nix
        ];
      };
      nixosConfigurations.builder-x86_64 = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = attrs;
        modules = [
          ./builder/ima.nix
        ];
      };
    };
}
