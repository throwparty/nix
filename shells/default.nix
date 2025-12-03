{ lib, pkgs }:
let
  node = import ./node.nix { inherit pkgs lib; };
in
{
  default =
    let
      inherit (lib) getExe getExe';
      inherit (pkgs)
        just
        mdformat
        nil
        nixd
        nixfmt-rfc-style
        toml-sort
        treefmt
        ;
      toolVersions = lib.mkToolVersions "default" ''
        ${getExe just} --version
        ${getExe mdformat} --version
        ${getExe' nil "nil"} --version
        ${getExe nixd} --version
        ${getExe nixfmt-rfc-style} --version
        ${getExe toml-sort} --version
        ${getExe treefmt} --version
      '';
    in
    pkgs.mkShell {
      buildInputs = [
        just
        mdformat
        nil
        nixd
        nixfmt-rfc-style
        toml-sort
        treefmt
      ];
      shellHook = "cat ${toolVersions}";
    };

  nodejs_24 = node.mkNodeShell {
    name = "nodejs_24";
    nodejs = pkgs.nodejs_24;
  };
}
