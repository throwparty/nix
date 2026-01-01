{
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
