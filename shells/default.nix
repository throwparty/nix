{
  encore,
  lib,
  pkgs,
}:
let
  inherit (lib) getExe getExe';
  encoreFlake = encore;
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
          printf "toml-sort %s\n" "$(${getExe toml-sort} --version)"
          ${getExe' nil "nil"} --version
          ${getExe nixd} --version
        '';
      };
    in
    lib.mergeShells [
      commonTools
      (pkgs.mkShell {
        buildInputs = [
          mdformat
          nil
          nixd
          nixfmt-rfc-style
          toml-sort
        ];
        shellHook = "cat ${toolVersions}";
      })
    ];

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
    pkgs.mkShell {
      buildInputs = [
        encore
        go
        postgresql_15
      ];
      shellHook = "cat ${toolVersions}";
    };

  githubActions =
    let
      inherit (pkgs)
        act
        actionlint
        zizmor
        ;
      toolVersions = lib.mkToolVersions {
        inherit pkgs;
        name = "github_actions";
        commands = ''
          ${getExe act} --version
          printf "actionlint %s\n" "$(${getExe actionlint} --version | head -n 1)"
          ${getExe zizmor} --version
        '';
      };
    in
    pkgs.mkShell {
      buildInputs = [
        act
        actionlint
        zizmor
      ];
      shellHook = "cat ${toolVersions}";
    };

  golang_1_25 = lib.mkGoShell {
    inherit pkgs;
    name = "golang_1_25";
    go = pkgs.go;
  };

  nodejs_24 = lib.mkNodeShell {
    inherit pkgs;
    name = "nodejs_24";
    nodejs = pkgs.nodejs_24;
  };

  rust_stable = lib.mkRustShell {
    inherit pkgs;
    name = "rust_stable";
    rustToolchain = pkgs.rust-bin.stable.latest.default;
  };
}
