{
  lib,
  fetchFromGitHub,
  buildDotnetModule,
  dotnetCorePackages,
  jq,
}:
let
  pname = "rzls";
  dotnet-sdk = with dotnetCorePackages; 
    # Don't inherit SDK 8.0 packages and targetPackages as rzls restore can't find the 9.0.11 packages
    combinePackages [
      sdk_9_0
      sdk_8_0
    ];

  dotnet-runtime = dotnetCorePackages.sdk_9_0;
in
buildDotnetModule {
  inherit pname dotnet-sdk dotnet-runtime;

  src = fetchFromGitHub {
    owner = "dotnet";
    repo = "razor";
    rev = "VSCode-CSharp-2.100.11";
    hash = "sha256-+GAoLo4yXnSLbQiWgKpqdOlS72pvhtw0Z2/4qnKCn2g=";
    # rev = "8ffc1c75d0bc26e09ab7553f5cf830996626b8ee";
    # hash = "sha256-FRF253BveWi5mihj94zEwSjwX1f3Cd56B7vbLpFhH2I=";
  };

  version = "9.0.111"; # https://github.com/dotnet/razor/blob/8ffc1c75d0bc26e09ab7553f5cf830996626b8ee/global.json
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
    "-p:PublishReadyToRun=false"
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
