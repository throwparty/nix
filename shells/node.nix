{ lib, pkgs }:
{
  mkNodeShell =
    {
      baseShell,
      nodejs,
      name ? "node",
      ...
    }:
    let
      toolVersions = lib.mkToolVersions {
        inherit
          name
          pkgs
          ;
        commands = ''
          printf "node %s\n" "$(${nodejs}/bin/node --version 2>&1 | head -n 1)"
          printf "yarn %s\n" "$(${
            pkgs.yarn.override { inherit nodejs; }
          }/bin/yarn --version 2>&1 | head -n 1)"
        '';
      };
    in
    baseShell.overrideAttrs (old: {
      buildInputs = (old.buildInputs or [ ]) ++ [
        nodejs
        pkgs.yarn
      ];
      shellHook = old.shellHook + "\ncat ${toolVersions}";
    });
}
