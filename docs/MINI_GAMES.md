# Mini-games — 0.4.0 (build 6)

Access: choose a child profile, then tap **Brincar e aprender** on the home screen.

The first interactive milestone provides three game modes and six four-round adventures:
- **Contar e recolher**: tap objects into a basket, tap collected objects to return them, then verify the requested quantity. Three packs cover 1–4, 5–8 and up to ten.
- **Construir palavras**: drag syllable pieces into ordered slots, or tap pieces to place them. Tap a filled slot to return its piece. Two packs cover eight familiar words; each round includes a distractor.
- **Combinar formas**: drag the matching shape onto an outline, or select a shape and tap the outline. Four rounds cover circle, triangle, square and rectangle.

Piu, a locally drawn bird guide, gives instructions, gentle retry hints and a brief success animation. Basket changes animate gently. Android reduced-animation preferences are honoured. Ouvir/Parar uses the existing offline Portuguese voice support for instructions and hints. Each adventure has a clear completion screen and a pause option; there are no timed rounds or automatic next sessions.

These 24 interactive rounds adapt six existing lessons in the 200-activity library, rather than increasing its activity count. Original lesson IDs, question counts and stored profiles/results remain compatible. The first verification of each round determines its score; retries remain available until it is solved. Completion celebrates effort and successful practice. A finished adventure records one attempt against its matching lesson; replays retain the existing best score and do not duplicate stars. Incomplete adventures are not saved/resumable.

Save failure leaves the result available for retry. A pause/back confirmation explains that unfinished practice is discarded. Speech stops when moving on, leaving the screen or backgrounding the app. New rounds return the board to the top of the page.

Checks: formatting and analysis; 49 automated tests including all previous content/progress/read-aloud checks and 10 new game checks. The new checks cover real word/shape drag gestures, tap alternatives, wrong-count correction, a complete saved/reloaded adventure, first-verification scoring, failed-save retry, pause cancellation and all six packs on small phones/tablets with enlarged text and reduced motion. Actual Flutter screenshots include the menu and all three modes.

Phone acceptance:
1. Install over 0.3.0 without uninstalling and verify profiles/stars remain.
2. Open Brincar e aprender; try all three game modes in airplane mode.
3. Try dragging and tapping, an incorrect answer, removing/reordering an item, and a retry.
4. Finish a four-round adventure, reopen the app and check the matching lesson's saved result.
5. Try Ouvir/Parar and Android reduced-animation settings.
6. Let a child play with an adult and observe whether instructions, pieces and pause controls are understandable.

Native touch feel, audible read-aloud and child usability still need a real-phone check. APKs remain locally test-signed prototypes; educator review of content remains pending.
