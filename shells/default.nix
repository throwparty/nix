{
  encore,
  lib,
  pkgs,
}:
let
  inherit (lib) getExe getExe';
  encoreFlake = encore;
  node = import ./node.nix { inherit pkgs lib; };
  commonTools =
    let
      inherit (pkgs)
        just
        treefmt
        ;
      toolVersions = lib.mkToolVersions {
        inherit pkgs;
        name = "commonTools";
        commands = ''
          ${getExe just} --version
          ${getExe treefmt} --version
        '';
      };
    in
    pkgs.mkShell {
      buildInputs = [
        just
        treefmt
      ];
      shellHook = "cat ${toolVersions}";
    };
in
{
  inherit commonTools;

  default =
    let
      inherit (pkgs)
        mdformat
        nil
        nixd
        nixfmt-rfc-style
        toml-sort
        ;
      toolVersions = lib.mkToolVersions {
        inherit pkgs;
        name = "default";
        commands = ''
          ${getExe mdformat} --version
          ${getExe nixfmt-rfc-style} --version
          ${getExe toml-sort} --version
          ${getExe' nil "nil"} --version
          ${getExe nixd} --version
        '';
      };
    in
    commonTools.overrideAttrs (old: {
      buildInputs = (old.buildInputs or [ ]) ++ [
        mdformat
        nil
        nixd
        nixfmt-rfc-style
        toml-sort
      ];
      shellHook = old.shellHook + "\ncat ${toolVersions}";
    });

  encore =
    let
      inherit (encoreFlake.packages.${pkgs.stdenv.hostPlatform.system}) encore;
      inherit (pkgs)
        go
        postgresql_15
        ;
      toolVersions = lib.mkToolVersions {
        inherit pkgs;
        name = "encore";
        commands = ''
          ${getExe' encore "encore"} version | grep ^encore
          ${getExe go} version
          ${getExe' postgresql_15 "psql"} --version
        '';
      };
    in
    commonTools.overrideAttrs (old: {
      buildInputs = (old.buildInputs or [ ]) ++ [
        encore
        go
        postgresql_15
      ];
      shellHook = old.shellHook + "\ncat ${toolVersions}";
    });

  nodejs_24 = node.mkNodeShell {
    name = "nodejs_24";
    baseShell = commonTools;
    nodejs = pkgs.nodejs_24;
  };
}
