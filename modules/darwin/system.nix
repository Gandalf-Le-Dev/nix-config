{ ... }:

{
  # Set primary user for user-specific settings
  system.primaryUser = "gandalfledev";

  system = {
    # Dock settings
    defaults.dock = {
      autohide = true;
      show-recents = false;
      # Disable hot corners
      wvous-tl-corner = 1; # Top-left: disabled
      wvous-tr-corner = 1; # Top-right: disabled
      wvous-bl-corner = 1; # Bottom-left: disabled
      wvous-br-corner = 1; # Bottom-right: disabled
    };

    # Finder settings
    defaults.finder = {
      AppleShowAllExtensions = true;
      ShowPathbar = true;
      ShowStatusBar = true;
      _FXShowPosixPathInTitle = true;
    };

    # Global macOS settings
    defaults.NSGlobalDomain = {
      # Disable auto-correct
      NSAutomaticSpellingCorrectionEnabled = false;
      # Disable auto-capitalize
      NSAutomaticCapitalizationEnabled = false;
      # Fast key repeat
      KeyRepeat = 2;
      InitialKeyRepeat = 15;
    };

    # Trackpad settings
    defaults.trackpad = {
      Clicking = true; # Tap to click
    };

    # Screenshots
    defaults.screencapture = {
      location = "~/Desktop/Screenshots";
      type = "png";
      disable-shadow = true;
    };

    # Disable .DS_Store on network and USB volumes
    defaults.CustomUserPreferences = {
      "com.apple.desktopservices" = {
        DSDontWriteNetworkStores = true;
        DSDontWriteUSBStores = true;
      };
    };
  };

  # Enable TouchID for sudo (updated option name)
  security.pam.services.sudo_local.touchIdAuth = true;
}
