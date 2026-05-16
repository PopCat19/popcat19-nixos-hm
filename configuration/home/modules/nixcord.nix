# nixcord.nix
#
# Purpose: Configure Vesktop via nixcord with typed Vencord plugin settings
#
# This module:
# - Manages Vesktop Discord client with system Vencord
# - Configures all Vencord plugins with typed settings
_: {
  programs.nixcord = {
    enable = true;
    vesktop.enable = true;
    vesktop.useSystemVencord = true;

    vesktop.settings = {
      appBadge = false;
      arRPC = true;
      autoUpdate = true;
      autoUpdateNotification = true;
      checkUpdates = false;
      customTitleBar = false;
      disableMinSize = true;
      discordBranch = "stable";
      enableReactDevtools = false;
      frameless = false;
      hardwareAcceleration = true;
      minimizeToTray = false;
      notifyAboutUpdates = true;
      staticTitle = true;
      tray = false;
      transparent = false;
      useQuickCss = true;
      winCtrlQ = false;
      winNativeTitleBar = false;

      splashBackground = "#000000";
      splashColor = "#ffffff";
      splashTheming = true;
    };

    config = {
      useQuickCss = true;
      autoUpdate = true;
      autoUpdateNotification = true;
      notifyAboutUpdates = true;

      plugins = {
        BlurNSFW = {
          enable = true;
          blurAmount = 10;
        };
        biggerStreamPreview.enable = true;
        colorSighted.enable = true;
        crashHandler.enable = true;
        disableDeepLinks.enable = true;
        experiments = {
          enable = true;
          toolbarDevMenu = false;
        };
        fakeNitro = {
          enable = true;
          emojiSize = 64;
          stickerSize = 256;
          enableEmojiBypass = true;
          enableStickerBypass = true;
          enableStreamQualityBypass = true;
          transformEmojis = true;
          transformStickers = true;
          hyperLinkText = "{{NAME}}";
          disableEmbedPermissionCheck = false;
          transformCompoundSentence = false;
        };
        fixYoutubeEmbeds.enable = true;
        forceOwnerCrown.enable = true;
        gifPaste.enable = true;
        greetStickerPicker.enable = true;
        imageZoom = {
          enable = true;
          invertScroll = true;
          size = 750.0;
          zoom = 2.2;
          zoomSpeed = 0.5;
          square = false;
          nearestNeighbour = false;
          saveZoomValues = true;
        };
        memberCount = {
          enable = true;
          memberList = true;
          toolTip = true;
          voiceActivity = true;
        };
        messageClickActions = {
          enable = true;
          enableDeleteOnClick = true;
          enableDoubleClickToEdit = true;
          enableDoubleClickToReply = true;
          requireModifier = false;
        };
        customCommands = {
          enable = true;
          tagsList = { };
        };
        newGuildSettings = {
          enable = true;
          everyone = true;
          events = true;
          guild = true;
          highlights = true;
          messages = 3;
          role = true;
          showAllChannels = true;
        };
        noProfileThemes.enable = true;
        noReplyMention = {
          enable = true;
          inverseShiftReply = false;
          shouldPingListed = true;
          userList = "";
        };
        noTypingAnimation.enable = true;
        pictureInPicture.enable = true;
        PinDMs = {
          enable = true;
          canCollapseDmSection = false;
          dmSectionCollapsed = false;
          pinOrder = 0;
          userBasedCategoryList = { };
        };
        readAllNotificationsButton.enable = true;
        reverseImageSearch.enable = true;
        revealAllSpoilers.enable = true;
        ReviewDB = {
          enable = true;
          hideBlockedUsers = true;
          notifyReviews = true;
          showWarning = true;
        };
        silentTyping = {
          enable = true;
          contextMenu = true;
          isEnabled = true;
          showIcon = false;
        };
        spotifyControls = {
          enable = true;
          hoverControls = false;
        };
        spotifyCrack = {
          enable = true;
          keepSpotifyActivityOnIdle = false;
          noSpotifyAutoPause = true;
        };
        typingIndicator = {
          enable = true;
          includeCurrentChannel = true;
          indicatorMode = 3;
          includeBlockedUsers = false;
          includeMutedChannels = false;
        };
        typingTweaks = {
          enable = true;
          alternativeFormatting = true;
          showAvatars = true;
          showRoleColors = true;
        };
        USRBG = {
          enable = true;
          nitroFirst = true;
          voiceBackground = true;
        };
        userMessagesPronouns = {
          enable = true;
          pronounsFormat = "LOWERCASE";
          showSelf = true;
        };
        validUser.enable = true;
        voiceMessages = {
          enable = true;
          echoCancellation = false;
          noiseSuppression = false;
        };
        webContextMenus = {
          enable = true;
          addBack = false;
        };
        webKeybinds.enable = true;
        whoReacted.enable = true;
        petpet.enable = true;
        youtubeAdblock.enable = true;
      };
    };

    extraConfig = {
      notifications = {
        logLimit = 50;
        position = "top-right";
        timeout = 5000;
        useNative = "not-focused";
      };
      plugins = {
      "AI Noise Suppression".enable = true;
      BadgeAPI.enable = true;
      BetterNotesBox = {
        enable = true;
        hide = false;
        noSpellCheck = false;
      };
      ChatInputButtonAPI.enable = true;
      CommandsAPI.enable = true;
      ContextMenuAPI.enable = true;
      MessageAccessoriesAPI.enable = true;
      MessageEventsAPI.enable = true;
      Experiments = {
        enable = true;
        enableIsStaff = false;
        forceStagingBanner = false;
      };
      FakeNitro.useHyperLinks = true;
      MoreCommands.enable = true;
      NoTrack = {
        enable = true;
        disableAnalytics = true;
      };
      NoticesAPI.enable = true;
      ServerListAPI.enable = true;
      Settings = {
        enable = true;
        settingsLocation = "aboveActivity";
      };
      SupportHelper.enable = true;
      UserSettingsAPI.enable = true;
    };
  };
};
}
