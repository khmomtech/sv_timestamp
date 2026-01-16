Localization & SDK setup for sv_timestamp

This project targets Flutter/Dart versions specified in `pubspec.yaml` (SDK: ^3.9.2).
Follow these steps to reproduce and finish localization tasks locally.

1) Use FVM to pin Flutter version (recommended)

# Install fvm (if not installed)
# Option A: via dart pub
dart pub global activate fvm
# Ensure ~/.pub-cache/bin is in your PATH
export PATH="$PATH:$HOME/.pub-cache/bin"

# Option B: via Homebrew
brew install fvm

# Pin Flutter 3.38.7 for this repo
cd /Users/sotheakh/Documents/mydev/sv_timestamp/sv_timestamp
fvm install 3.38.7
fvm use 3.38.7 --local

# Use fvm when running flutter commands
fvm flutter pub get
fvm flutter gen-l10n

2) If you prefer not to use fvm
- Download Flutter 3.38.7 from flutter.dev, extract it, and set PATH to the `bin/` folder.
- Verify with `flutter --version`.

3) Add Khmer font files (optional but recommended)
- Download Noto Sans Khmer fonts (or any Khmer-capable font) and place them at:
  `assets/fonts/NotoSansKhmer-Regular.ttf`
  `assets/fonts/NotoSansKhmer-Bold.ttf`
- Uncomment the `NotoSansKhmer` font block in `pubspec.yaml`.

4) Regenerate localization files
fvm flutter pub get
fvm flutter gen-l10n

5) Test on a device configured for Khmer locale
fvm flutter run -d <device>

Notes
- `l10n.yaml` in the repo controls localization generation. Edit that file only if you need to change generation options.
- This repository includes placeholder Khmer strings for many keys; review and update `lib/l10n/app_localizations_km.dart` for accurate translations.

If you want, I can open a PR that adds `.fvm/fvm_config.json`, `pubspec.yaml` guidance, and this CONTRIBUTING file (already staged in this branch). Let me know if you'd like that PR created now.
