#!/bin/zsh
# App Store screenshots for an app with a watchOS target, which App Store Connect requires once
# the binary contains a Watch app. Builds the Watch scheme for the Watch simulator, launches it in
# its demo mode in Italian and English, and saves
# Apps/<App>/fastlane/screenshots/<lang>/Apple Watch Series 11 (46mm)-01-watch.png (416×496).
# deliver uploads them as they are; Tools/make_screenshots.py frames only the iPhone ones.
#
# The Watch app must show demo content when the environment variable `demo_env` is set, since a
# simulator has no paired iPhone (Habits: SBU_WATCH_DEMO in WatchHabits+Demo.swift).
#
# Usage: Tools/watch_screenshots.sh <App dir> <Watch scheme> <Watch bundle id> <demo env var>
#   Tools/watch_screenshots.sh Apps/SbuHabits SbuHabitsWatch dev.sbu.habits.watchkitapp SBU_WATCH_DEMO
set -euo pipefail

app_dir=${1:A} scheme=$2 bundle=$3 demo_env=$4
device="Apple Watch Series 11 (46mm)"
udid=$(xcrun simctl list devices available | grep -F "$device (" | head -1 | grep -oE '[0-9A-F-]{36}')
[[ -n $udid ]] || { echo "No '$device' simulator: create it in Xcode > Devices and Simulators." >&2; exit 1; }

derived=$(mktemp -d)
trap 'rm -rf $derived' EXIT
project=$(print -l $app_dir/*.xcodeproj(N) | head -1)
xcodebuild build -project $project -scheme $scheme -destination "id=$udid" -derivedDataPath $derived -quiet

xcrun simctl boot $udid 2>/dev/null || true
xcrun simctl bootstatus $udid >/dev/null
xcrun simctl install $udid $derived/Build/Products/Debug-watchsimulator/*.app

for lang locale folder in it it_IT it en en_US en-US; do
  xcrun simctl terminate $udid $bundle 2>/dev/null || true
  env SIMCTL_CHILD_$demo_env=1 xcrun simctl launch $udid $bundle -AppleLanguages "($lang)" -AppleLocale $locale >/dev/null
  sleep 4  # the first frame, with the demo habits laid out
  mkdir -p "$app_dir/fastlane/screenshots/$folder"
  xcrun simctl io $udid screenshot "$app_dir/fastlane/screenshots/$folder/$device-01-watch.png" >/dev/null 2>&1
  echo "${app_dir:t} $folder: $device-01-watch.png"
done
xcrun simctl terminate $udid $bundle 2>/dev/null || true
