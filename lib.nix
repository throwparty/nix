{
  mkToolVersions =
    { pkgs, name, commands }:
    let
      versionScript = pkgs.writeShellScript "${name}-version-script" ''
        {
          ${commands}
        } >>"$out"
      '';
    in
    pkgs.runCommand "${name}-versions" {
      preferLocalBuild = true;
      allowSubstitutes = false;
    } versionScript;
}
