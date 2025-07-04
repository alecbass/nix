{
  lib,
  stdenv,
  fetchurl,
  nixosTests,
  copyDesktopItems,
  makeDesktopItem,
  makeWrapper,
  wrapGAppsHook3,
  gobject-introspection,
  jre, # old or modded versions of the game may require Java 8 (https://aur.archlinux.org/packages/minecraft-launcher/#pinned-674960)
  xorg,
  zlib,
  nss,
  nspr,
  fontconfig,
  pango,
  cairo,
  expat,
  alsa-lib,
  cups,
  dbus,
  atk,
  gtk3-x11,
  gtk2-x11,
  gdk-pixbuf,
  glib,
  curl,
  freetype,
  libpulseaudio,
  libuuid,
  systemd,
  flite ? null,
  libXxf86vm ? null,
  libGL,
  libdrm,
  libgbm,
}:
let
  desktopItem = makeDesktopItem {
    name = "minecraft-launcher";
    exec = "minecraft-launcher";
    icon = "minecraft-launcher";
    comment = "Official launcher for Minecraft, a sandbox-building game";
    desktopName = "Minecraft Launcher";
    categories = [ "Game" ];
  };

  envLibPath = lib.makeLibraryPath (
    [
      curl
      libpulseaudio
      systemd
      alsa-lib # needed for narrator
      flite # needed for narrator
      libXxf86vm # needed only for versions <1.13

      # Copied from libPath, required at runtime
      cups
      gdk-pixbuf
      glib
      gtk3-x11
      nspr
      nss
      libGL
      libdrm
      libgbm
      libuuid
    ] ++ (with xorg; [
        libX11
    ])
  );

  libPath = lib.makeLibraryPath (
    [
      alsa-lib
      atk
      cairo
      cups
      dbus
      expat
      fontconfig
      freetype
      gdk-pixbuf
      glib
      pango
      gtk3-x11
      gtk2-x11
      nspr
      nss
      stdenv.cc.cc
      zlib
      libuuid
    ]
    ++ (with xorg; [
      libX11
      libxcb
      libXcomposite
      libXcursor
      libXdamage
      libXext
      libXfixes
      libXi
      libXrandr
      libXrender
      libXtst
      libXScrnSaver
    ])
  );
in
stdenv.mkDerivation rec {
  name = "minecraft-launcher";
  pname = "minecraft-launcher";

  src = fetchurl {
    # Current download, it appears new legacy launcher versions are no longer available
    url = "https://launcher.mojang.com/download/Minecraft.tar.gz";
    sha256 = "sha256-aVJpKBVHu7z0f+dGMwJ6Dk3cE6YQYMaGpyF+hdMU5F4=";
  };

  icon = fetchurl {
    url = "https://launcher.mojang.com/download/minecraft-launcher.svg";
    sha256 = "0w8z21ml79kblv20wh5lz037g130pxkgs8ll9s3bi94zn2pbrhim";
  };

  nativeBuildInputs = [
    makeWrapper
    wrapGAppsHook3
    copyDesktopItems
    gobject-introspection
  ];

  sourceRoot = ".";

  dontWrapGApps = true;
  dontConfigure = true;
  dontBuild = true;

  installPhase = ''
    runHook preInstall

    mkdir -p $out/opt
    mv minecraft-launcher $out/opt

    install -D $icon $out/share/icons/hicolor/symbolic/apps/minecraft-launcher.svg

    runHook postInstall
  '';

  preFixup = ''
    patchelf \
      --set-interpreter ${stdenv.cc.bintools.dynamicLinker} \
      --set-rpath '$ORIGIN/'":${libPath}" \
      $out/opt/minecraft-launcher/minecraft-launcher
  '';

  postFixup = ''
    # Do not create `GPUCache` in current directory
    makeWrapper $out/opt/minecraft-launcher/minecraft-launcher $out/bin/minecraft-launcher \
      --prefix LD_LIBRARY_PATH : ${envLibPath} \
      --prefix PATH : ${lib.makeBinPath [ jre ]} \
      --set JAVA_HOME ${lib.getBin jre} \
      --chdir /tmp \
      "''${gappsWrapperArgs[@]}"
  '';

  desktopItems = [ desktopItem ];

  meta = with lib; {
    description = "Official launcher for Minecraft, a sandbox-building game";
    homepage = "https://minecraft.net";
    maintainers = with maintainers; [ ryantm alecbass ];
    sourceProvenance = with sourceTypes; [ binaryNativeCode ];
    license = licenses.unfree;
    platforms = [ "x86_64-linux" ];
  };

  passthru = {
    tests = { inherit (nixosTests) minecraft; };
    updateScript = ./update.sh;
  };
}
