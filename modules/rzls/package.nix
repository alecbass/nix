{
  lib,
  fetchFromGitHub,
  buildDotnetModule,
  dotnetCorePackages,
  jq,
}:
let
  pname = "rzls";
  # dotnet-sdk =
  #   with dotnetCorePackages;
  #   sdk_9_0_1xx
  #   // {
  #     inherit (sdk_8_0)
  #       packages
  #       targetPackages
  #       ;
  #   };

  dotnet-sdk =
    with dotnetCorePackages;
    combinePackages [
      sdk_9_0_1xx
      sdk_8_0
    ];
  dotnet-runtime = dotnetCorePackages.runtime_9_0;
in
buildDotnetModule {
  inherit pname dotnet-sdk dotnet-runtime;

  src = fetchFromGitHub {
    owner = "dotnet";
    repo = "razor";
    # rev = "2798396c3481573aa49f9c792179ebbb5e183dca";
    rev = "90c12b14924f312df21758d63d7db6ff0290fa5c"; # main

    # hash = "sha256-tPROplLbKmWTbm0r3844zJX3mUQfIWv9jzjcflM5WJk=";
    hash = "sha256-a0Mg5WozSK/AqSyevkZqYQ4z87GsZYJWvNKzVDc/3Vo="; # main
  };

  # version = "9.0.0-beta.25428.3";
  version = "9.0.109";
  # version = "9.0.0-beta.25111.5";
  projectFile = "src/Razor/src/rzls/rzls.csproj";
  useDotnetFromEnv = true;
  nugetDeps = ./deps.json;

  nativeBuildInputs = [ jq ];

  postPatch = ''
    # Upstream uses rollForward = latestPatch, which pins to an *exact* .NET SDK version.
    jq '.sdk.rollForward = "latestMinor"' < global.json > global.json.tmp
    mv global.json.tmp global.json
  '';

  dotnetFlags = [
    # this removes the Microsoft.WindowsDesktop.App.Ref dependency
    "-p:EnableWindowsTargeting=false"
  ];

  dotnetInstallFlags = [
    "-p:InformationalVersion=$version"
  ];

  passthru = {
    updateScript = ./update.sh;
  };

  meta = {
    homepage = "https://github.com/dotnet/razor";
    description = "Razor language server";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [
      bretek
      tris203
    ];
    mainProgram = "rzls";
  };
}
