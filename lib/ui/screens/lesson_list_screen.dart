part of '../app.dart';

class LessonListScreen extends StatefulWidget {
  const LessonListScreen({
    super.key,
    required this.controller,
    required this.subject,
  });
  final LearningController controller;
  final String subject;
  @override
  State<LessonListScreen> createState() => _LessonListScreenState();
}

class _LessonListScreenState extends State<LessonListScreen> {
  int level = 1;
  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: widget.controller,
    builder: (context, _) => Scaffold(
      appBar: AppBar(title: Text(subjectName(widget.subject))),
      body: PageBody(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ScenePicture(subject: widget.subject, height: 150),
            const SizedBox(height: 16),
            Text(
              widget.subject == 'portuguese'
                  ? 'Uma palavra de cada vez.'
                  : 'Vamos descobrir os números.',
              style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 12),
            const Text(
              'Começa onde te sentires confortável. Todos os níveis estão disponíveis.',
              style: TextStyle(height: 1.5),
            ),
            const SizedBox(height: 20),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (var value = 1; value <= 3; value++)
                  ChoiceChip(
                    label: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Text('Nível $value'),
                    ),
                    selected: level == value,
                    onSelected: (_) => setState(() => level = value),
                  ),
              ],
            ),
            const SizedBox(height: 22),
            for (final lesson in widget.controller.curriculum.lessons.where(
              (l) => l.subject == widget.subject && l.level == level,
            ))
              Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Surface(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            subjectIcon(widget.subject),
                            color: subjectColor(widget.subject),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              lesson.title,
                              style: const TextStyle(
                                fontSize: 21,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      LessonBadge(lesson: lesson),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Stars(
                            count:
                                widget.controller.progress(lesson.id)?.stars ??
                                0,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              '${lesson.exercises.length} desafios',
                              style: const TextStyle(fontSize: 12),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton(
                          style: FilledButton.styleFrom(
                            backgroundColor: subjectColor(widget.subject),
                          ),
                          onPressed: () => Navigator.of(context).push(
                            MaterialPageRoute<void>(
                              builder: (_) => LessonScreen(
                                controller: widget.controller,
                                lesson: lesson,
                              ),
                            ),
                          ),
                          child: Text(
                            widget.controller.progress(lesson.id) == null
                                ? 'Explorar'
                                : 'Praticar outra vez',
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    ),
  );
}
