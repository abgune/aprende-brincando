part of '../app.dart';

class ParentGate extends StatefulWidget {
  const ParentGate({super.key});
  @override
  State<ParentGate> createState() => _ParentGateState();
}

class _ParentGateState extends State<ParentGate> {
  final answer = TextEditingController();
  late final int left = 12 + Random().nextInt(8),
      right = 8 + Random().nextInt(8);
  bool wrong = false;
  @override
  void dispose() {
    answer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: const Text('Área dos pais'),
    content: Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Pede a um adulto para resolver:'),
        const SizedBox(height: 16),
        Text(
          '$left + $right = ?',
          style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: answer,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            labelText: 'Resposta',
            errorText: wrong ? 'Tente novamente.' : null,
          ),
        ),
      ],
    ),
    actions: [
      TextButton(
        onPressed: () => Navigator.pop(context, false),
        child: const Text('Cancelar'),
      ),
      FilledButton(
        onPressed: () {
          if (int.tryParse(answer.text.trim()) == left + right) {
            Navigator.pop(context, true);
          } else {
            setState(() => wrong = true);
          }
        },
        child: const Text('Entrar'),
      ),
    ],
  );
}

class ParentScreen extends StatelessWidget {
  const ParentScreen({super.key, required this.controller});
  final LearningController controller;
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Acompanhar a aprendizagem')),
    body: PageBody(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Cada criança tem o seu ritmo.',
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 14),
          const Text(
            'Estes resultados mostram a prática no aplicativo. Não substituem uma avaliação escolar.',
            style: TextStyle(height: 1.5),
          ),
          const SizedBox(height: 22),
          if (controller.profiles.isEmpty)
            const Surface(
              child: Text(
                'Crie um perfil para começar a acompanhar o progresso.',
              ),
            ),
          for (final profile in controller.profiles)
            Padding(
              padding: const EdgeInsets.only(bottom: 18),
              child: Surface(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(child: Icon(avatarIcons[profile.avatar])),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            '${profile.name} · ${profile.age} anos',
                            style: const TextStyle(
                              fontSize: 21,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),
                    Text(
                      '${controller.progressFor(profile.id).length} de ${controller.curriculum.lessons.length} lições terminadas',
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 10),
                    LinearProgressIndicator(
                      value:
                          controller.progressFor(profile.id).length /
                          controller.curriculum.lessons.length,
                      minHeight: 8,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    const SizedBox(height: 20),
                    if (controller.progressFor(profile.id).isEmpty)
                      const Text(
                        'Ainda sem lições terminadas. Experimentem uma lição juntos.',
                      ),
                    for (final subject in ['portuguese', 'math']) ...[
                      Text(
                        subjectName(subject),
                        style: TextStyle(
                          color: subjectColor(subject),
                          fontSize: 17,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 6),
                      for (final lesson in controller.curriculum.lessons.where(
                        (l) =>
                            l.subject == subject &&
                            controller
                                .progressFor(profile.id)
                                .containsKey(l.id),
                      ))
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                lesson.title,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(height: 5),
                              Text(
                                'Melhor resultado: ${controller.progressFor(profile.id)[lesson.id]!.bestCorrect}/${lesson.exercises.length} · Tentativas: ${controller.progressFor(profile.id)[lesson.id]!.attempts}',
                                style: const TextStyle(fontSize: 13),
                              ),
                              Stars(
                                count: controller
                                    .progressFor(profile.id)[lesson.id]!
                                    .stars,
                              ),
                            ],
                          ),
                        ),
                      const SizedBox(height: 10),
                    ],
                  ],
                ),
              ),
            ),
          Surface(
            color: const Color(0xFFE7F0F6),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Sobre este protótipo',
                  style: TextStyle(fontSize: 19, fontWeight: FontWeight.w800),
                ),
                SizedBox(height: 12),
                Text(
                  '${controller.curriculum.lessons.length} lições, ${controller.curriculum.lessons.fold<int>(0, (total, lesson) => total + lesson.exercises.length)} desafios e três níveis. O conteúdo introdutório ainda precisa de revisão por educadores em Moçambique.\n\nOs nomes e resultados ficam neste dispositivo. Não há contas online, publicidade ou compras. Se os dados do aplicativo forem apagados ou o aplicativo for desinstalado, o progresso pode perder-se.',
                  style: TextStyle(height: 1.6),
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}
