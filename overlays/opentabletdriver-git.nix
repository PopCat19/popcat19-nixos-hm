# opentabletdriver-git.nix
#
# Purpose: Build OpenTabletDriver from git latest
#
# This module:
# - Uses flake input for source (auto-updates with flake update)
# - Uses date-based version string
# - Builds with dotnet SDK 8.0
{
  lib,
  buildDotnetModule,
  copyDesktopItems,
  coreutils,
  dotnetCorePackages,
  gtk3,
  jq,
  libappindicator,
  libevdev,
  libnotify,
  libx11,
  libxrandr,
  makeDesktopItem,
  nixosTests,
  udev,
  wrapGAppsHook3,
  udevCheckHook,
  src,
}:

buildDotnetModule (finalAttrs: {
  pname = "OpenTabletDriver";
  version = "0.6.6.3-unstable-${lib.substring 0 10 (src.lastModifiedDate or "1970-01-01")}";

  inherit src;

  dotnet-sdk = dotnetCorePackages.sdk_8_0;

  projectFile = [
    "OpenTabletDriver.Console"
    "OpenTabletDriver.Daemon"
    "OpenTabletDriver.UX.Gtk"
  ];

  nugetDeps = ./opentabletdriver-deps.json;

  executables = [
    "OpenTabletDriver.Console"
    "OpenTabletDriver.Daemon"
    "OpenTabletDriver.UX.Gtk"
  ];

  nativeBuildInputs = [
    copyDesktopItems
    wrapGAppsHook3
    udevCheckHook
    jq
  ];

  runtimeDeps = [
    gtk3
    libappindicator
    libevdev
    libnotify
    libx11
    libxrandr
    udev
  ];

  buildInputs = finalAttrs.runtimeDeps;

  OTD_CONFIGURATIONS = "${finalAttrs.src}/OpenTabletDriver.Configurations/Configurations";

  doCheck = true;
  testProjectFile = "OpenTabletDriver.Tests/OpenTabletDriver.Tests.csproj";

  disabledTests = [
    "OpenTabletDriver.Tests.UpdaterTests.CheckForUpdates_Returns_Update_When_Available"
    "OpenTabletDriver.Tests.UpdaterTests.Install_Throws_UpdateAlreadyInstalledException_When_AlreadyInstalled"
    "OpenTabletDriver.Tests.UpdaterTests.Install_DoesNotThrow_UpdateAlreadyInstalledException_When_PreviousInstallFailed"
    "OpenTabletDriver.Tests.UpdaterTests.Install_Throws_UpdateInProgressException_When_AnotherUpdate_Is_InProgress"
    "OpenTabletDriver.Tests.UpdaterTests.Install_Moves_UpdatedBinaries_To_BinDirectory"
    "OpenTabletDriver.Tests.UpdaterTests.Install_Moves_Only_ToBeUpdated_Binaries"
    "OpenTabletDriver.Tests.UpdaterTests.Install_Copies_AppDataFiles"
    "OpenTabletDriver.Tests.TimerTests.TimerAccuracy"
  ];

  preBuild = ''
    patchShebangs generate-rules.sh
    substituteInPlace generate-rules.sh \
      --replace-fail '/usr/bin/env rm' '${lib.getExe' coreutils "rm"}'
  '';

  postFixup = ''
    mv $out/bin/OpenTabletDriver.Console $out/bin/otd
    mv $out/bin/OpenTabletDriver.Daemon $out/bin/otd-daemon
    mv $out/bin/OpenTabletDriver.UX.Gtk $out/bin/otd-gui

    install -Dm644 $src/OpenTabletDriver.UX/Assets/otd.png -t $out/share/pixmaps

    mkdir -p $out/lib/udev/rules.d
    ./generate-rules.sh > $out/lib/udev/rules.d/70-opentabletdriver.rules
  '';

  desktopItems = [
    (makeDesktopItem {
      desktopName = "OpenTabletDriver";
      name = "OpenTabletDriver";
      exec = "otd-gui";
      icon = "otd";
      comment = "Open source, cross-platform, user-mode tablet driver";
      categories = [ "Utility" ];
    })
  ];

  passthru = {
    tests = {
      otd-runs = nixosTests.opentabletdriver;
    };
  };

  meta = {
    description = "Open source, cross-platform, user-mode tablet driver (git latest)";
    homepage = "https://github.com/OpenTabletDriver/OpenTabletDriver";
    license = lib.licenses.lgpl3Plus;
    mainProgram = "otd";
    maintainers = [ ];
    platforms = [
      "x86_64-linux"
      "aarch64-linux"
    ];
  };
})
