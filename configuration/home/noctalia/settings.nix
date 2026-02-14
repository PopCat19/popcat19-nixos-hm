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
      marginVertical = 0.25;
      marginHorizontal = 0.25;
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
            enableColorization = false;
            useDistroLogo = true;
          }
          {
            id = "Workspace";
            hideUnoccupied = false;
            labelMode = "name";
            characterCount = 2;
            followFocusedScreen = false;
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
            usePrimaryColor = false;
          }
          {
            id = "MediaMini";
            hideMode = "hidden";
            hideWhenIdle = false;
            maxWidth = 256;
            scrollingMode = "hover";
            showAlbumArt = false;
            showArtistFirst = true;
            showProgressRing = true;
            showVisualizer = false;
            useFixedWidth = false;
            visualizerType = "linear";
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
                displayMode = "alwaysShow";
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
          }
          {
            id = "WiFi";
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
            usePrimaryColor = false;
          }
          {
            id = "NotificationHistory";
            hideWhenZero = true;
            showUnreadBadge = true;
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
      lockOnSuspend = false;
      showSessionButtonsOnLockScreen = true;
      showHibernateOnLockScreen = false;
      enableShadows = false;
      shadowDirection = "bottom_right";
      shadowOffsetX = 2;
      shadowOffsetY = 3;
      language = "";
      allowPanelsOnScreenWithoutBar = true;
    };

    ui = {
      fontDefaultScale = 1;
      fontFixedScale = 1;
      tooltipsEnabled = true;
      panelsAttachedToBar = true;
      settingsPanelAttachToBar = false;
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
          enabled = true;
          id = "timer-card";
        }
        {
          enabled = false;
          id = "weather-card";
        }
      ];
    };

    screenRecorder = {
      directory = "";
      frameRate = 60;
      audioCodec = "opus";
      videoCodec = "hevc";
      quality = "very_high";
      colorRange = "full";
      showCursor = true;
      audioSource = "default_output";
      videoSource = "portal";
    };

    wallpaper = {
      enabled = true;
      overviewEnabled = false;
      directory = "${config.home.homeDirectory}/wallpaper";
      monitorDirectories = [ ];
      enableMultiMonitorDirectories = false;
      recursiveSearch = false;
      setWallpaperOnAllMonitors = true;
      fillMode = "crop";
      fillColor = "#000000";
      randomEnabled = false;
      randomIntervalSec = 300;
      transitionDuration = 1500;
      transitionType = "fade";
      transitionEdgeSmoothness = 0.05;
      panelPosition = "follow_bar";
      hideWallpaperFilenames = false;
      useWallhaven = false;
      wallhavenQuery = "";
      wallhavenSorting = "relevance";
      wallhavenOrder = "desc";
      wallhavenCategories = "111";
      wallhavenPurity = "100";
      wallhavenResolutionMode = "atleast";
      wallhavenResolutionWidth = "";
      wallhavenResolutionHeight = "";
    };

    appLauncher = {
      enableClipboardHistory = true;
      enableClipPreview = true;
      position = "center";
      pinnedExecs = [ ];
      useApp2Unit = false;
      sortByMostUsed = true;
      terminalCommand = "xterm -e";
      customLaunchPrefixEnabled = true;
      customLaunchPrefix = "uwsm app --";
      viewMode = "list";
      showCategories = true;
    };

    controlCenter = {
      position = "close_to_bar_button";
      shortcuts = {
        left = [
          {
            id = "WiFi";
          }
          {
            id = "Bluetooth";
          }
          {
            id = "ScreenRecorder";
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
      memWarningThreshold = 80;
      memCriticalThreshold = 90;
      diskWarningThreshold = 80;
      diskCriticalThreshold = 90;
      cpuPollingInterval = 3000;
      tempPollingInterval = 3000;
      memPollingInterval = 1750;
      diskPollingInterval = 3000;
      networkPollingInterval = 3000;
      useCustomColors = false;
    };
    dock = {
      enabled = false;
      displayMode = "auto_hide";
      floatingRatio = 1;
      size = 1;
      onlySameOutput = true;
      monitors = [ ];
      pinnedApps = [ ];
      colorizeIcons = false;
      pinnedStatic = false;
      inactiveIndicators = false;
      animationSpeed = 1;
    };
    network = {
      wifiEnabled = true;
    };

    sessionMenu = {
      enableCountdown = true;
      countdownDuration = 10000;
      position = "center";
      showHeader = true;
      powerOptions = [
        {
          action = "lock";
          enabled = true;
          command = "";
          countdownEnabled = true;
        }
        {
          action = "suspend";
          enabled = true;
          command = "";
          countdownEnabled = true;
        }
        {
          action = "reboot";
          enabled = true;
          command = "";
          countdownEnabled = true;
        }
        {
          action = "logout";
          enabled = true;
          command = "";
          countdownEnabled = true;
        }
        {
          action = "shutdown";
          enabled = true;
          command = "";
          countdownEnabled = true;
        }
      ];
    };

    notifications = {
      enabled = true;
      monitors = [ ];
      location = "top_right";
      overlayLayer = true;
      respectExpireTimeout = false;
      lowUrgencyDuration = 3;
      normalUrgencyDuration = 8;
      criticalUrgencyDuration = 15;
      enableKeyboardLayoutToast = true;
      sounds = {
        enabled = false;
        volume = 0.5;
        separateSounds = false;
        criticalSoundFile = "";
        normalSoundFile = "";
        lowSoundFile = "";
        excludedApps = "discord,firefox,chrome,chromium,edge";
      };
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
      cavaFrameRate = 30;
      visualizerType = "linear";
      visualizerQuality = "high";
      mprisBlacklist = [ ];
      preferredPlayer = "";
      externalMixer = "pwvucontrol || pavucontrol";
    };

    brightness = {
      brightnessStep = 10;
      enforceMinimum = true;
      enableDdcSupport = false;
    };

    colorSchemes = {
      useWallpaperColors = false;
      darkMode = true;
      schedulingMode = "off";
      manualSunrise = "06:30";
      manualSunset = "18:30";
      generateTemplatesForPredefined = true;
    };

    templates = {
      gtk = false;
      qt = false;
      kcolorscheme = false;
      alacritty = false;
      kitty = false;
      ghostty = false;
      foot = false;
      wezterm = false;
      fuzzel = false;
      discord = false;
      pywalfox = false;
      vicinae = false;
      walker = false;
      code = false;
      spicetify = false;
      telegram = false;
      cava = false;
      emacs = false;
      niri = false;
      enableUserTemplates = false;
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
    };
  };
in
{
  inherit settings;
}
