# Read-aloud milestone — 0.3.0 (build 5)

The combined update contains the corrected book illustration, 100 Portuguese and 100 maths activities, and read-aloud support.

Tap **Ouvir** to hear a lesson introduction, a question with all its choices, or feedback after answering. Tap **Parar** to stop. Story questions include the story in their spoken text. Maths operators and gaps are converted into Portuguese words. Playback stops when starting/advancing a lesson, leaving the screen, or backgrounding the app. There is no automatic playback.

This implementation uses Android's installed text-to-speech engine. It only selects Portuguese voices marked as offline and installed, preferring a Mozambique voice when available, then Portugal, then another Portuguese voice. It does not download a voice or use an online speech service. Voice availability, quality and accent depend on the phone. This is device speech synthesis, not bundled studio narration or a guaranteed Mozambican recording.

If no offline Portuguese voice is installed, the app shows an adult-help message. An adult can open the phone's text-to-speech settings, select its speech engine and install Portuguese voice data where supported. The names and locations of these settings differ by phone. After setup, reopen the app and test Ouvir in airplane mode. If the phone's engine offers no offline Portuguese voice, the picture and text activities remain usable.

Android platform references: [TextToSpeech](https://developer.android.com/reference/android/speech/tts/TextToSpeech) and [Voice network requirements](https://developer.android.com/reference/android/speech/tts/Voice#isNetworkConnectionRequired()). The app declares the TTS service visibility query and retains its release manifest without an Internet permission.

Checks: formatting and analysis; 39 automated tests covering content, progress retention, visual quantity/answer agreement, phone layouts, speech unavailable/error/retry, stop/completion handling, stale callbacks, cancellation during preparation, spoken operators, and a real lesson UI with a fake speech backend. Phone screenshots are rendered from the Flutter app. The native Android implementation is compiled into both ARM packages.

Not verified here: audible playback through an actual Android engine, missing-voice behaviour on a real phone, its Portuguese pronunciation, background/return behaviour and airplane-mode playback. No phone or emulator is connected. These require the user's device check; automated speech tests use a fake engine.

Phone acceptance:
1. Install over the previous app and confirm profiles/stars remain.
2. Open a lesson and tap Ouvir, then Parar.
3. Start challenges; hear the question and all choices. Choose an answer and hear the explanation.
4. Advance or leave while speech plays; confirm it stops. Background the app and confirm it stops.
5. Repeat in airplane mode with a Portuguese voice installed.
6. Check the expanded subject lists: 25 lessons and 100 activities in each subject.

All APKs remain locally test-signed prototype builds; curriculum still awaits educator review.
