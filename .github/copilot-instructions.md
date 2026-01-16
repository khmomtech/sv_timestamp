<!-- Copilot / AI agent instructions for the sv_timestamp Flutter app -->

# sv_timestamp — Copilot instructions

Purpose: quickly orient AI coding agents so they can make safe, focused changes.

- Quick start (commands):
  - Install deps: `flutter pub get`
  - Run on device: `flutter run -d <device>` (use Xcode for iOS device builds)
  - Run tests: `flutter test`
  - Build: `flutter build apk` / `flutter build ios`

- Big picture (what this app does):
  - Mobile Flutter app that captures photos and stamps them with time, location, and a logo.
  - Image processing and watermarking is done in Dart using the `image` package (no native bitmaps).
  - Settings are stored in `SharedPreferences`; app state uses `Provider` / `ChangeNotifier`.

- Major components & where to change them (concrete examples):
  - App entry & DI: `lib/main.dart` — initializes `Hive`, `EmojiManager`, and registers `StorageService` and `SettingsProvider`.
  - Capture flow: `lib/screens/camera_screen.dart` — camera lifecycle, permissions, capture, and handoff to the metadata pipeline.
  - Image processing / watermarking: `lib/utils/metadata_service.dart` — layout, font sizing, logo loading, geocoding/address wrapping, and final JPG encoding.
  - Persistent storage: `lib/utils/storage_service.dart` — saves processed images to ApplicationDocuments under `captured_images/` named as `<milliseconds>.jpg`.
  - Settings & locale: `lib/utils/setting_provider.dart` and `lib/l10n/*` (`pubspec.yaml` has `flutter.generate: true` for gen-l10n).

- Key developer workflows and gotchas:
  - Localization: run `flutter pub get` then the generated files in `lib/l10n/` are used directly (see `lib/l10n/app_localizations.dart`).
  - Image filenames: the app uses `timestamp.millisecondsSinceEpoch.jpg` — this format is relied on when parsing stored images (see `_loadImages` in `StorageService`).
  - SharedPreferences keys to be aware of:
    - `watermark_size`, `custom_logo_path`, `app_title`, `sound_on_capture`, `vibration_on_capture`, `image_quality`, `watermark_position`, `watermark_opacity`.
  - Font/bitmap text drawing: `metadata_service.dart` uses built-in `image` fonts (e.g. `img.arial24`) and a simple text-wrapping routine — edits here change visual output for all saved images.
  - Custom logo handling: `MetadataService` prefers an in-memory base64 logo, falls back to `assets/logo.png`, and finally to a file path stored in `custom_logo_path`.
  - Camera / emulator: emulators may not provide a camera; to reproduce capture flows use a physical device or configure an emulator with a virtual camera. Permissions are requested at runtime (via `geolocator` and camera package).

- Integration points & major dependencies:
  - camera (capture), geolocator + geocoding (coordinates -> address), image (processing), shared_preferences (settings), path_provider (file storage), provider (DI/state).
  - Native platform notes: iOS Info.plist and Android manifest need camera & location permissions to exercise capture flows.

- Code patterns & conventions specific to this repo:
  - Services are `ChangeNotifier` and registered via `MultiProvider` in `main.dart`.
  - Images are processed synchronously in Dart (heavy CPU work) — prefer small incremental changes and test on device.
  - App initializes global singletons at startup: `EmojiManager.init()`, `Hive.initFlutter()`, `MetadataService.initializeSettings()`.
  - The app relies on `SharedPreferences` as the canonical settings store (no remote sync).

- Where to look for low-risk change areas vs. risky areas:
  - Low-risk: UI text, theming (`lib/theme/app_theme.dart`), small widget adjustments, localization string updates.
  - Medium-risk: `StorageService` persistence logic, settings keys, or provider wiring — affects app state and stored data.
  - High-risk: `metadata_service.dart` image layout, resizing, and drawing code — changes affect all saved images and must be tested on device with sample images.

- PR guidance for AI edits:
  - Keep changes small and self-contained; include device/manual test notes for capture and saved-image verification.
  - If modifying `metadata_service.dart`, include before/after example images in PR or a short description of expected visual changes.

If anything above is unclear or you want more examples (e.g., exact SharedPreferences usages, sample saved-image path, or edit suggestions for watermark layout), tell me which area to expand.
