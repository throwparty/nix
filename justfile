mod workflows ".github/workflows"

set shell := ["bash", "-eux", "-o", "pipefail", "-c"]

default: list

list:
    just --list

fmt:
    treefmt

lint:
    just workflows lint
    nix flake show
    just build

build-devshells +build_args="":
    #!/usr/bin/env bash
    set -eux -o pipefail
    system="$(nix eval --raw --impure --expr 'builtins.currentSystem')"
    shells=( $(nix flake show --json 2>/dev/null | jq -r --arg sys "$system" '.devShells[$sys] | keys[] | ".#devShells." + $sys + "." + .') )
    nix build --no-link --print-build-logs {{ build_args }} "${shells[@]}"

build-packages +build_args="":
    #!/usr/bin/env bash
    set -eux -o pipefail
    system="$(nix eval --raw --impure --expr 'builtins.currentSystem')"
    packages=( $(nix flake show --json 2>/dev/null | jq -r --arg sys "$system" '.packages[$sys] | keys[] | ".#packages." + $sys + "." + .') )
    nix build --no-link --print-build-logs {{ build_args }} "${packages[@]}"

build: build-devshells build-packages
