# Build 01 acceptance checks

Automated check results and build status are recorded in `BUILD_REPORT.md`. The Android integration test is provided separately; it requires a device/emulator.

| Behaviour | Verification |
|---|---|
| First launch offers profile creation | Widget test creates a profile through the UI |
| Names, ages and symbols are valid | Controller validation tests |
| Profiles and results reload locally | Controller restart and preferences-adapter tests |
| Each child has separate results | Controller profile-switch test |
| Content includes three levels and both subjects | JSON validation tests, 12 lessons/48 exercises |
| Invalid content and duplicate IDs/options rejected | Content parser tests |
| Lessons provide teaching and feedback | Full-quiz and incorrect-answer widget tests |
| An answer can score only once | UI disables all options after selection |
| Unfinished exit asks and gives no reward | Exit-confirmation widget test |
| Repeating keeps best score without duplicate stars | Controller replay test |
| Failed saves preserve previous state and permit retry | Failing-store tests |
| Corrupt or unsupported state is not overwritten | Startup/controller tests |
| Parent gate requires correct displayed answer | Gate widget test |
| Small phone/tablet layouts support larger text | 320×640 and 800×1024 widget checks at 1.3× text |
| Android build produces installable package | Debug APK compile |
| Actual Android storage survives reopening | Device integration test plus manual cold-start check |

## Device test instructions

Use a dedicated test phone or emulator. The integration test temporarily replaces the current preferences key and restores its original value afterward; interruption during a test can prevent restoration. Do not use a family's live installation.

1. Connect an Android phone with developer options and USB debugging enabled, or start an Android emulator.
2. Run `flutter devices` and choose its device ID.
3. Install and launch: `flutter run -d DEVICE_ID`.
4. Create two nicknames; finish a Portuguese lesson as one child and a maths lesson as the other.
5. Turn on airplane mode and repeat both lesson flows. Expect all introductions, choices and feedback to work.
6. Force-stop the app, reopen it, and verify active profile, stars and both children's separate progress.
7. Replay a lesson with a lower score: best result must stay unchanged; attempts must increase.
8. Cancel an unfinished lesson and reopen it: no partial reward or attempt should be recorded.
9. Open the parent gate; verify wrong-answer rejection and correct-answer access; return to child mode and reopen to require a fresh gate.
10. Run `flutter test integration_test/offline_learning_test.dart -d DEVICE_ID` while offline after build dependencies are cached.
11. Check 320px-class screens, large font settings, screen reader labels, rotation and older/low-memory Android devices. Capture any overflow or performance issue.

The automated integration test reloads the storage controller inside one process. It does not replace a manual force-stop/relaunch test, OS-level low-storage test, or physical-device accessibility review.

## Release checks still required

Educator review, testing with children/adults, real-device performance/memory profiling, Android backup behaviour verification, production signing, publisher identity, store privacy disclosures and any school-pilot requirements are required before broader deployment. The APK in Build 01 is a debug prototype, not a store release.
