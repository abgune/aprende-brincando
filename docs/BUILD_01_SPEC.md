# Aprende Brincando — agreed Build 01 scope

Decision date: 10 October 2026 (Africa/Maputo).

The original ChatGPT reference exposed assistant-response placeholders, not the approved V0.1 text or code. This implementation follows the replacement scope selected by the user in this chat: **B — complete learning prototype; mixed curriculum; balanced, modern design**. Starter curriculum and code are newly authored for this build, rather than recovered from the unavailable reference.

## Audience and principles

- Children aged 5–8 in Mozambique, Portuguese interface and content.
- Android first; every bundled lesson works without a network connection.
- Short lessons, encouraging explanations, repeatable practice, no ranking or streak pressure.
- No online accounts, advertising, payments, unrestricted chat, telemetry, or subscription flows.
- Device-local profiles and progress; parent summaries distinguish practice from formal assessment.

## Milestones

1. Verify/install Flutter, Dart, Android SDK and Java; generate an Android-only Flutter application.
2. Build onboarding and up to eight child profiles (nickname, age 5–8, one of four symbols), home, profile switching and subject selection.
3. Bundle 12 lessons/48 exercises: six Portuguese and six mathematics lessons, across three progressively harder levels. All levels stay available; age does not automatically gate content.
4. Show lesson introduction, four multiple-choice exercises, one answer per exercise, immediate supportive feedback and explanatory text. Leaving an unfinished attempt asks for confirmation.
5. Save completed attempts atomically at the application level: persist the candidate state before presenting it as saved. Keep each child's best score, attempt count and latest completion timestamp. A failed save can retry.
6. Show 0–3 stars per lesson and a parent overview behind a fresh arithmetic gate. Replaying never decreases the best score or duplicates stars.
7. Format, analyze, run unit/widget tests, compile Android APK, and run a device integration test when an Android target is available. Document validation and outstanding real-device checks.
8. Commit and push to the user-identified repository: `https://github.com/abgune/aprende-brincando`.

## Educational plan

| Level | Portuguese | Mathematics |
|---|---|---|
| 1 — Foundations | Vowels; syllable joining | Counting to 10; shapes |
| 2 — Everyday practice | Familiar words; simple sentences | Addition to 10; subtraction/comparison |
| 3 — Growing confidence | Short-text comprehension; sequencing | Problems to 20 with local examples; patterns/order |

Each lesson has an objective, a teaching introduction and four questions. Correct-answer positions vary. Questions have 2–4 unique options and exactly one indexed answer. All explanations are bundled. The vocabulary uses Mozambican Portuguese forms where practical (for example “acção”, “objectos”, “dezanove”, “meticais”).

**Review status:** prototype material awaiting review by Mozambican educators. No official curriculum alignment, grade accreditation or learning efficacy claim is made. Before a school pilot, obtain source curriculum documents and have educators review language, sequence, difficulty and answers.

## Scoring

- No correct answers: 0 stars.
- At least one correct answer but less than half: 1 star.
- At least half correct but not all: 2 stars.
- Every answer correct: 3 stars.

Completing an attempt counts as a finished lesson, even with zero stars. The parent screen reports the best score and number of completed attempts. Unfinished attempts are not saved or resumable in Build 01.

## Visual and asset requirements

Modern Material 3 interface; light blue-grey canvas, deep blue text, teal Portuguese accents, lavender maths accents, warm gold rewards, rounded cards and generous spacing. Scrollable layouts support phones/tablets, with content width capped at 840 logical pixels. Main action buttons are at least 56 logical pixels high. Choice feedback includes explanatory text so colour is not the only cue.

Assets shipped: local Material icon font, four profile symbols, Android vector launcher icon, and one UTF-8 curriculum JSON. No downloaded images or fonts are required. Recorded Portuguese audio, custom character art and reviewed textbook-derived materials are future assets. Young or emerging readers may need adult help: this version has no narration.

## Deferred scope

Downloadable packs, cloud sync, accounts, subscriptions, school licensing, teacher export, profile editing/deletion, audio narration, local-language support, resumable attempts, production signing, store publishing, and school deployment are outside this build. The arithmetic gate is a child-facing separation mechanism, not authentication.
