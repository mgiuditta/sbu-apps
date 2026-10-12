#!/usr/bin/env bash
# Scaffold a new Sbu app from Tools/templates/app.
#
# Usage: Tools/new_app.sh <Name> <accent-token> <glyph>
#   Name          English noun, capitalised: Level, Noise, Habits
#   accent-token  an accent-* token from Design/tokens.json: accent-level
#   glyph         a make_icons.py preset (level, noise, ...) or SVG elements in 1024 coordinates
#
# Creates Apps/Sbu<Name> (XcodeGen project, bundle id dev.sbu.<name>, SbuKit dependency,
# generated icon, fastlane lanes test/snapshot/frameit/beta/release) and generates the Xcode project.
set -euo pipefail

if [[ $# -ne 3 ]]; then
  sed -n '2,9p' "$0" | sed 's/^# \{0,1\}//'
  exit 64
fi

name=$1 accent=$2 glyph=$3
root=$(cd "$(dirname "$0")/.." && pwd)
lower=$(printf '%s' "$name" | tr '[:upper:]' '[:lower:]')
dest="$root/Apps/Sbu$name"

[[ $name =~ ^[A-Z][A-Za-z]+$ ]] || { echo "Name must be a capitalised word, like Level" >&2; exit 64; }
[[ -e $dest ]] && { echo "$dest already exists" >&2; exit 73; }
for tool in xcodegen fastlane python3; do
  command -v "$tool" >/dev/null || { echo "missing $tool (brew install $tool)" >&2; exit 69; }
done

# Token values come only from Design/tokens.json.
read -r accent_hex surface_hex < <(python3 - "$root/Design/tokens.json" "$accent" <<'PY'
import json, sys
colors = {t["name"]: t["value"]["light"] for t in json.load(open(sys.argv[1]))["color"]["tokens"]}
if not sys.argv[2].startswith("accent-") or sys.argv[2] not in colors:
    sys.exit("unknown accent token: " + sys.argv[2])
print(colors[sys.argv[2]], colors["surface"])
PY
)
accent_swift=$(python3 -c 'import sys; h, *t = sys.argv[1].split("-"); print(h + "".join(p.title() for p in t))' "$accent")
# accent-level is the one accent that takes ink instead of white.
on_accent=$([[ $accent == accent-level ]] && echo onAccentLevel || echo onAccent)

mkdir -p "$root/Apps"
cp -R "$root/Tools/templates/app" "$dest"
# Rename __NAME__ paths, deepest first.
find "$dest" -depth -name '*__NAME__*' | while read -r path; do
  mv "$path" "$(dirname "$path")/$(basename "$path" | sed "s/__NAME__/$name/g")"
done
find "$dest" -type f \( -name '*.swift' -o -name '*.yml' -o -name '*.json' -o -name '*.xcstrings' -o -name '*.txt' -o -name '*.strings' -o -name 'Fastfile' -o -name 'Appfile' -o -name 'Snapfile' \) -print0 |
  xargs -0 sed -i '' -e "s/__NAME__/$name/g" -e "s/__LOWER__/$lower/g" -e "s/__ACCENT__/$accent_swift/g" \
    -e "s/__ONACCENT__/$on_accent/g" -e "s/__ACCENT_HEX__/$accent_hex/g"

# Icon: design-system SVG, AppIcon.appiconset PNG, and the same SVG for SbuAppIconView.
assets="$dest/Sbu$name/Assets.xcassets"
python3 "$root/Tools/make_icons.py" "$(python3 -c 'import json, sys; print(json.dumps({"name": sys.argv[1], "accent": sys.argv[2], "glyph": sys.argv[3]}))' "$lower" "$accent" "$glyph")" \
  --out "$root/Design/icons" --appiconset "$assets/AppIcon.appiconset"
cp "$root/Design/icons/sbu-$lower.svg" "$assets/AppIconArtwork.imageset/AppIconArtwork.svg"

# frameit background: plain light `surface`.
python3 -c 'import sys; from PIL import Image; Image.new("RGB", (1320, 2868), sys.argv[1]).save(sys.argv[2])' \
  "$surface_hex" "$dest/fastlane/frame-background.png"

# fastlane's SnapshotHelper.swift for the UI test target.
tmp=$(mktemp -d)
(cd "$tmp" && mkdir fastlane && FASTLANE_SKIP_UPDATE_CHECK=1 fastlane snapshot init >/dev/null)
cp "$tmp/fastlane/SnapshotHelper.swift" "$dest/Sbu${name}UITests/"
rm -rf "$tmp"

(cd "$dest" && xcodegen generate --quiet)

cat <<EOF
Created Apps/Sbu$name (dev.sbu.$lower, $accent).
Next:
  1. Write the app in Apps/Sbu$name/Sbu$name (start from MainView.swift), strings in Localizable.xcstrings.
  2. Fill fastlane/metadata/{it,en-US}: subtitle and the __FEATURES__/__ONE_THING__ placeholders.
  3. cd Apps/Sbu$name && fastlane test
EOF
