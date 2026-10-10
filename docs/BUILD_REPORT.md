# Build 01 execution report

Executed on 10 October 2026, Africa/Maputo, on the user's Windows development environment.

## Completed tooling actions

- Verified existing Git for Windows and Temurin Java 21.0.12.1.
- Installed the official stable Flutter SDK (3.47.7, revision `abaf9c523780a608bd46686fd5e53740a07077f8`) and Dart 3.13.5 in the task workspace's `work/tooling/flutter` directory.
- Repaired the initial SDK checkout by enabling long paths in that SDK repository's local Git configuration. No global Git configuration was changed.
- Downloaded Android command-line tools `16111833` from Google's SDK repository. Checked the archive's repository SHA-1: `57d04f2d75eb8e8fffc5000a987e5de4b5a63e9d`.
- Installed Android platform-tools 37.0.1, Android API 36, build-tools 36.0.0 and NDK 28.2.13676358 in `work/tooling/android-sdk`.
- Configured Flutter to use that SDK and disabled Flutter tool analytics. `flutter doctor -v` reports a passing Android toolchain and accepted Android licences.
- Kept the machine's global PATH unchanged. `scripts/Use-Tooling.ps1` makes the tools available in a PowerShell session. Invoking Flutter without that helper can show a PATH warning; compilation works through the installed SDK.
- Used existing Java rather than installing Android Studio. No emulator was installed, and Android debugging reported no connected devices.

## Completed application actions

- Generated an Android-only Flutter application, package `mz.aprendebrincando.aprende_brincando`, version `0.1.0+1`, minimum Android API 24, target/compile API 36.
- Implemented profiles, switching, modern Material 3 home/subject/level screens, teaching introductions, quizzes, feedback, result stars and parent progress.
- Added bundled UTF-8 Portuguese curriculum JSON: 12 lessons, 48 exercises, two subjects, three levels, explicit educator-review status.
- Implemented versioned device-local storage and per-child progress. Candidate state is persisted before successful UI completion. Best scores are preserved across replays.
- Fixed a profile-ID collision discovered by testing: profiles now receive random 128-bit IDs with a uniqueness check.
- Added local vector launcher artwork, accessibility labels, explanatory feedback and scrollable layouts. Disabled Android backup and excluded stored data from device transfer.
- Wrote README, functional specification, architecture/storage contract, acceptance checklist, verification helpers, CI workflow and seven actual Flutter screen previews.

## Verified checks

| Check | Result |
|---|---|
| Dependency resolution | Passed; `pubspec.lock` committed |
| Formatting | Passed; 17 Dart files, no formatting changes required |
| Flutter analysis | Passed; no issues |
| Unit/widget suite | Passed; 26 tests |
| Screen preview render | Passed; one additional render check; seven PNGs inspected |
| Android debug compilation | Passed; final incremental build completed in 13.9 seconds after the initial dependency-heavy build |
| Debug APK signature | Passed; APK Signature Scheme v2, one test signer |
| Debug package metadata | Verified app label, package ID, version, API 24 minimum/API 36 target and ARM/ARM64/x86_64 ABIs |
| Android real-device integration | Not run; no Android phone or emulator available |

The initial test launch encountered a Windows sandbox temporary-path access failure. Tests subsequently ran successfully with a shorter writable temporary directory and the required execution permissions. Formatting/parser issues found during implementation were fixed before the passing analysis and test runs.

## Android artifacts

The final debug APK is delivered outside the repository in the task's `outputs` folder. Build files, SDKs, caches, local Android paths and signing keys are excluded from Git. Smaller optimized ARM packages are additional prototype artifacts; their final outcome, names, sizes and checksums are listed in the task-level completion report and checksum manifest.

Optimized-package compilation initially encountered stale registration of the development-only integration-test plugin. Generated build files and dependency/plugin metadata were regenerated before the retry. All APKs use a generated test signing key, including any optimized builds; production signing and store publication were not performed.

## Remaining steps and limits

- Android integration test, airplane-mode exercise, cold-start persistence, accessibility and low-memory phone checks require a connected device or emulator. Instructions and an integration test are supplied.
- Curriculum source alignment and educational validation require Mozambican educator review and source materials.
- No Play Store deployment, subscriptions, downloadable packs or school pilot was included in the agreed scope.
- The original prior-chat assistant text remained unavailable. This build follows the user's replacement scope decisions, not an assumed recovered V0.1 specification.

## Git delivery

The user explicitly identified `https://github.com/abgune/aprende-brincando` and authorized the build push through that choice. Its remote was empty at inspection; the project uses `main`. Commit ID, verified remote state and push outcome are recorded in the task-level completion report after delivery.
