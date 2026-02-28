{
  description = "throwparty/nix";

  inputs = {
    encore = {
      url = "github:encoredev/encore-flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    flake-utils.url = "github:numtide/flake-utils";
    nixpkgs.url = "github:NixOS/nixpkgs/release-25.11";
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
    in
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = import nixpkgs {
          inherit system;
          overlays = [
            (import rust-overlay)
          ];
        };
      in
      {
        devShells = import ./shells/default.nix {
          inherit pkgs;
          inherit encore;
          lib = pkgs.lib // lib;
        };
      }
    )
    // {
      inherit lib;
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
