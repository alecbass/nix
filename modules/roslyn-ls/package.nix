{
  lib,
  fetchFromGitHub,
  buildDotnetModule,
  dotnetCorePackages,
  stdenvNoCC,
  testers,
  roslyn-ls,
  jq,
}:
let
  pname = "roslyn-ls";
  dotnet-sdk =
    with dotnetCorePackages;
    sdk_9_0_1xx
    // {
      inherit
        (combinePackages [
          sdk_9_0_1xx
          sdk_8_0
        ])
        packages
        targetPackages
        ;
    };
  # need sdk on runtime as well
  dotnet-runtime = dotnetCorePackages.sdk_9_0;
  rid = dotnetCorePackages.systemToDotnetRid stdenvNoCC.targetPlatform.system;

  project = "Microsoft.CodeAnalysis.LanguageServer";
in
buildDotnetModule rec {
  inherit pname dotnet-sdk dotnet-runtime;

  # Pinned to the last version using .NET SDK 9 as 10 gives a segmentation fault while building
  vsVersion = "2.84.19";
  src = fetchFromGitHub {
    owner = "dotnet";
    repo = "roslyn";

    rev = "76e5e267c0a9f4435a942fbd3e4cef4272f40843";
    hash = "sha256-YGJh0vQu4IH3VWaTU3TKNkvRFfiLxz4tJUows2C48wY=";
  };

  # versioned independently from vscode-csharp
  # "roslyn" in here:
  # https://github.com/dotnet/vscode-csharp/blob/main/package.json
  # version = "5.0.0-1.25204.1";
  version = "5.0.0-2.25458.10";
  projectFile = "src/LanguageServer/${project}/${project}.csproj";
  useDotnetFromEnv = true;
  nugetDeps = ./deps.json;

  nativeBuildInputs = [ jq ];

  patches = [];

  postPatch = ''
    # Upstream uses rollForward = latestPatch, which pins to an *exact* .NET SDK version.
    jq '.sdk.rollForward = "latestMinor"' < global.json > global.json.tmp
    mv global.json.tmp global.json
  '';

  dotnetFlags = [
    "-p:TargetRid=${rid}"
    # this removes the Microsoft.WindowsDesktop.App.Ref dependency
    "-p:EnableWindowsTargeting=false"
  ];

  # two problems solved here:
  # 1. --no-build removed -> BuildHost project within roslyn is running Build target during publish
  # 2. missing crossgen2 7.* in local nuget directory when PublishReadyToRun=true
  # the latter should be fixable here but unsure how
  installPhase = ''
    runHook preInstall

    env dotnet publish $dotnetProjectFiles \
        -p:ContinuousIntegrationBuild=true \
        -p:Deterministic=true \
        -p:InformationalVersion=$version \
        -p:UseAppHost=true \
        -p:PublishTrimmed=false \
        -p:PublishReadyToRun=false \
        --configuration Release \
        --no-self-contained \
        --output "$out/lib/$pname" \
        --no-restore \
        --runtime ${rid} \
        ''${dotnetInstallFlags[@]}  \
        ''${dotnetFlags[@]}

    runHook postInstall
  '';

  passthru = {
    tests.version = testers.testVersion { package = roslyn-ls; };
    updateScript = ./update.sh;
  };

  meta = {
    homepage = "https://github.com/dotnet/vscode-csharp";
    description = "Language server behind C# Dev Kit for Visual Studio Code";
    changelog = "https://github.com/dotnet/vscode-csharp/releases/tag/v${vsVersion}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ konradmalik ];
    mainProgram = "Microsoft.CodeAnalysis.LanguageServer";
  };
}
