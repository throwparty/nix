{ lib }:
let
  inherit (lib)
    getExe
    getExe';
  customLib = {
    mergeShells =
      shells:
      lib.foldl' (
        acc: shell:
        acc.overrideAttrs (old: {
          buildInputs = (old.buildInputs or [ ]) ++ (shell.buildInputs or [ ]);
          nativeBuildInputs = (old.nativeBuildInputs or [ ]) ++ (shell.nativeBuildInputs or [ ]);
          shellHook = (old.shellHook or "") + "\n" + (shell.shellHook or "");
        })
      ) (builtins.head shells) (builtins.tail shells);

    mkToolVersions =
      {
        pkgs,
        name,
        commands,
      }:
      let
        versionScript = pkgs.writeShellScript "${name}-version-script" ''
          echo "From ${name}:" >>"$out"
          {
            ${commands}
          } | sort | sed 's/^/  /' >>"$out"
        '';
      in
      pkgs.runCommand "${name}-versions" {
        preferLocalBuild = true;
        allowSubstitutes = false;
      } versionScript;

    mkGoShell =
      {
        pkgs,
        go,
        name ? "go",
      }:
      let
        inherit (pkgs)
          delve
          golangci-lint
          golangci-lint-langserver
          gopls
          ;
        toolVersions = customLib.mkToolVersions {
          inherit
            name
            pkgs
            ;
          commands = ''
            printf "delve %s\n" "$(${getExe delve} version | awk '/^Version/ { print $2 }')"
            ${getExe go} version
            ${getExe golangci-lint} --version 2>&1 | head -n 1
            ${getExe gopls} version 2>&1 | head -n 1
          '';
        };
      in
      pkgs.mkShell {
        buildInputs = [
          delve
          go
          golangci-lint
          golangci-lint-langserver
          gopls
        ];
        shellHook = "cat ${toolVersions}";
      };

    mkNodeShell =
      {
        pkgs,
        nodejs,
        name ? "node",
        ...
      }:
      let
        toolVersions = customLib.mkToolVersions {
          inherit
            name
            pkgs
            ;
          commands = ''
            printf "node %s\n" "$(${getExe nodejs} --version 2>&1 | head -n 1)"
            printf "yarn %s\n" "$(${getExe (pkgs.yarn.override { inherit nodejs; })} --version 2>&1 | head -n 1)"
          '';
        };
      in
      pkgs.mkShell {
        buildInputs = [
          nodejs
          pkgs.yarn
        ];
        shellHook = "cat ${toolVersions}";
      };

    mkRustShell =
      {
        pkgs,
        rustToolchain,
        name ? "rust",
        ...
      }:
      let
        toolVersions = customLib.mkToolVersions {
          inherit
            name
            pkgs
            ;
          commands = ''
            ${getExe' rustToolchain "cargo"} --version
            ${getExe' rustToolchain "rustc"} --version
          '';
        };
      in
      pkgs.mkShell {
        buildInputs = [ rustToolchain ];
        shellHook = "cat ${toolVersions}";
      };
  };
in
customLib
