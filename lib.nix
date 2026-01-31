{
  mergeShells =
    shell1: shell2:
    shell1.overrideAttrs (old: {
      buildInputs = (old.buildInputs or [ ]) ++ shell2.buildInputs;
      shellHook = old.shellHook + "\n" + shell2.shellHook;
    });

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
}
