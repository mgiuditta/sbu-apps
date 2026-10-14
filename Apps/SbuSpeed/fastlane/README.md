fastlane documentation
----

# Installation

Make sure you have the latest version of the Xcode command line tools installed:

```sh
xcode-select --install
```

For _fastlane_ installation instructions, see [Installing _fastlane_](https://docs.fastlane.tools/#installing-fastlane)

# Available Actions

## iOS

### ios internal_testers

```sh
[bundle exec] fastlane ios internal_testers
```

Internal TestFlight group with every build, with SBU_TESTER_EMAIL (default matteogiuditta@gmail.com) in it

### ios test

```sh
[bundle exec] fastlane ios test
```

Unit tests on the simulator

### ios snapshot

```sh
[bundle exec] fastlane ios snapshot
```

App Store screenshots (Snapfile), Italian and English

### ios frames

```sh
[bundle exec] fastlane ios frames
```

Panorama on paper with the icon engraving and a closing card with the logo (Tools/make_screenshots.py)

### ios beta

```sh
[bundle exec] fastlane ios beta
```

Build and upload to TestFlight

### ios release

```sh
[bundle exec] fastlane ios release
```

Build and upload to the App Store with metadata and framed screenshots, without submitting

### ios metadata

```sh
[bundle exec] fastlane ios metadata
```

Upload only metadata and framed screenshots to the App Store listing, without a build or submitting

----

This README.md is auto-generated and will be re-generated every time [_fastlane_](https://fastlane.tools) is run.

More information about _fastlane_ can be found on [fastlane.tools](https://fastlane.tools).

The documentation of _fastlane_ can be found on [docs.fastlane.tools](https://docs.fastlane.tools).
