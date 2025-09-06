{
  config,
  lib,
  pkgs,
  ...
}:
{
  flavor = "lineageos";

  # device codename - FP4 for Fairphone 4 in this case.
  # Supported devices are listed under https://wiki.lineageos.org/devices/
  device = "pstar";

  # LineageOS branch.
  # You can check the supported branches for your device under
  # https://wiki.lineageos.org/devices/<device codename>
  # Leave out to choose the official default branch for the device.
  flavorVersion = "22.1";

  apps.fdroid.enable = true;
  microg.enable = true;

  # Enables ccache for the build process. Remember to add /var/cache/ccache as
  # an additional sandbox path to your Nix config.
  ccache.enable = true;

  # Enable lindroid for the build.
  lindroid.enable = true;
  lindroid.systemVersion = "LineageOS_22.1";

  # buildDateTime is set by default by the flavor, and is updated when those flavors have new releases.
  # If you make new changes to your build that you want to be pushed by the OTA updater, you should set this yourself.
  # buildDateTime = 1584398664; # Use `date "+%s"` to get the current time

  signing.enable = true;
  signing.keyStorePath = "/etc/secrets/android-keys"; # A _string_ of the path for the key store.
}
