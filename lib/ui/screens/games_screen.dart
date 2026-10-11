part of '../app.dart';

class GamesScreen extends StatelessWidget {
  const GamesScreen({super.key, required this.controller});
  final LearningController controller;
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Brincar e aprender')),
    body: PageBody(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Surface(
            color: Color(0xFFE1F5EB),
            child: Row(
              children: [
                PiuGuide(),
                SizedBox(width: 16),
                Expanded(
                  child: Text(
                    'Olá! Sou o Piu.\nVamos descobrir juntos?',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          for (final kind in MiniGameKind.values) ...[
            Text(
              switch (kind) {
                MiniGameKind.collect => 'Contar e recolher',
                MiniGameKind.words => 'Construir palavras',
                MiniGameKind.shapes => 'Combinar formas',
              },
              style: const TextStyle(fontSize: 23, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 10),
            for (final pack in MiniGamePack.all.where((p) => p.kind == kind))
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    icon: Icon(switch (kind) {
                      MiniGameKind.collect => Icons.shopping_basket_rounded,
                      MiniGameKind.words => Icons.extension_rounded,
                      MiniGameKind.shapes => Icons.category_rounded,
                    }),
                    label: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      child: Text(
                        pack.title,
                        style: const TextStyle(fontSize: 18),
                      ),
                    ),
                    onPressed: () => Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) =>
                            PlayScreen(controller: controller, pack: pack),
                      ),
                    ),
                  ),
                ),
              ),
            const SizedBox(height: 14),
          ],
          const Text(
            'Quatro desafios por aventura. Podes fazer uma pausa quando quiseres.',
            style: TextStyle(height: 1.5),
          ),
        ],
      ),
    ),
  );
}
