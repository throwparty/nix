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
    }:
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = import nixpkgs {
          inherit system;
        };
        lib = import ./lib.nix { inherit pkgs; };
      in
      {
        inherit lib;
        devShells = import ./shells/default.nix {
          inherit pkgs;
          inherit encore;
          lib = pkgs.lib // lib;
        };
      }
    );
}
