# Architecture and data contract

## Runtime flow

`main.dart` → bundled `Curriculum.load()` + local preferences → `LearningController.load()` → `LearningApp` → profile/home/lesson/parent screens.

The app has no backend. Flutter `ChangeNotifier` keeps the UI up to date; standard `Navigator` routes handle screen transitions. `LocalStore` isolates storage so tests can use an in-memory or failing adapter. Production uses `shared_preferences` with a versioned serialized JSON key, `aprende_brincando.state.v1`.

## Curriculum contract

```json
{
  "schemaVersion": 1,
  "language": "pt-MZ",
  "contentVersion": "0.1.0",
  "reviewStatus": "prototype-awaiting-mozambican-educator-review",
  "lessons": [{
    "id": "pt-1-vogais",
    "subject": "portuguese",
    "level": 1,
    "title": "As cinco vogais",
    "objective": "Reconhecer as vogais em palavras familiares.",
    "introduction": "As vogais são A, E, I, O e U.",
    "exercises": [{
      "prompt": "Qual destas letras é uma vogal?",
      "choices": ["B", "A", "M"],
      "answer": 1,
      "explanation": "A é uma vogal."
    }]
  }]
}
```

`answer` is zero-based. IDs must be unique, subject must be `portuguese` or `math`, level must be 1–3, and exercises must have 2–4 distinct nonempty choices and a valid answer index. Invalid bundled data stops startup with a retry screen. Unknown schema/language versions are rejected.

## Persisted state

The root object stores `schemaVersion`, `profiles`, `activeId` and `progress`. Each profile contains `id`, `name`, `age`, and `avatar` (0–3). `progress` maps child ID → lesson ID → `bestCorrect`, `total`, `attempts`, `lastPlayed` (UTC ISO 8601). Names are trimmed and limited to 24 characters. Age is 5–8. UI creates at most eight profiles.

Every mutation builds a candidate snapshot, writes it, then replaces in-memory state. A failing write leaves the previous state intact. Buttons prevent overlapping saves. Replays increment attempts and retain the maximum score. Partial attempts live only in the lesson screen. Startup validates saved profiles and lesson references; a changed curriculum with incompatible question counts requires an explicit migration rather than silent reinterpretation.

Preferences are appropriate for this small prototype, but they are not a database, encrypted storage or a crash-proof transactional system. A later production build should introduce migrations and stronger persistence before adding downloadable curriculum or school-scale records.

## Offline and privacy boundaries

The release manifest requests no internet, camera, microphone, contacts or location permission. Debug/profile builds include Flutter's generated internet permission for debugging. Lesson runtime does not call a network API. Android backup and device transfer of app files/preferences are excluded. Names and practice results remain app-private on the device, without encryption beyond platform protections. Clearing data or uninstalling can erase progress.

The parent gate uses a new random addition question on each opening. It avoids accidental access but is not a password or security boundary. The app has no payment or account-management actions behind the gate.

## Recovery

Do not overwrite malformed saved data. Startup keeps it and offers retry. A developer can retrieve app-private preferences on a debuggable test install using Android debugging tools, preserve a copy, and repair or migrate the JSON. On a real family's install, first obtain consent and back up any recoverable data. Clearing app data is destructive and should be a last resort, not an automatic recovery path.
