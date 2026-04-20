# settings.nix
#
# Purpose: Provides complete Noctalia settings as Nix attribute set
#
# This module:
# - Exports settings attribute set for Noctalia shell configuration
# - Conditionally enables battery widget for laptop hosts
{
  pkgs,
  config,
  hostname ? null,
  enableUWSM ? true,
  ...
}:
let
  hasBattery =
    if hostname != null then
      hostname == "popcat19-surface0" || hostname == "popcat19-thinkpad0"
    else
      false;

  settings = {
    bar = {
      position = "top";
      monitors = [ ];
      density = "default";
      showCapsule = false;
      floating = true;
      marginVertical = 5;
      marginHorizontal = 5;
      outerCorners = true;
      exclusive = true;

      widgets = {
        left = [
          {
            id = "ControlCenter";
            icon = "noctalia";
            colorizeDistroLogo = false;
            colorizeSystemIcon = "none";
            customIconPath = "";
            enableColorization = true;
            useDistroLogo = true;
          }
          {
            id = "Workspace";
            hideUnoccupied = false;
            labelMode = "name";
            characterCount = 2;
            followFocusedScreen = false;
            colorizeIcons = false;
            iconScale = 0.8;
            pillSize = 0.6;
            showBadge = true;
            showLabelsOnlyWhenOccupied = true;
          }
          {
            id = "SystemMonitor";
            diskPath = "/";
            showCpuUsage = true;
            showCpuTemp = true;
            showMemoryAsPercent = false;
            showMemoryUsage = true;
            showNetworkStats = false;
            showDiskUsage = true;
            showDiskAvailable = true;
            showDiskUsageAsPercent = false;
            showSwapUsage = true;
            useMonospaceFont = true;
            compactMode = false;
          }
          {
            id = "MediaMini";
            hideMode = "hidden";
            hideWhenIdle = false;
            maxWidth = 256;
            scrollingMode = "hover";
            showAlbumArt = true;
            showArtistFirst = true;
            showProgressRing = true;
            showVisualizer = false;
            useFixedWidth = false;
            visualizerType = "linear";
            compactMode = true;
            compactShowAlbumArt = true;
            panelShowAlbumArt = true;
            panelShowVisualizer = true;
          }
        ];

        center = [ ];

        right = [
          {
            id = "Tray";
            blacklist = [ ];
            colorizeIcons = false;
            drawerEnabled = true;
            hidePassive = false;
            pinned = [ ];
          }
        ]
        ++ (
          if hasBattery then
            [
              {
                id = "Battery";
                displayMode = "icon-always";
                showNoctaliaPerformance = false;
                showPowerProfiles = false;
                warningThreshold = 20;
              }
            ]
          else
            [ ]
        )
        ++ [
          {
            id = "Volume";
            displayMode = "alwaysShow";
            middleClickCommand = "pwvucontrol || pavucontrol";
          }
          {
            id = "Network";
            displayMode = "onhover";
          }
          {
            id = "Bluetooth";
            displayMode = "onhover";
          }
          {
            id = "Clock";
            formatHorizontal = "HH:mm ddd, MMM dd";
            formatVertical = "HH mm - dd MM";
            useCustomFont = true;
            customFont = "JetBrainsMono Nerd Font";
            tooltipFormat = "HH:mm ddd, MMM dd";
          }
          {
            id = "NotificationHistory";
            hideWhenZero = true;
            showUnreadBadge = true;
            unreadBadgeColor = "primary";
          }
        ];
      };
    };

    general = {
      avatarImage = "${pkgs.writeText "face" ""}/.face";
      dimmerOpacity = 0.4;
      showScreenCorners = false;
      forceBlackScreenCorners = false;
      scaleRatio = 1;
      radiusRatio = 1;
      iRadiusRatio = 1;
      boxRadiusRatio = 1;
      screenRadiusRatio = 1;
      animationSpeed = 1.2;
      animationDisabled = false;
      compactLockScreen = false;
      lockScreenAnimations = false;
      lockOnSuspend = false;
      showSessionButtonsOnLockScreen = true;
      showHibernateOnLockScreen = false;
      enableShadows = false;
      shadowDirection = "bottom_right";
      shadowOffsetX = 2;
      shadowOffsetY = 3;
      language = "";
      allowPanelsOnScreenWithoutBar = true;
      enableLockScreenCountdown = true;
      lockScreenCountdownDuration = 10000;
    };

    ui = {
      fontDefault = "Rounded Mplus 1c Medium";
      fontFixed = "FiraCode Nerd Font";
      fontDefaultScale = 1;
      fontFixedScale = 1;
      tooltipsEnabled = true;
      panelsAttachedToBar = true;
      settingsPanelMode = "centered";
    };

    location = {
      name = "New York";
      weatherEnabled = false;
      weatherShowEffects = true;
      useFahrenheit = false;
      use12hourFormat = false;
      showWeekNumberInCalendar = false;
      showCalendarEvents = true;
      showCalendarWeather = true;
      analogClockInCalendar = false;
      firstDayOfWeek = -1;
      hideWeatherTimezone = false;
      hideWeatherCityName = false;
    };

    calendar = {
      cards = [
        {
          enabled = true;
          id = "calendar-header-card";
        }
        {
          enabled = true;
          id = "calendar-month-card";
        }
        {
          enabled = false;
          id = "weather-card";
        }
      ];
    };

    wallpaper = {
      enabled = true;
      overviewEnabled = false;
      directory = "${config.home.homeDirectory}/Pictures/Wallpapers";
      monitorDirectories = [ ];
      enableMultiMonitorDirectories = false;
      showHiddenFiles = false;
      viewMode = "single";
      setWallpaperOnAllMonitors = true;
      fillMode = "crop";
      fillColor = "#000000";
      useSolidColor = false;
      solidColor = "#1a1a2e";
      automationEnabled = false;
      wallpaperChangeMode = "random";
      randomIntervalSec = 300;
      transitionDuration = 1500;
      transitionType = "fade";
      transitionEdgeSmoothness = 0.05;
      panelPosition = "follow_bar";
      hideWallpaperFilenames = false;
      overviewBlur = 0.4;
      overviewTint = 0.6;
      useWallhaven = false;
      wallhavenQuery = "";
      wallhavenSorting = "relevance";
      wallhavenOrder = "desc";
      wallhavenCategories = "111";
      wallhavenPurity = "100";
      wallhavenRatios = "";
      wallhavenApiKey = "";
      wallhavenResolutionMode = "atleast";
      wallhavenResolutionWidth = "";
      wallhavenResolutionHeight = "";
      sortOrder = "name";
    };

    appLauncher = {
      enableClipboardHistory = true;
      autoPasteClipboard = false;
      enableClipPreview = true;
      clipboardWrapText = true;
      clipboardWatchTextCommand = "wl-paste --type text --watch cliphist store";
      clipboardWatchImageCommand = "wl-paste --type image --watch cliphist store";
      position = "center";
      pinnedApps = [ ];
      useApp2Unit = false;
      sortByMostUsed = true;
      terminalCommand = "xterm -e";
      customLaunchPrefixEnabled = enableUWSM;
      customLaunchPrefix = if enableUWSM then "uwsm app --" else "";
      viewMode = "list";
      showCategories = true;
      iconMode = "tabler";
      showIconBackground = false;
      enableSettingsSearch = true;
      enableWindowsSearch = true;
      ignoreMouseInput = false;
      screenshotAnnotationTool = "";
      overviewLayer = false;
      density = "default";
    };

    controlCenter = {
      position = "close_to_bar_button";
      diskPath = "/";
      shortcuts = {
        left = [
          {
            id = "Network";
          }
          {
            id = "Bluetooth";
          }
          {
            id = "WallpaperSelector";
          }
        ];
        right = [
          {
            id = "Notifications";
          }
          {
            id = "PowerProfile";
          }
          {
            id = "KeepAwake";
          }
          {
            id = "NightLight";
          }
        ];
      };
      cards = [
        {
          enabled = true;
          id = "profile-card";
        }
        {
          enabled = true;
          id = "shortcuts-card";
        }
        {
          enabled = true;
          id = "audio-card";
        }
        {
          enabled = false;
          id = "weather-card";
        }
        {
          enabled = true;
          id = "media-sysmon-card";
        }
      ];
    };

    systemMonitor = {
      cpuWarningThreshold = 80;
      cpuCriticalThreshold = 90;
      tempWarningThreshold = 80;
      tempCriticalThreshold = 90;
      gpuWarningThreshold = 80;
      gpuCriticalThreshold = 90;
      memWarningThreshold = 80;
      memCriticalThreshold = 90;
      swapWarningThreshold = 80;
      swapCriticalThreshold = 90;
      diskWarningThreshold = 80;
      diskCriticalThreshold = 90;
      diskAvailWarningThreshold = 20;
      diskAvailCriticalThreshold = 5;
      batteryWarningThreshold = 20;
      batteryCriticalThreshold = 5;
      cpuPollingInterval = 1000;
      gpuPollingInterval = 3000;
      enableDgpuMonitoring = false;
      memPollingInterval = 1000;
      diskPollingInterval = 3000;
      networkPollingInterval = 1000;
      loadAvgPollingInterval = 3000;
      useCustomColors = false;
      warningColor = "";
      criticalColor = "";
      externalMonitor = "resources || missioncenter || jdsystemmonitor || corestats || system-monitoring-center || gnome-system-monitor || plasma-systemmonitor || mate-system-monitor || ukui-system-monitor || deepin-system-monitor || pantheon-system-monitor";
    };
    dock = {
      enabled = false;
      position = "bottom";
      displayMode = "auto_hide";
      floatingRatio = 1;
      size = 1;
      onlySameOutput = true;
      monitors = [ ];
      pinnedApps = [ ];
      colorizeIcons = false;
      pinnedStatic = false;
      inactiveIndicators = false;
      deadOpacity = 0.6;
      animationSpeed = 1;
    };
    network = {
      wifiEnabled = true;
      bluetoothRssiPollingEnabled = false;
      bluetoothRssiPollIntervalMs = 10000;
      wifiDetailsViewMode = "grid";
      bluetoothDetailsViewMode = "grid";
      bluetoothHideUnnamedDevices = false;
    };

    sessionMenu = {
      enableCountdown = true;
      countdownDuration = 10000;
      position = "center";
      showHeader = true;
      largeButtonsStyle = true;
      largeButtonsLayout = "single-row";
      showNumberLabels = true;
      powerOptions = [
        {
          action = "lock";
          enabled = true;
          command = "";
          countdownEnabled = true;
          keybind = "";
        }
        {
          action = "suspend";
          enabled = true;
          command = "";
          countdownEnabled = true;
          keybind = "";
        }
        {
          action = "reboot";
          enabled = true;
          command = "";
          countdownEnabled = true;
          keybind = "";
        }
        {
          action = "logout";
          enabled = true;
          command = "";
          countdownEnabled = true;
          keybind = "";
        }
        {
          action = "shutdown";
          enabled = true;
          command = "";
          countdownEnabled = true;
          keybind = "";
        }
        {
          action = "hibernate";
          enabled = true;
          command = "";
          countdownEnabled = true;
          keybind = "";
        }
      ];
    };

    notifications = {
      enabled = true;
      monitors = [ ];
      location = "top";
      overlayLayer = true;
      respectExpireTimeout = false;
      lowUrgencyDuration = 3;
      normalUrgencyDuration = 8;
      criticalUrgencyDuration = 15;
      saveToHistory = {
        low = true;
        normal = true;
        critical = true;
      };
      sounds = {
        enabled = false;
        volume = 0.5;
        separateSounds = false;
        criticalSoundFile = "";
        normalSoundFile = "";
        lowSoundFile = "";
        excludedApps = "discord,firefox,chrome,chromium,edge";
      };
      enableMediaToast = false;
      enableKeyboardLayoutToast = true;
      enableBatteryToast = true;
    };

    osd = {
      enabled = true;
      location = "top";
      autoHideMs = 2000;
      overlayLayer = true;
      enabledTypes = [
        0
        1
        2
      ];
      monitors = [ ];
    };

    audio = {
      volumeStep = 4;
      volumeOverdrive = true;
      cavaFrameRate = 120;
      visualizerType = "none";
      mprisBlacklist = [ ];
      preferredPlayer = "";
      volumeFeedback = false;
    };

    brightness = {
      brightnessStep = 10;
      enforceMinimum = true;
      enableDdcSupport = false;
    };

    colorSchemes = {
      useWallpaperColors = false;
      predefinedScheme = "Noctalia (default)";
      darkMode = true;
      schedulingMode = "off";
      manualSunrise = "06:30";
      manualSunset = "18:30";
      generationMethod = "tonal-spot";
      monitorForColors = "";
    };

    templates = {
      activeTemplates = [ ];
      enableUserTheming = false;
    };

    nightLight = {
      enabled = false;
      forced = false;
      autoSchedule = false;
      nightTemp = "4000";
      dayTemp = "6500";
      manualSunrise = "06:30";
      manualSunset = "18:30";
    };

    hooks = {
      enabled = false;
      wallpaperChange = "";
      darkModeChange = "";
      screenLock = "";
      screenUnlock = "";
      performanceModeEnabled = "";
      performanceModeDisabled = "";
      startup = "";
      session = "";
    };

    plugins = {
      autoUpdate = false;
    };

    desktopWidgets = {
      enabled = false;
      gridSnap = false;
      monitorWidgets = [ ];
    };
  };
in
{
  inherit settings;
}
