# Flavors

In normal usage, the user needs to select a robotnix "flavor" in their configuration file by setting the `flavor` option.
Flavors may change the default settings of some other modules, which might not match the default setting shown on the [Options](options.md) reference page.
As an example, the GrapheneOS flavor enables `apps.vanadium.enable` by default.
For further details, consult the implementation of the flavor under (for example) `flavors/grapheneos/*`.

Currently, the vanilla and GrapheneOS flavors are based on Android 12, while the LineageOS flavor uses either Android 10 or Android 11, depending on the device.
If a robotnix flavor supports multiple Android versions (either older or experimental newer versions),
this can be overridden by setting (for example) `androidVersion = 11`.

## Vanilla
The vanilla flavor is meant to represent a (mostly) unaltered version of the AOSP code published by Google.
Vanilla AOSP support may be enabled by setting `flavor = "vanilla";`.
It does, however, include some small fixes and usability improvements.
Enabling the vanilla flavor also enables the chromium webview/app by default as well.

The vanilla flavor in robotnix currently supports only Pixel phones which still receive updates from Google (>= Pixel 3a).
Older Pixel phones (e.g. `marlin` / Pixel 1 XL) may be still be built by overriding `androidVersion = 10;`.
However, these might be removed in the future as they are no longer receiving device updates from Google.

The vanilla flavor retains working support for Android Verified Boot,
and allows a user to re-lock the bootloader using the user's own generated root of trust.

## GrapheneOS
GrapheneOS is a privacy and security focused mobile OS with Android app compatibility developed as a non-profit open source project.
GrapheneOS support may be enabled by setting `flavor = "grapheneos";`.
Enabling the GrapheneOS flavor will also enable the Vanadium app/webview and Seedvault robotnix modules.
Additionally, the upstream GrapheneOS updater is disabled,
but the robotnix updater app (based on the GrapheneOS updater app) can be enabled by setting `apps.updater.enable = true;` and `apps.updater.url = "...";`.

The user should understand that enabling certain robotnix modules may have security implications as they produce a may produce a larger attack surface than is intended by the GrapheneOS project.
Some modules, such as the MicroG and the F-Droid privileged extension, have been explicitly rejected by upstream GrapheneOS.
If the user wishes to enable these modules, they should understand and be willing to accept the usability/security tradeoffs.

GrapheneOS releases are tagged in robotnix, but before 2021.05.16.04, the date suffix (YY.MM.DD.HH) did not match the one used in the upstream release.
Only the latest GrapheneOS release is included with robotnix, even if that release is only a "beta" release upstream.
If you would prefer to stick to only stable releases, wait until the release is marked "stable" upstream.

Before reporting bugs to upstream GrapheneOS, please ensure that you can reproduce your issue using the official GrapheneOS images.
Alternatively, feel free to ask about your issue on the `#robotnix:nixos.org` channel on Matrix.

## LineageOS
LineageOS is a free and open-source operating system for various devices, based on the Android mobile platform.
LineageOS support may be enabled by setting `flavor = "lineageos";`.
At the time of writing, this includes support for ~160 devices.

Robotnix includes support for LineageOS 20.0 to 22.1 (some older releases are also present but unmaintained).
By default, robotnix will select the latest supported version for the device specified in the configuration.
This can be overridden by setting the corresponding `androidVersion`. Here is the correspondance table of the supported Robotnix version:

`androidVersion` | LineageOS version
--- | ---
10 | 17.1
11 | 18.1
12 | 19.1
13 | 20.0
14 | 21.0
15 | 22.1

Since LineageOS does not produce tagged releases like vanilla AOSP or GrapheneOS,
we periodically take snapshots of the upstream repositories and include metadata in robotnix which pins the source repositories to particular revisions.
This metadata can be found under `flavors/lineageos/*/*.json`.

LineageOS support in robotnix should be considered "experimental," as it does yet have the same level of support provided for `vanilla` and `grapheneos` flavors.
LineageOS source metadata may be updated irregularly in robotnix, and certain modules (such as the updater) are not guaranteed to work.
Moreover, LineageOS does not appear to provide the same level of security as even the vanilla flavor, as it disables dm-verity/AVB, sets `userdebug` as the default variant, and uses vendor files with unclear origin.
LineageOS support is still valuable to include as it extends support to a much wider variety of devices, and provides the base that many other Android ROMs use to customize.
Contributions and fixes from LineageOS users are especially welcome!

For devices with "boot-as-recovery", the typical LineageOS flashing process involves first producing a `boot.img` and `ota`, flashing `boot.img` with fastboot, and then sideloading the `ota` in recovery mode.
The `boot.img` and `ota` targets can be built using `nix-build ... -A bootImg` or `nix-build ... -A ota`, respectively.
Check the upstream documentation for your particular device before following the above instructions.

To add a support for a particular device, add its code to `./flavors/lineageos/supported_devices.toml`, then run `nix-shell`, then `./flavors/lineageos/update.sh -s <lineageos_branch>`.

### Note on signing
When you build a LineageOS image, the system image is cryptographically signed by default. There are three options concerning the keys the image can be signed with:

- the official LineageOS keys (release-keys). We don't have access to them, so the only images signed with these keys are the official LineageOS builds. If you previously installed LineageOS from official sources, these are the keys you are currently using.
- the test keys (test-keys). These keys are publicly available, and Robotnix uses them by default.
- your own release keys. Please see [the relevant section in the Building page](../building.md#building-and-signing-releases).

When you run LineageOS and install apps that save stuff to your phone, that data is "coupled" to the keys your LineageOS install was signed with. If you try to boot a LineageOS install with an image that was signed with different build keys than the ones your user data was coupled to, it will complain and not boot at best (or you'll loose all your data at worse).

In that case, you have two options:

- you can wipe your userdata partition and start over with the new keys
- or you can migrate your userdata from the keys of your old install to your new install

To do the latter, please see [the official documentation](https://wiki.lineageos.org/signing_builds#using-a-script).

## Anbox
Anbox is a Free and open-source container-based approach at running Android on Linux systems.
Anbox support may be enabled by setting `flavor = "anbox";`.

At the time of writing, support is experimental.
Given that Anbox is based on an older Android release (7), support for Robotnix options is not guaranteed.

## Waydroid
Waydroid is a Free and open-source container-based approach at running Android on Linux systems.
Waydroid support may be enabled by setting device and flavor, e.g. `device="x86_64"; flavor="waydroid";`.
LineageOS based system/vendor images can be built using `nix-build ... -A config.build.waydroid`.

At the time of writing, support is experimental.
