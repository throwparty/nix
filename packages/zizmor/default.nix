{
  lib,
  stdenv,
  fetchFromGitHub,
  installShellFiles,
  rust-jemalloc-sys,
  rust-bin,
  fetchCargoVendor,
  makeRustPlatform,
  versionCheckHook,
}:
let
  rustToolchain = rust-bin.stable.latest.default;
  customRustPlatform = makeRustPlatform {
    cargo = rustToolchain;
    rustc = rustToolchain;
  };
in
customRustPlatform.buildRustPackage (finalAttrs: {
  pname = "zizmor";
  version = "1.30.1";

  src = fetchFromGitHub {
    owner = "zizmorcore";
    repo = "zizmor";
    tag = "v${finalAttrs.version}";
    hash = "sha256-Oay7x5bS85w7bszaUHRyh/PuMA1d4hd7l//HqsV8Z3A=";
  };

  cargoDeps = fetchCargoVendor {
    inherit (finalAttrs) src;
    name = "${finalAttrs.pname}-${finalAttrs.version}-vendor";
    hash = "sha256-0cDYV7e9S6r4xF4UTqH3DAKGmwOkJ/DrOJd8Ohr9LwM=";
  };

  buildInputs = [
    rust-jemalloc-sys
  ];

  nativeBuildInputs = lib.optionals (stdenv.buildPlatform.canExecute stdenv.hostPlatform) [
    installShellFiles
  ];

  postInstall = lib.optionalString (stdenv.buildPlatform.canExecute stdenv.hostPlatform) ''
    installShellCompletion --cmd zizmor \
      --bash <("$out/bin/zizmor" --completions bash) \
      --zsh <("$out/bin/zizmor" --completions zsh) \
      --fish <("$out/bin/zizmor" --completions fish)
  '';

  nativeInstallCheckInputs = [ versionCheckHook ];

  doInstallCheck = true;

  meta = {
    description = "Tool for finding security issues in GitHub Actions setups";
    homepage = "https://docs.zizmor.sh/";
    changelog = "https://github.com/zizmorcore/zizmor/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.mit;
    mainProgram = "zizmor";
  };
})
