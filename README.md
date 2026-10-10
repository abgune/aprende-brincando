Current app version: 0.1.1+2. See [visual update and artwork notes](docs/VISUAL_UPDATE.md).

# Aprende Brincando

An offline-first Flutter Android learning prototype for children aged 5–8 in Mozambique. Portuguese reading and maths lessons, local child profiles, quizzes, stars and a parent progress screen.

Build 01 follows the user's selected **complete learning prototype / mixed curriculum / modern balanced design** scope. The earlier ChatGPT specification could not be retrieved; this agreed scope and newly authored starter content are documented in [the Build 01 specification](docs/BUILD_01_SPEC.md).

## Included

- Up to eight device-local child profiles with nickname, age and symbol.
- 12 bundled lessons and 48 exercises, across three freely selectable levels.
- Teaching introductions, supportive feedback and repeatable practice.
- Best results, completion counts, attempts and stars saved per child.
- Parent overview behind a simple arithmetic gate.
- No runtime network dependency, online accounts, ads or purchases.

This is a prototype. The curriculum awaits review by Mozambican educators. Emerging readers may need adult help because narration is not included. Clearing app data or uninstalling can erase local progress. The arithmetic gate is not authentication.

## Tooling

Verified build versions are in [the build report](docs/BUILD_REPORT.md). The development environment uses Flutter 3.47.7 / Dart 3.13.5, Java 21, Android API 36, build-tools 36.0.0 and NDK 28.2.13676358. Flutter currently requires Android API 24 or newer for this application.

The task-local Flutter and Android installations live outside this repository in the Codex workspace's `work/tooling` folder. Open PowerShell in this project and make them available for that session:

```powershell
. ./scripts/Use-Tooling.ps1
flutter doctor -v
flutter pub get
flutter run -d YOUR_ANDROID_DEVICE_ID
```

On another machine, install [Flutter](https://docs.flutter.dev/install/manual) and the [Android development tools](https://docs.flutter.dev/platform-integration/android/setup), then use your own paths:

```powershell
. ./scripts/Use-Tooling.ps1 -FlutterSdk C:/dev/flutter -AndroidSdk C:/dev/android-sdk
flutter config --android-sdk $env:ANDROID_HOME
flutter pub get
```

No global PATH edit is necessary. If Windows temporary-file paths cause Flutter test compilation to fail, set `TEMP` and `TMP` to a short writable directory for the current session before running tests.

## Verify and build

```powershell
./scripts/Verify.ps1 -BuildApk
```

Equivalent commands on any supported development host:

```text
flutter pub get
dart format --output=none --set-exit-if-changed lib test integration_test tool
flutter analyze
flutter test --coverage
flutter build apk --debug
```

The APK is generated at `build/app/outputs/flutter-apk/app-debug.apk`. It is debug-signed and intended for prototype testing. No production signing key or store release has been configured. CI runs analysis, tests and a debug APK build on pushes and pull requests.

For smaller phone packages, Build 01 also uses:

```text
flutter build apk --release --split-per-abi --target-platform android-arm,android-arm64
```

These optimized packages still use the generated debug signing key and are test builds. The ARM64 package is for 64-bit ARM phones; the armeabi-v7a package is for 32-bit ARM phones. Choose the package matching the device. Build outputs are kept outside Git; locally delivered copies and checksums accompany this project in the task's outputs folder.

For device testing, use a dedicated install and follow [the acceptance checklist](docs/ACCEPTANCE.md). Run the integration test with:

```text
flutter test integration_test/offline_learning_test.dart -d YOUR_ANDROID_DEVICE_ID
```

## Project structure

```text
lib/
  main.dart                     startup, asset and preferences loading
  content/curriculum.dart       content model and validation
  data/local_store.dart         storage abstraction and preferences adapter
  state/learning_controller.dart profiles, progress, scoring and persistence
  ui/app.dart                   theme, app shell and shared UI helpers
  ui/screens/                   home, profiles, lessons, results and parents
assets/content/curriculum.json  versioned Portuguese starter curriculum
android/                        generated Android project and local-only backup rules
test/                           content, persistence, scoring and widget checks
integration_test/               real Android preferences and offline lesson flow
scripts/                        session tooling and verification helpers
docs/                           specification, architecture, acceptance and build report
.github/workflows/verify.yml     continuous verification and APK artifact
tool/render_previews.dart        optional actual-screen preview renderer
```

## Content editing

Edit `assets/content/curriculum.json`. Keep stable lesson IDs, `schemaVersion: 1`, `language: pt-MZ`, valid zero-based answers and unique choices. Each lesson has a title, objective, introduction, subject, level and exercise list. Run tests after editing. Changing the question count of a lesson with saved results requires a migration; do not silently reinterpret previous scores.

See [architecture and data contracts](docs/ARCHITECTURE.md) for storage details and [Build 01 scope](docs/BUILD_01_SPEC.md) for curriculum, design and deferred work.

## Screen previews

Actual Flutter renders are available in [docs/previews](docs/previews). To regenerate them after changing the UI:

```text
flutter test tool/render_previews.dart
```

Set `FLUTTER_ROOT` to your SDK path first. This optional renderer loads local Flutter SDK fonts and writes PNG previews; it does not require an Android device.

