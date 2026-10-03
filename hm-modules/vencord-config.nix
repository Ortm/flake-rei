# Vencord plugins and settings for Discord (nixcord).
#
# Captured from the running client on 2026-10-03 so the plugin toggles stop
# resetting on every `home-manager switch`: nixcord writes
# ~/.config/Vencord/settings/settings.json from this file at activation.
#
# Edit by hand. Plugin names here are nixcord's camelCase option names;
# `enable = true` is what the client shows as a switched-on plugin.
#
# Vencord's internal *_API plugins (and a few removed ones) have no nixcord
# option and are not listed; the client keeps its own defaults for those.
{
  # Added in the client but not enabled there.
  themeLinks = [ "https://catppuccin.github.io/discord/dist/catppuccin-mocha.theme.css" ];
  useQuickCss = true;

  plugins = {
    accountPanelServerProfile = {
      enable = false;
      prioritizeServerProfile = false;
    };
    addAttachments.enable = true;
    alwaysAnimate.enable = false;
    alwaysExpandRoles.enable = true;
    alwaysTrust = {
      enable = true;
      domain = true;
      file = true;
    };
    anonymiseFileNames = {
      enable = false;
      anonymiseByDefault = true;
      consistent = "image";
      method = 0;
      randomisedLength = 7;
    };
    autoDndWhilePlaying = {
      enable = false;
      statusToSet = "dnd";
    };
    betterFolders = {
      enable = true;
      closeAllFolders = false;
      closeAllHomeButton = false;
      closeOthers = false;
      closeServerFolder = false;
      forceOpen = false;
      keepIcons = false;
      showFolderIcon = 1;
      sidebar = true;
      sidebarAnim = true;
    };
    betterGifAltText.enable = false;
    betterGifPicker.enable = true;
    betterRoleContext = {
      enable = true;
      roleIconFileFormat = "png";
    };
    betterRoleDot = {
      enable = false;
      bothStyles = false;
      copyRoleColorInProfilePopout = false;
    };
    betterSessions = {
      enable = false;
      backgroundCheck = false;
      checkInterval = 20;
    };
    betterSettings = {
      enable = false;
      disableFade = true;
      eagerLoad = true;
      organizeMenu = true;
    };
    betterUploadButton.enable = false;
    biggerStreamPreview.enable = true;
    blurNsfw = {
      enable = false;
      blurAmount = 10;
    };
    callTimer = {
      enable = true;
      format = "stopwatch";
    };
    characterCounter = {
      enable = true;
      colorEffects = true;
    };
    clearUrls.enable = false;
    clientTheme = {
      enable = false;
      color = "313338";
    };
    colorSighted.enable = false;
    concatenatedComponentExtractor.enable = false;
    consoleJanitor = {
      enable = false;
      allowLevel = {
        debug = false;
        error = true;
        info = false;
        log = false;
        trace = false;
        warn = false;
      };
      disableLoggers = false;
      disableSpotifyLogger = true;
      whitelistedLoggers = "GatewaySocket; Routing/Utils";
    };
    consoleShortcuts.enable = false;
    copyEmojiMarkdown = {
      enable = false;
      copyUnicode = true;
    };
    copyFileContents.enable = true;
    copyStickerLinks.enable = false;
    copyUserUrls.enable = false;
    crashHandler = {
      enable = false;
      attemptToNavigateToHome = false;
      attemptToPreventCrashes = true;
    };
    customCommands = {
      enable = false;
      tagsList = { };
    };
    customIdle = {
      enable = true;
      idleTimeout = 10.0;
      remainInIdle = true;
    };
    customRpc = {
      enable = false;
      appId = null;
      appName = null;
      buttonOneText = null;
      buttonOneUrl = null;
      buttonTwoText = null;
      buttonTwoUrl = null;
      details = null;
      detailsUrl = null;
      endTime = 0;
      imageBig = null;
      imageBigTooltip = null;
      imageBigUrl = null;
      imageSmall = null;
      imageSmallTooltip = null;
      imageSmallUrl = null;
      partyMaxSize = 0;
      partySize = 0;
      startTime = 0;
      state = null;
      stateUrl = null;
      streamLink = null;
      timestampMode = 0;
      type = 0;
    };
    dearrow = {
      enable = false;
      dearrowByDefault = true;
      hideButton = false;
      replaceElements = 0;
    };
    decor = {
      enable = false;
      agreedToGuidelines = false;
    };
    devCompanion = {
      enable = false;
      notifyOnAutoConnect = true;
    };
    disableCallIdle.enable = true;
    disableDeepLinks.enable = false;
    dontRoundMyTimestamps.enable = false;
    experiments.enable = false;
    expressionCloner.enable = false;
    f8Break.enable = false;
    fakeNitro = {
      enable = true;
      disableEmbedPermissionCheck = false;
      emojiSize = 48;
      enableEmojiBypass = true;
      enableStickerBypass = true;
      enableStreamQualityBypass = true;
      hyperLinkText = "{{NAME}}";
      stickerSize = 160;
      transformCompoundSentence = false;
      transformEmojis = true;
      transformStickers = true;
      useHyperLinks = true;
    };
    fakeProfileThemes = {
      enable = false;
      nitroFirst = true;
    };
    favoriteEmojiFirst.enable = false;
    fixCodeblockGap.enable = true;
    fixDiscordCss.enable = false;
    fixImagesQuality = {
      enable = true;
      originalImagesInChat = false;
    };
    fixSpotifyEmbeds = {
      enable = false;
      volume = 10.0;
    };
    fixYoutubeEmbeds.enable = true;
    forceOwnerCrown.enable = false;
    friendInvites.enable = false;
    fullSearchContext.enable = true;
    fullUserInChatbox.enable = true;
    gameActivityToggle = {
      enable = true;
      location = "PANEL";
      oldIcon = false;
    };
    gifPaste.enable = false;
    greetStickerPicker = {
      enable = false;
      greetMode = "Greet";
      multiGreetChoices = [ ];
      unholyMultiGreetEnabled = false;
    };
    hideMedia.enable = false;
    iLoveSpam.enable = false;
    ignoreActivities = {
      enable = false;
      idsList = "";
      ignoreCompeting = false;
      ignoreListening = false;
      ignorePlaying = false;
      ignoreStreaming = false;
      ignoreWatching = false;
      ignoredActivities = [ ];
      listMode = 0;
    };
    imageFilename = {
      enable = false;
      showFullUrl = false;
    };
    imageLink.enable = true;
    imageZoom = {
      enable = true;
      invertScroll = true;
      nearestNeighbour = false;
      saveZoomValues = true;
      size = 100.0;
      square = false;
      zoom = 2.0;
      zoomSpeed = 0.5;
    };
    implicitRelationships = {
      enable = false;
      sortByAffinity = true;
    };
    ircColors = {
      enable = true;
      applyColorOnlyInDms = false;
      applyColorOnlyToUsersWithoutColor = false;
      lightness = 70;
      memberListColors = true;
    };
    keepCurrentChannel.enable = false;
    loadingQuotes = {
      enable = true;
      additionalQuotes = "";
      additionalQuotesDelimiter = "|";
      enableDiscordPresetQuotes = false;
      enablePluginPresetQuotes = true;
      replaceEvents = true;
    };
    memberCount = {
      enable = false;
      memberList = true;
      toolTip = true;
      voiceActivity = true;
    };
    mentionAvatars = {
      enable = false;
      showAtSymbol = true;
    };
    messageClickActions = {
      enable = true;
      enableDeleteOnClick = true;
      enableDoubleClickToEdit = true;
      enableDoubleClickToReply = true;
      requireModifier = false;
    };
    messageLatency = {
      enable = true;
      detectDiscordKotlin = true;
      ignoreSelf = false;
      latency = 2;
      showMillis = false;
    };
    messageLinkEmbeds = {
      enable = false;
      automodEmbeds = "never";
      idList = "";
      listMode = "blacklist";
      messageBackgroundColor = false;
    };
    messageLogger = {
      enable = true;
      collapseDeleted = false;
      deleteStyle = "text";
      ignoreBots = true;
      ignoreChannels = "";
      ignoreGuilds = "";
      ignoreSelf = false;
      ignoreUsers = "";
      inlineEdits = true;
      logDeletedAttachments = true;
      logDeletes = true;
      logEdits = true;
    };
    moreQuickReactions = {
      enable = false;
      reactionCount = 5;
    };
    musicRichPresence = {
      enable = false;
      apiKey = null;
      clickableLinks = true;
      hideWithActivity = false;
      hideWithSpotify = true;
      instanceApiBaseUrl = null;
      instanceBaseUrl = null;
      missingArt = "logo";
      nameFormat = "status-name";
      scrobblerBackend = "lastfm";
      shareUsername = false;
      showAlbumCover = true;
      showLogo = true;
      statusDisplayType = "artist";
      statusName = "some music";
      useListeningStatus = false;
      username = null;
    };
    mutualGroupDms.enable = true;
    newGuildSettings = {
      enable = false;
      events = true;
      everyone = true;
      guild = true;
      highlights = true;
      messages = 3;
      role = true;
      showAllChannels = true;
    };
    noBlockedMessages = {
      enable = true;
      applyToIgnoredUsers = true;
      ignoreMessages = false;
    };
    noDevtoolsWarning.enable = false;
    noF1.enable = true;
    noMaskedUrlPaste.enable = false;
    noMiddleClickPaste.enable = false;
    noMosaic = {
      enable = true;
      inlineVideo = true;
    };
    noOnboardingDelay.enable = true;
    noPendingCount = {
      enable = false;
      hideFriendRequestsCount = true;
      hideMessageRequestsCount = true;
      hidePremiumOffersCount = true;
    };
    noProfileThemes.enable = true;
    noReplyMention = {
      enable = true;
      inverseShiftReply = false;
      roleList = "1234567890123445,1234567890123445";
      shouldPingListed = true;
      userList = "1234567890123445,1234567890123445";
    };
    noServerEmojis = {
      enable = true;
      shownEmojis = "onlyUnicode";
    };
    noSystemBadge.enable = true;
    noTrack = {
      enable = false;
      disableAnalytics = true;
    };
    noTypingAnimation.enable = false;
    noUnblockToJump.enable = true;
    notificationVolume = {
      enable = true;
      notificationVolume = 100.0;
    };
    onePingPerDm = {
      enable = true;
      allowEveryone = false;
      allowMentions = false;
      channelToAffect = "both_dms";
    };
    oneko.enable = false;
    openInApp = {
      enable = true;
      epic = true;
      itunes = true;
      spotify = true;
      steam = true;
      tidal = true;
    };
    overrideForumDefaults = {
      enable = false;
      defaultLayout = 1;
      defaultSortOrder = 0;
    };
    pauseInvitesForever.enable = true;
    permissionFreeWill = {
      enable = true;
      lockout = true;
      onboarding = true;
    };
    permissionsViewer = {
      enable = true;
      permissionsSortOrder = 0;
    };
    petpet.enable = false;
    pictureInPicture = {
      enable = false;
      loop = true;
    };
    pinDms = {
      enable = true;
      canCollapseDmSection = false;
      dmSectionCollapsed = false;
      pinOrder = 0;
      userBasedCategoryList = {
        "515437055065456641" = [
          {
            id = "vmje6vy905s";
            name = "besties";
            color = 15277667;
            collapsed = false;
            channels = [
              "1491562316720898108"
              "1174391259289370716"
              "939911145983180851"
            ];
          }
          {
            id = "zft6yu5x8f";
            name = "friends";
            color = 10181046;
            collapsed = false;
            channels = [
              "1456393390953468125"
              "1482171946216063038"
              "1453956784057352196"
              "1496225881419550931"
            ];
          }
        ];
      };
    };
    plainFolderIcon.enable = false;
    platformIndicators = {
      enable = false;
      badges = true;
      colorMobileIndicator = true;
      list = true;
      messages = true;
    };
    previewMessage.enable = true;
    quickMention.enable = true;
    quickReply = {
      enable = true;
      ignoreBlockedAndIgnored = true;
      shouldMention = 2;
    };
    reactErrorDecoder.enable = false;
    readAllNotificationsButton.enable = true;
    relationshipNotifier = {
      enable = true;
      friendRequestCancels = true;
      friends = true;
      groups = true;
      notices = false;
      offlineRemovals = true;
      servers = true;
    };
    replaceGoogleSearch = {
      enable = false;
      customEngineName = null;
      customEngineUrl = null;
      replacementEngine = "off";
    };
    replyTimestamp.enable = false;
    revealAllSpoilers.enable = false;
    reverseImageSearch.enable = false;
    reviewDb = {
      enable = false;
      hideBlockedUsers = true;
      hideTimestamps = false;
      lastReviewId = 0;
      notifyReviews = true;
      reviewsDropdownState = false;
      showWarning = true;
    };
    roleColorEverywhere = {
      enable = false;
      chatMentions = true;
      colorChatMessages = false;
      memberList = true;
      messageSaturation = 30.0;
      pollResults = true;
      reactorsList = true;
      voiceUsers = true;
    };
    secretRingToneEnabler = {
      enable = false;
      onlySnow = false;
    };
    sendTimestamps = {
      enable = true;
      replaceMessageContents = true;
    };
    serverInfo.enable = true;
    serverListIndicators = {
      enable = false;
      mode = 2;
    };
    settings = {
      enable = false;
      includeVencordInfoWhenCopying = true;
      settingsLocation = "aboveNitro";
    };
    shikiCodeblocks = {
      enable = true;
      bgOpacity = 100.0;
      customTheme = null;
      theme = "https://cdn.jsdelivr.net/gh/shikijs/textmate-grammars-themes@bc5436518111d87ea58eb56d97b3f9bec30e6b83/packages/tm-themes/themes/dark-plus.json";
      tryHljs = "SECONDARY";
      useDevIcon = "GREYSCALE";
    };
    showAllMessageButtons.enable = false;
    showConnections = {
      enable = false;
      iconSize = 32;
      iconSpacing = 1;
    };
    showHiddenChannels = {
      enable = true;
      defaultAllowedUsersAndRolesDropdownState = true;
      hideUnreads = true;
      showMode = 0;
    };
    showHiddenThings = {
      enable = true;
      showInvitesPaused = true;
      showModView = true;
      showTimeouts = true;
    };
    showMeYourName = {
      enable = true;
      displayNames = false;
      friendNicknames = "dms";
      inReplies = false;
      mode = "user-nick";
    };
    showTimeoutDuration = {
      enable = false;
      displayStyle = "ssalggnikool";
    };
    silentMessageToggle = {
      enable = true;
      autoDisable = true;
    };
    silentTyping = {
      enable = true;
      contextMenu = true;
      isEnabled = true;
      showIcon = false;
    };
    sortFriendRequests = {
      enable = false;
      showDates = false;
    };
    spotifyControls = {
      enable = false;
      hoverControls = false;
      previousButtonRestartsTrack = true;
      useSpotifyUris = false;
    };
    spotifyCrack = {
      enable = true;
      keepSpotifyActivityOnIdle = false;
      noSpotifyAutoPause = true;
    };
    spotifyShareCommands.enable = false;
    startupTimings.enable = false;
    stickerPaste.enable = false;
    streamerModeOnStream.enable = false;
    superReactionTweaks = {
      enable = false;
      superReactByDefault = true;
      superReactionPlayingLimit = 20.0;
      unlimitedSuperReactionPlaying = false;
    };
    supportHelper = {
      enable = false;
      dismissedDevBuildWarning = false;
    };
    tenorGifSearch.enable = false;
    textReplace = {
      enable = false;
      regexRules = [
        {
          find = "";
          name = "";
          onlyIfIncludes = "";
          replace = "";
          scope = "myMessages";
        }
      ];
      stringRules = [
        {
          find = "";
          name = "";
          onlyIfIncludes = "";
          replace = "";
          scope = "myMessages";
        }
      ];
    };
    themeAttributes.enable = false;
    translate = {
      enable = false;
      autoTranslate = false;
      # deeplApiKey = …; # left out: secret (public repo)
      dismissedAutoTranslateAlert = false;
      kagiSession = "";
      receivedInput = "auto";
      receivedOutput = "en";
      sentInput = "auto";
      sentOutput = "en";
      service = "google";
      showAutoTranslateTooltip = true;
    };
    typingIndicator = {
      enable = false;
      includeBlockedUsers = false;
      includeCurrentChannel = true;
      includeIgnoredUsers = false;
      includeMutedChannels = false;
      indicatorMode = 3;
    };
    typingTweaks = {
      enable = true;
      alternativeFormatting = true;
      showAvatars = true;
      showRoleColors = true;
    };
    unindent.enable = false;
    unlockedAvatarZoom = {
      enable = true;
      zoomMultiplier = 4.0;
    };
    unsuppressEmbeds.enable = false;
    userMessagesPronouns = {
      enable = false;
      pronounsFormat = "LOWERCASE";
      showSelf = true;
    };
    userVoiceShow = {
      enable = false;
      showInMemberList = true;
      showInMessages = true;
      showInUserProfileModal = true;
    };
    usrbg = {
      enable = true;
      nitroFirst = true;
      voiceBackground = true;
    };
    validReply.enable = false;
    validUser.enable = false;
    vcNarrator = {
      enable = false;
      deafenMessage = "{{USER}} deafened";
      joinMessage = "{{USER}} joined";
      latinOnly = false;
      leaveMessage = "{{USER}} left";
      moveMessage = "{{USER}} moved to {{CHANNEL}}";
      muteMessage = "{{USER}} muted";
      rate = 1.0;
      sayOwnName = false;
      undeafenMessage = "{{USER}} undeafened";
      unmuteMessage = "{{USER}} unmuted";
      voice = null;
      volume = 1.0;
    };
    vencordToolbox = {
      enable = true;
      showPluginMenu = true;
    };
    viewIcons = {
      enable = false;
      format = "webp";
      imgSize = "1024";
    };
    viewRaw = {
      enable = true;
      clickMethod = "Left";
      messageContextMenu = false;
    };
    voiceChatDoubleClick.enable = true;
    voiceDownload.enable = true;
    voiceMessages = {
      enable = true;
      echoCancellation = true;
      noiseSuppression = true;
    };
    volumeBooster = {
      enable = true;
      multiplier = 2.0;
    };
    webContextMenus = {
      enable = false;
      addBack = false;
    };
    webKeybinds = {
      enable = false;
      overrideCommonKeybinds = false;
      showNavigationButtons = true;
    };
    webPwa.enable = false;
    webRichPresence.enable = false;
    webScreenShare = {
      enable = false;
      contentHint = "motion";
      frameRate = "60";
      resolution = "1080";
      systemAudio = false;
    };
    webScreenShareFixes.enable = false;
    whoReacted = {
      enable = false;
      clickableAvatars = true;
    };
    xsOverlay = {
      enable = false;
      botNotifications = false;
      callNotifications = true;
      channelPingColor = "#8a2be2";
      dmNotifications = true;
      groupDmNotifications = true;
      lengthBasedTimeout = true;
      opacity = 1.0;
      pingColor = "#7289da";
      preferUdp = false;
      serverNotifications = true;
      soundPath = "default";
      timeout = 3;
      volume = 0.2;
      webSocketPort = 42070;
    };
    youtubeAdblock.enable = true;
  };
}
