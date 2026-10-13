#!/usr/bin/env bash
# Scaffold a new Sbu app from Tools/templates/app.
#
# Usage: Tools/new_app.sh <Name> <accent-token> <subject>
#   Name          English noun, capitalised: Level, Noise, Habits
#   accent-token  an accent-* token from Design/tokens.json: accent-level
#   subject       the instrument the icon engraves, in English: "an old iron padlock, closed" (needs GEMINI_API_KEY)
#
# Creates Apps/Sbu<Name> (XcodeGen project, bundle id dev.sbu.<name>, SbuKit dependency,
# generated icon, fastlane lanes test/snapshot/frames/beta/release), the site entry Site/src/content/apps/<name>.md,
# and generates the Xcode project.
set -euo pipefail

if [[ $# -ne 3 ]]; then
  sed -n '2,9p' "$0" | sed 's/^# \{0,1\}//'
  exit 64
fi

name=$1 accent=$2 subject=$3
root=$(cd "$(dirname "$0")/.." && pwd)
lower=$(printf '%s' "$name" | tr '[:upper:]' '[:lower:]')
dest="$root/Apps/Sbu$name"

[[ $name =~ ^[A-Z][A-Za-z]+$ ]] || { echo "Name must be a capitalised word, like Level" >&2; exit 64; }
[[ -e $dest ]] && { echo "$dest already exists" >&2; exit 73; }
for tool in xcodegen fastlane python3; do
  command -v "$tool" >/dev/null || { echo "missing $tool (brew install $tool)" >&2; exit 69; }
done

# The accent must be a token in Design/tokens.json.
python3 - "$root/Design/tokens.json" "$accent" <<'PY'
import json, sys
colors = {t["name"]: t["value"]["light"] for t in json.load(open(sys.argv[1]))["color"]["tokens"]}
if not sys.argv[2].startswith("accent-") or sys.argv[2] not in colors:
    sys.exit("unknown accent token: " + sys.argv[2])
PY
accent_swift=$(python3 -c 'import sys; h, *t = sys.argv[1].split("-"); print(h + "".join(p.title() for p in t))' "$accent")

mkdir -p "$root/Apps"
cp -R "$root/Tools/templates/app" "$dest"
# Rename __NAME__ paths, deepest first.
find "$dest" -depth -name '*__NAME__*' | while read -r path; do
  mv "$path" "$(dirname "$path")/$(basename "$path" | sed "s/__NAME__/$name/g")"
done
find "$dest" -type f \( -name '*.swift' -o -name '*.yml' -o -name '*.json' -o -name '*.xcstrings' -o -name '*.txt' -o -name '*.strings' -o -name 'Fastfile' -o -name 'Appfile' -o -name 'Snapfile' \) -print0 |
  xargs -0 sed -i '' -e "s/__NAME__/$name/g" -e "s/__LOWER__/$lower/g" -e "s/__ACCENT__/$accent_swift/g"

# Icon: engraved instrument on paper, light/dark/tinted in AppIcon.appiconset, light/dark for SbuAppIconView.
assets="$root/Apps/Sbu$name/Sbu$name/Assets.xcassets"
python3 - "$root/Design/icons/engravings.json" "$lower" "$accent" "$subject" <<'PY'
import json, sys
path, name, accent, subject = sys.argv[1:]
specs = json.load(open(path))
specs[name] = {"accent": accent, "subject": subject}
json.dump(specs, open(path, "w"), indent=2)
open(path, "a").write("\n")
PY
python3 "$root/Tools/make_icons.py" "$lower" --generate \
  --appiconset "$assets/AppIcon.appiconset" --artwork "$assets/AppIconArtwork.imageset"


# fastlane's SnapshotHelper.swift for the UI test target.
tmp=$(mktemp -d)
(cd "$tmp" && mkdir fastlane && FASTLANE_SKIP_UPDATE_CHECK=1 fastlane snapshot init >/dev/null)
cp "$tmp/fastlane/SnapshotHelper.swift" "$dest/Sbu${name}UITests/"
rm -rf "$tmp"

(cd "$dest" && xcodegen generate --quiet)

# Site page: only what the fastlane listing doesn't say. The site skips the app until the listing is filled in.
site_app="$root/Site/src/content/apps/$lower.md"
if [[ ! -e $site_app ]]; then
  order=$(( $(cat "$root"/Site/src/content/apps/*.md 2>/dev/null | sed -n 's/^order: //p' | sort -n | tail -1) + 1 ))
  cat > "$site_app" <<EOF
---
# Name, subtitle, description and features come from Apps/Sbu$name/fastlane/metadata. Do not repeat them here.
app: Sbu$name
accent: $accent
order: $order
status: building
appStoreId: null
category: UtilitiesApplication
# originale: { name: <Originale>, appStoreId: <id> }
# figure:
#   it: { value: "<Cifra>", label: <etichetta> }
#   en: { value: "<figure>", label: <label> }
---
EOF
fi

# App Store Connect record. Not fatal: without FASTLANE_USER, or if 2FA needs a terminal, run the lane later.
asc_step="cd Apps/Sbu$name && FASTLANE_USER=<apple-id> fastlane create_app"
if [[ -n ${FASTLANE_USER:-} ]] && (cd "$dest" && FASTLANE_SKIP_UPDATE_CHECK=1 fastlane create_app); then
  asc_step="App Store Connect record created."
fi

cat <<EOF
Created Apps/Sbu$name (dev.sbu.$lower, $accent).
$asc_step
Next:
  1. Write the app in Apps/Sbu$name/Sbu$name (start from MainView.swift), strings in Localizable.xcstrings.
  2. Fill fastlane/metadata/{it,en-US}: subtitle and the __FEATURES__/__ONE_THING__ placeholders.
  3. cd Apps/Sbu$name && fastlane test
  4. Site/src/content/apps/$lower.md: Originale, Cifra, FAQ; then cd Site && npm run build
EOF
