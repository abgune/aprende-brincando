part of '../app.dart';

class LessonScreen extends StatefulWidget {
  const LessonScreen({
    super.key,
    required this.controller,
    required this.lesson,
  });
  final LearningController controller;
  final Lesson lesson;
  @override
  State<LessonScreen> createState() => _LessonScreenState();
}

class _LessonScreenState extends State<LessonScreen> {
  bool started = false,
      finished = false,
      saved = false,
      saving = false,
      saveFailed = false;
  int index = 0, correct = 0;
  int? selected;

  Future<void> finish() async {
    setState(() {
      finished = true;
      saving = true;
      saveFailed = false;
    });
    final success = await saveAction(
      context,
      () => widget.controller.recordResult(widget.lesson, correct),
    );
    if (mounted) {
      setState(() {
        saved = success;
        saving = false;
        saveFailed = !success;
      });
    }
  }

  Future<bool> confirmExit() async {
    if (!started || saved) return true;
    if (saving) return false;
    return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Sair da lição?'),
            content: Text(
              finished
                  ? 'O resultado ainda não foi guardado.'
                  : 'Este desafio ainda não terminou. O progresso desta tentativa não será guardado.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Continuar'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Sair'),
              ),
            ],
          ),
        ) ??
        false;
  }

  @override
  Widget build(BuildContext context) {
    final lesson = widget.lesson;
    final exercise = lesson.exercises[index];
    return PopScope(
      canPop: !started || saved,
      onPopInvokedWithResult: (didPop, result) async {
        if (!didPop && await confirmExit() && context.mounted) {
          setState(() {
            started = false;
          });
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (context.mounted) Navigator.of(context).pop();
          });
        }
      },
      child: Scaffold(
        appBar: AppBar(title: Text(lesson.title)),
        body: PageBody(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (!started) ...[
                Surface(
                  color: subjectColor(lesson.subject).withValues(alpha: .10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ScenePicture(subject: lesson.subject, height: 160),
                      const SizedBox(height: 20),
                      Text(
                        lesson.title,
                        style: const TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        lesson.introduction,
                        style: const TextStyle(fontSize: 20, height: 1.6),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Lê com calma. Pede ajuda a um adulto se precisares.',
                  style: TextStyle(height: 1.5),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: () => setState(() => started = true),
                    child: const Text('Começar os desafios'),
                  ),
                ),
              ] else if (finished) ...[
                Surface(
                  child: Column(
                    children: [
                      const Icon(
                        Icons.celebration_rounded,
                        color: Color(0xFFE4A530),
                        size: 68,
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        'Boa descoberta!',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 18),
                      Stars(
                        count: LessonProgress.starsFor(
                          correct,
                          lesson.exercises.length,
                        ),
                        size: 48,
                      ),
                      const SizedBox(height: 18),
                      Text(
                        '$correct de ${lesson.exercises.length} respostas certas',
                        style: const TextStyle(fontSize: 20),
                      ),
                      const SizedBox(height: 14),
                      const Text(
                        'Praticar ajuda a aprender. Podes voltar quando quiseres.',
                        textAlign: TextAlign.center,
                        style: TextStyle(height: 1.5),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        saving
                            ? 'A guardar o teu progresso…'
                            : saved
                            ? 'Progresso guardado neste dispositivo.'
                            : 'O resultado ainda não foi guardado.',
                        textAlign: TextAlign.center,
                      ),
                      if (saving)
                        const Padding(
                          padding: EdgeInsets.all(16),
                          child: CircularProgressIndicator(),
                        ),
                      if (saveFailed)
                        Padding(
                          padding: const EdgeInsets.only(top: 16),
                          child: FilledButton(
                            onPressed: finish,
                            child: const Text('Tentar guardar novamente'),
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                if (saved)
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Voltar às lições'),
                    ),
                  ),
              ] else ...[
                Text(
                  'DESAFIO ${index + 1} DE ${lesson.exercises.length}',
                  style: TextStyle(
                    color: subjectColor(lesson.subject),
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1,
                  ),
                ),
                const SizedBox(height: 12),
                Semantics(
                  label: 'Progresso do desafio',
                  child: LinearProgressIndicator(
                    value: (index + 1) / lesson.exercises.length,
                    borderRadius: BorderRadius.circular(8),
                    minHeight: 8,
                    color: subjectColor(lesson.subject),
                  ),
                ),
                const SizedBox(height: 28),
                Text(
                  exercise.prompt,
                  style: const TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w800,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 16),
                ExercisePicture(lesson: lesson, index: index),
                const SizedBox(height: 16),
                for (var choice = 0; choice < exercise.choices.length; choice++)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: SizedBox(
                      width: double.infinity,
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.all(20),
                          alignment: Alignment.centerLeft,
                          backgroundColor: selected == choice
                              ? subjectColor(
                                  lesson.subject,
                                ).withValues(alpha: .12)
                              : Colors.white,
                          foregroundColor: ink,
                          disabledForegroundColor: ink,
                          side: BorderSide(
                            color: selected == choice
                                ? subjectColor(lesson.subject)
                                : ink.withValues(alpha: .12),
                            width: selected == choice ? 2 : 1,
                          ),
                        ),
                        onPressed: selected != null
                            ? null
                            : () => setState(() {
                                selected = choice;
                                if (choice == exercise.answer) correct++;
                              }),
                        child: Row(
                          children: [
                            ChoicePicture(label: exercise.choices[choice]),
                            Expanded(
                              child: Text(
                                exercise.choices[choice],
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                if (selected != null) ...[
                  const SizedBox(height: 10),
                  Semantics(
                    liveRegion: true,
                    child: Surface(
                      color: selected == exercise.answer
                          ? const Color(0xFFE0F2E9)
                          : const Color(0xFFFFF1D7),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            selected == exercise.answer
                                ? 'Muito bem!'
                                : 'Vamos aprender juntos.',
                            style: const TextStyle(
                              fontSize: 19,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            exercise.explanation,
                            style: const TextStyle(fontSize: 17, height: 1.5),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: () {
                        if (index + 1 == lesson.exercises.length) {
                          finish();
                        } else {
                          setState(() {
                            index++;
                            selected = null;
                          });
                        }
                      },
                      child: Text(
                        index + 1 == lesson.exercises.length
                            ? 'Ver resultado'
                            : 'Próximo desafio',
                      ),
                    ),
                  ),
                ],
              ],
            ],
          ),
        ),
      ),
    );
  }
}
