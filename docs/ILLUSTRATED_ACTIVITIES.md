# Illustrated activities milestone — included in 0.3.0 (build 5)

The app contains **100 Portuguese activities and 100 maths activities**, including the original 24 per subject. This adds 152 activities in 38 lessons, for 50 lessons total. Each lesson still has four challenges; levels contain 9, 8 and 8 lessons per subject.

Portuguese covers initial letters/vowels, joining syllables, missing vowels, syllable counting, picture-word matching, articles, plurals, sentence completion, actions, positions and six short illustrated stories. Story questions offer an expandable text reminder.

Maths covers counting to ten, sequences, comparisons, shapes, addition, subtraction, numbers to twenty, patterns, word problems, tens and units, length comparisons and meticais. Diagrams use exact quantities; subtraction crosses out removed objects. Each currency illustration represents one metical as explained in the activity.

Pictures combine bundled storybook art, native emoji illustrations and deterministic Flutter drawings. Mangoes, coins, shapes and measurement blocks are drawn directly so they do not depend on newer emoji support. Other object pictures use the phone's offline emoji font; appearance varies by Android version. Original activities retain their existing visual presentation. This is an illustrated question library, not 200 separately generated paintings or new game modes.

The reading illustration was edited with the built-in image-generation tool: the open book now faces the children. The asset remains at assets/images/reading.png; the prompt is recorded in VISUAL_UPDATE.md. Original generated files were preserved.

Stable lesson IDs and four-question counts for the original 12 lessons remain unchanged. A regression test loads a Build 01 profile/result into the expanded curriculum and confirms its stars and score survive. New visual metadata is optional and validated; no saved-state migration is required.

Validation includes content counts, numerical illustration/answer agreement, invalid visual rejection, saved-progress compatibility, a complete new illustrated quiz, and all 200 exercise picture layouts at small-phone width with enlarged text. Actual app previews include Portuguese and maths activities.

Phone acceptance:
- Install over the current app without uninstalling. Check profiles and stars.
- With airplane mode enabled, open new activities in each subject and each level.
- Check object pictures render on the phone, then complete a new lesson and relaunch.
- Try a story's 'Ver a história' reminder and shape/pattern choices.

The user approved the previous visual build. This expanded library still needs a phone check and educator review. Read-aloud support was implemented after the activity library, and is included in the combined build; see READ_ALOUD.md.
