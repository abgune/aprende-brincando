part of '../app.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key, required this.controller});
  final LearningController controller;

  void openProfiles(BuildContext context) => Navigator.of(context).push(
    MaterialPageRoute<void>(
      builder: (_) => ProfileScreen(controller: controller),
    ),
  );
  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: controller,
    builder: (context, _) {
      final profile = controller.active;
      final completed = profile == null
          ? 0
          : controller.progressFor(profile.id).length;
      return Scaffold(
        appBar: AppBar(
          title: const Text(
            'Aprende Brincando',
            style: TextStyle(fontSize: 19, fontWeight: FontWeight.w800),
          ),
          actions: [
            IconButton(
              tooltip: 'Área dos pais',
              onPressed: () async {
                final unlocked = await showDialog<bool>(
                  context: context,
                  builder: (_) => const ParentGate(),
                );
                if (unlocked == true && context.mounted) {
                  Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => ParentScreen(controller: controller),
                    ),
                  );
                }
              },
              icon: const Icon(Icons.family_restroom_rounded),
            ),
            const SizedBox(width: 8),
          ],
        ),
        body: PageBody(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.offline_bolt_rounded,
                    color: green,
                    size: 20,
                  ),
                  const SizedBox(width: 7),
                  const Expanded(
                    child: Text(
                      'Pronto para aprender sem internet',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 22),
              if (profile != null) ...[
                Semantics(
                  button: true,
                  label: 'Mudar perfil. ${profile.name}',
                  child: InkWell(
                    borderRadius: BorderRadius.circular(16),
                    onTap: () => openProfiles(context),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 24,
                            backgroundColor: green.withValues(alpha: .12),
                            child: Icon(
                              avatarIcons[profile.avatar],
                              color: green,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Olá, ${profile.name}!',
                              style: const TextStyle(
                                fontSize: 23,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                          const Icon(Icons.swap_horiz_rounded),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 18),
              ],
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(26),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(28),
                  gradient: const LinearGradient(
                    colors: [Color(0xFF123E52), Color(0xFF157E73)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(
                          Icons.auto_awesome_rounded,
                          color: Color(0xFFFFD47D),
                          size: 28,
                        ),
                        SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'PEQUENOS PASSOS, GRANDES DESCOBERTAS',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),
                    Text(
                      profile == null
                          ? 'Aprender pode ser\numa aventura.'
                          : 'O que vamos\ndescobrir hoje?',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 30,
                        fontWeight: FontWeight.w800,
                        height: 1.15,
                      ),
                    ),
                    const SizedBox(height: 14),
                    const Text(
                      'Ler, contar e experimentar.\nAo teu ritmo, onde estiveres.',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        height: 1.5,
                      ),
                    ),
                    if (profile == null) ...[
                      const SizedBox(height: 22),
                      FilledButton(
                        style: FilledButton.styleFrom(
                          backgroundColor: const Color(0xFFFFD47D),
                          foregroundColor: ink,
                        ),
                        onPressed: () => openProfiles(context),
                        child: const Text('Criar o meu perfil'),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 20),
              if (profile != null) ...[
                Surface(
                  padding: const EdgeInsets.all(18),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.star_rounded,
                        color: Color(0xFFE4A530),
                        size: 32,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          '${controller.stars} estrelas\n$completed de ${controller.curriculum.lessons.length} lições terminadas',
                          style: const TextStyle(
                            fontSize: 15,
                            height: 1.5,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 26),
                const Text(
                  'Escolhe uma aventura',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 14),
                for (final subject in ['portuguese', 'math']) ...[
                  SubjectCard(
                    subject: subject,
                    completed: controller.curriculum.lessons
                        .where(
                          (l) =>
                              l.subject == subject &&
                              controller.progress(l.id) != null,
                        )
                        .length,
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => LessonListScreen(
                          controller: controller,
                          subject: subject,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                ],
                Surface(
                  color: const Color(0xFFFFF1D7),
                  child: const Row(
                    children: [
                      Icon(Icons.favorite_rounded, color: Color(0xFFE59849)),
                      SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Cada tentativa ajuda a aprender. Podes repetir qualquer lição.',
                          style: TextStyle(height: 1.5),
                        ),
                      ),
                    ],
                  ),
                ),
              ] else ...[
                Surface(
                  child: const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Um espaço para cada criança',
                        style: TextStyle(
                          fontSize: 19,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Para crianças dos 5 aos 8 anos. Usa um nome curto ou uma alcunha. O progresso fica neste dispositivo.',
                        style: TextStyle(height: 1.5),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      );
    },
  );
}

class SubjectCard extends StatelessWidget {
  const SubjectCard({
    super.key,
    required this.subject,
    required this.completed,
    required this.onTap,
  });
  final String subject;
  final int completed;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => Semantics(
    button: true,
    child: InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(26),
      child: Surface(
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(17),
              decoration: BoxDecoration(
                color: subjectColor(subject).withValues(alpha: .12),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(
                subjectIcon(subject),
                color: subjectColor(subject),
                size: 32,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    subjectName(subject),
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    subject == 'portuguese'
                        ? 'Letras, palavras e histórias'
                        : 'Números, formas e desafios',
                    style: const TextStyle(fontSize: 14),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '$completed de 6 lições terminadas',
                    style: TextStyle(
                      color: subjectColor(subject),
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_rounded),
          ],
        ),
      ),
    ),
  );
}
