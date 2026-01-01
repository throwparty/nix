{
  description = "throwparty/nix";
  inputs = {
    encore = {
      url = "github:encoredev/encore-flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    flake-utils.url = "github:numtide/flake-utils";
    nixpkgs.url = "github:NixOS/nixpkgs/release-25.11";
  };
  outputs =
    {
      encore,
      flake-utils,
      nixpkgs,
      ...
    }@attrs:
    let
      lib = import ./lib.nix;
    in
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = import nixpkgs {
          inherit system;
        };
      in
      {
        inherit lib;
        devShells = import ./shells/default.nix {
          inherit pkgs;
          inherit encore;
          lib = pkgs.lib // lib;
        };
      }
    )
    // {
      inherit lib;
    }
    // {
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
