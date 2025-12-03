set shell := ["bash", "-eux", "-o", "pipefail", "-c"]

default: list

list:
    just --list

fmt:
    treefmt

lint:
    nix flake show
    just build

build-devshells:
    nix build '.#devShells.aarch64-darwin.default' '.#devShells.aarch64-darwin.nodejs_24' --print-build-logs

build: build-devshells
