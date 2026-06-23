platforms = ["macos"]
after = ["@stdlib//bundles/modern-macos"]

def install(ctx):
    r = ctx.run("uname", ["-s"])
    os = r.stdout.strip()
    if os != "Darwin":
        ctx.log("Not macOS — skipping macOS defaults")
        return

    home = ctx.home

    # "System Settings" (Ventura+) / "System Preferences" (older macOS)
    ctx.run("osascript", ["-e",
             'try\n    tell application "System Settings" to quit\non error\n    try\n        tell application "System Preferences" to quit\n    end try\nend try'])

    # --- computer name ---
    name = ctx.prompt("Set a computer name? (leave blank to skip)")
    if name:
        ctx.run("sudo", ["scutil", "--set", "ComputerName", name])
        ctx.run("sudo", ["scutil", "--set", "HostName", name])
        ctx.run("sudo", ["scutil", "--set", "LocalHostName", name])
        ctx.run("sudo", ["defaults", "write",
                 "/Library/Preferences/SystemConfiguration/com.apple.smb.server",
                 "NetBIOSName", "-string", name])

    # --- Homebrew PATH ---
    r = ctx.run("brew", ["--prefix"])
    bp = r.stdout.strip()
    ctx.run("sudo", ["launchctl", "config", "user", "path",
             bp + "/bin:" + bp + "/sbin:/usr/local/bin:/usr/local/sbin:/usr/bin:/bin"])

    # --- general UI/UX ---
    # Mute startup chime. Apple Silicon (arm64) uses StartupMute; Intel uses SystemAudioVolume.
    r = ctx.run("uname", ["-m"])
    arch = r.stdout.strip()
    if arch == "arm64":
        ctx.run("sudo", ["nvram", "StartupMute=%01"])
    else:
        ctx.run("sudo", ["nvram", "SystemAudioVolume="])
    ctx.run("defaults", ["write", "com.apple.finder", "AppleShowAllFiles",
             "-boolean", "true"])
    ctx.run("defaults", ["write", "NSGlobalDomain",
             "NSNavPanelExpandedStateForSaveMode", "-bool", "true"])
    ctx.run("defaults", ["write", "NSGlobalDomain",
             "NSNavPanelExpandedStateForSaveMode2", "-bool", "true"])
    ctx.run("defaults", ["write", "NSGlobalDomain",
             "PMPrintingExpandedStateForPrint", "-bool", "true"])
    ctx.run("defaults", ["write", "NSGlobalDomain",
             "PMPrintingExpandedStateForPrint2", "-bool", "true"])
    ctx.run("defaults", ["write", "NSGlobalDomain",
             "NSDocumentSaveNewDocumentsToCloud", "-bool", "false"])
    ctx.run("defaults", ["write", "com.apple.print.PrintingPrefs",
             "Quit When Finished", "-bool", "true"])
    ctx.run("defaults", ["write", "NSGlobalDomain",
             "NSAutomaticCapitalizationEnabled", "-bool", "false"])
    ctx.run("defaults", ["write", "NSGlobalDomain",
             "NSAutomaticDashSubstitutionEnabled", "-bool", "false"])
    ctx.run("defaults", ["write", "NSGlobalDomain",
             "NSAutomaticPeriodSubstitutionEnabled", "-bool", "false"])
    ctx.run("defaults", ["write", "NSGlobalDomain",
             "NSAutomaticQuoteSubstitutionEnabled", "-bool", "false"])
    ctx.run("defaults", ["write", "NSGlobalDomain",
             "NSAutomaticSpellingCorrectionEnabled", "-bool", "false"])
    ctx.run("defaults", ["write", "NSGlobalDomain",
             "NSWindowResizeTime", "-float", "0.001"])

    # --- keyboard ---
    ctx.run("defaults", ["write", "NSGlobalDomain",
             "ApplePressAndHoldEnabled", "-bool", "false"])
    ctx.run("defaults", ["write", "NSGlobalDomain", "KeyRepeat",
             "-int", "1"])
    ctx.run("defaults", ["write", "NSGlobalDomain",
             "InitialKeyRepeat", "-int", "10"])

    # --- advanced keyboard mapping ---
    ctx.log("Applying advanced keyboard mapping...")
    ctx.run("defaults", ["write", "NSGlobalDomain",
             "AppleKeyboardUIMode", "-int", "3"])
    ctx.run("defaults", ["write", "NSGlobalDomain",
             "com.apple.keyboard.fnState", "-bool", "true"])

    # --- trackpad / mouse ---
    ctx.run("defaults", ["write",
             "com.apple.driver.AppleBluetoothMultitouch.trackpad",
             "Clicking", "-bool", "true"])
    ctx.run("defaults", ["-currentHost", "write", "NSGlobalDomain",
             "com.apple.mouse.tapBehavior", "-int", "1"])
    ctx.run("defaults", ["write", "NSGlobalDomain",
             "com.apple.mouse.tapBehavior", "-int", "1"])
    ctx.run("defaults", ["write", "com.apple.BluetoothAudioAgent",
             "Apple Bitpool Min (editable)", "-int", "40"])

    # --- energy ---
    ctx.run("sudo", ["pmset", "-c", "displaysleep", "15"])
    ctx.run("sudo", ["pmset", "-b", "displaysleep", "5"])
    ctx.run("sudo", ["pmset", "-b", "sleep", "15"])
    ctx.run("sudo", ["pmset", "-c", "sleep", "30"])
    ctx.run("sudo", ["pmset", "-a", "hibernatemode", "0"])
    # Remove pre-existing sleepimage; hibernatemode 0 won't write a new one
    # but doesn't clean up existing files (which can be equal to RAM size).
    ctx.run("sudo", ["rm", "-f", "/var/vm/sleepimage"])

    # --- Xcode CLT + Rosetta 2 ---
    ctx.log("Installing foundational developer tools...")
    r = ctx.run("xcode-select", ["-p"])
    if r.exit_code != 0:
        ctx.log("Installing Xcode Command Line Tools...")
        ctx.run("xcode-select", ["--install"])
    r = ctx.run("uname", ["-m"])
    arch = r.stdout.strip()
    if arch == "arm64":
        r = ctx.run("pkgutil", ["--pkg-info", "com.apple.pkg.RosettaUpdateAuto"])
        if r.exit_code != 0:
            ctx.log("Installing Rosetta 2 for x86_64 compatibility...")
            ctx.run("sudo", ["softwareupdate", "--install-rosetta",
                     "--agree-to-license"])
        else:
            ctx.log("Rosetta 2 already installed")

    # --- system dialogs ---
    ctx.log("Tuning system dialogs and security prompts...")
    ctx.run("defaults", ["write", "com.apple.CrashReporter",
             "DialogType", "-string", "none"])

    # --- background daemon priorities ---
    ctx.log("Tuning background daemon priorities...")
    ctx.run("sudo", ["sysctl", "debug.lowpri_throttle_enabled=0"])
    # Persist across reboots via /etc/sysctl.conf.
    ctx.run("sudo", ["sh", "-c",
             "grep -qF 'debug.lowpri_throttle_enabled' /etc/sysctl.conf 2>/dev/null " +
             "|| echo 'debug.lowpri_throttle_enabled=0' >> /etc/sysctl.conf"])

    # --- hardware-specific tuning ---
    ctx.log("Tuning for Studio Display and pro hardware...")
    ctx.run("defaults", ["-currentHost", "write", "-globalDomain",
             "AppleFontSmoothing", "-int", "0"])
    ctx.run("defaults", ["write", "NSGlobalDomain",
             "AppleReduceDesktopTinting", "-bool", "true"])
    ctx.run("defaults", ["write",
             "com.apple.systempreferences",
             "com.apple.preference.sound.input.autoselect",
             "-bool", "false"])
    # --- regional defaults ---
    ctx.log("Setting regional and format defaults...")
    ctx.run("defaults", ["write", "NSGlobalDomain",
             "AppleICUForce24HourTime", "-bool", "true"])
    ctx.run("defaults", ["write", "NSGlobalDomain",
             "AppleMetricUnits", "-bool", "true"])
    ctx.run("defaults", ["write", "NSGlobalDomain",
             "AppleMeasurementUnits", "-string", "Centimeters"])

    # --- Finder ---
    ctx.log("Applying Finder preferences...")
    ctx.run("osascript", ["-e", 'tell application "Finder" to quit'])
    ctx.run("defaults", ["write", "NSGlobalDomain",
             "AppleShowAllExtensions", "-bool", "true"])
    ctx.run("defaults", ["write", "com.apple.finder", "ShowPathbar",
             "-bool", "true"])
    ctx.run("defaults", ["write", "com.apple.finder",
             "FXPreferredViewStyle", "-string", "Nlsv"])
    ctx.run("defaults", ["write", "com.apple.finder",
             "_FXSortFoldersFirst", "-bool", "true"])
    ctx.run("defaults", ["write", "com.apple.finder",
             "FXDefaultSearchScope", "-string", "SCcf"])
    ctx.run("defaults", ["write", "com.apple.finder",
             "FXEnableExtensionChangeWarning", "-bool", "false"])
    ctx.run("defaults", ["write", "com.apple.finder", "QuitMenuItem",
             "-bool", "false"])
    ctx.run("defaults", ["write", "NSGlobalDomain",
             "com.apple.springing.enabled", "-bool", "true"])
    ctx.run("defaults", ["write", "NSGlobalDomain",
             "com.apple.springing.delay", "-float", "0"])
    ctx.run("defaults", ["write", "com.apple.desktopservices",
             "DSDontWriteNetworkStores", "-bool", "true"])
    ctx.run("defaults", ["write", "com.apple.desktopservices",
             "DSDontWriteUSBStores", "-bool", "true"])
    finder_plist = home + "/Library/Preferences/com.apple.finder.plist"
    for key in ["DesktopViewSettings", "FK_StandardViewSettings", "StandardViewSettings"]:
        path = ":" + key + ":IconViewSettings:showItemInfo"
        r = ctx.run("/usr/libexec/PlistBuddy", ["-c", "Set " + path + " true", finder_plist])
        if r.exit_code != 0:
            ctx.run("/usr/libexec/PlistBuddy", ["-c", "Add " + path + " bool true", finder_plist])
    ctx.run("chflags", ["nohidden", home + "/Library"])
    ctx.run("sudo", ["chflags", "nohidden", "/Volumes"])
    ctx.run("open", ["-a", "Finder"])

    # --- Dock ---
    ctx.log("Applying Dock preferences...")
    ctx.run("defaults", ["write", "com.apple.dock", "tilesize",
             "-int", "48"])
    ctx.run("defaults", ["write", "com.apple.dock",
             "minimize-to-application", "-bool", "true"])
    ctx.run("defaults", ["write", "com.apple.dock",
             "enable-spring-load-actions-on-all-items", "-bool", "true"])
    ctx.run("defaults", ["write", "com.apple.dock",
             "show-process-indicators", "-bool", "true"])
    ctx.run("defaults", ["write", "com.apple.dock",
             "expose-animation-duration", "-float", "0.1"])
    ctx.run("defaults", ["write", "com.apple.dock",
             "expose-group-by-app", "-bool", "false"])
    ctx.run("defaults", ["write", "com.apple.dock", "mru-spaces",
             "-bool", "false"])
    ctx.run("defaults", ["write", "com.apple.spaces",
             "spans-displays", "-bool", "false"])
    ctx.run("defaults", ["write", "NSGlobalDomain",
             "AppleSpacesSwitchOnActivate", "-bool", "false"])
    ctx.run("defaults", ["write", "com.apple.dock", "autohide-delay",
             "-float", "0"])
    ctx.run("defaults", ["write", "com.apple.dock", "autohide",
             "-bool", "true"])
    ctx.run("defaults", ["write", "com.apple.dock", "showhidden",
             "-bool", "true"])
    ctx.run("defaults", ["write", "com.apple.dock", "show-recents",
             "-bool", "false"])
    ctx.run("killall", ["Dock"])

    # --- screen sharing hygiene ---
    ctx.log("Applying content creation & screen sharing hygiene...")
    ctx.run("defaults", ["write", "com.apple.finder",
             "CreateDesktop", "-bool", "false"])
    ctx.run("defaults", ["-currentHost", "write",
             "com.apple.notificationcenterui", "dndMirroring",
             "-bool", "true"])

    # --- apps ---
    ctx.log("Applying app preferences...")
    ctx.run("defaults", ["-currentHost", "write",
             "com.apple.ImageCapture", "disableHotPlug", "-bool", "true"])
    ctx.run("defaults", ["write", "com.apple.TextEdit", "RichText",
             "-int", "0"])
    ctx.run("defaults", ["write", "com.apple.TextEdit",
             "PlainTextEncoding", "-int", "4"])
    ctx.run("defaults", ["write", "com.apple.TextEdit",
             "PlainTextEncodingForWrite", "-int", "4"])
    ctx.run("defaults", ["write", "com.apple.DiskUtility",
             "DUDebugMenuEnabled", "-bool", "true"])
    ctx.run("defaults", ["write", "com.apple.DiskUtility",
             "advanced-image-options", "-bool", "true"])
    ctx.run("defaults", ["write", "com.apple.TimeMachine",
             "DoNotOfferNewDisksForBackup", "-bool", "true"])
    ctx.run("mkdir", ["-p", home + "/workspace"])
    ctx.run("touch", [home + "/workspace/.metadata_never_index"])
    ctx.run("sudo", ["mdutil", "-E", "/"])
    ctx.run("sudo", ["defaults", "write",
             "/Library/Preferences/com.apple.SpotlightServer.plist",
             "ExternalVolumesIgnore", "-bool", "true"])
    ctx.run("defaults", ["write", "com.apple.Console", "DebugMenu",
             "-bool", "true"])
    ctx.run("defaults", ["write", "com.apple.Console",
             "ShowDeveloperLogs", "-bool", "true"])
    ctx.run("mkdir", ["-p", home + "/Pictures/Screenshots"])
    ctx.run("defaults", ["write", "com.apple.screencapture", "location",
             "-string", home + "/Pictures/Screenshots"])
    ctx.run("defaults", ["write", "com.apple.screencapture", "type",
             "-string", "png"])
    ctx.run("defaults", ["write", "com.apple.mail",
             "AddressesIncludeNameOnPasteboard", "-bool", "false"])
    ctx.run("defaults", ["write", "com.apple.mail",
             "DisableInlineAttachmentViewing", "-bool", "true"])

    # --- Safari / WebKit ---
    ctx.log("Applying Safari & WebKit developer settings...")
    ctx.run("defaults", ["write", "com.apple.Safari",
             "IncludeDevelopMenu", "-bool", "true"])
    ctx.run("defaults", ["write", "com.apple.Safari",
             "WebKitDeveloperExtrasEnabledPreferenceKey", "-bool", "true"])
    ctx.run("defaults", ["write", "com.apple.Safari",
             "com.apple.Safari.ContentPageGroupIdentifier.WebKit2DeveloperExtrasEnabled",
             "-bool", "true"])
    ctx.run("defaults", ["write", "NSGlobalDomain",
             "WebKitDeveloperExtras", "-bool", "true"])

    ctx.log("macOS defaults applied")

def upgrade(ctx):
    install(ctx)

def uninstall(ctx):
    ctx.log("macOS defaults cannot be reverted automatically — " +
            "run 'defaults delete' for each key manually")
