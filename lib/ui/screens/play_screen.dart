part of '../app.dart';

class PlayScreen extends StatefulWidget {
  const PlayScreen({
    super.key,
    required this.controller,
    required this.pack,
    this.speechBackend,
  });
  final LearningController controller;
  final MiniGamePack pack;
  final SpeechBackend? speechBackend;
  @override
  State<PlayScreen> createState() => _PlayScreenState();
}

class _PlayScreenState extends State<PlayScreen> with WidgetsBindingObserver {
  final boardScroll = ScrollController();
  late final Lesson lesson;
  late final ReadAloudController reader;
  late MiniGameRound round;
  int index = 0, correct = 0;
  bool tried = false,
      solved = false,
      finished = false,
      saved = false,
      saving = false,
      allowExit = false;
  String? hint;
  Set<int> collected = {};
  List<int?> slots = [];
  String? selectedShape;
  @override
  void initState() {
    super.initState();
    lesson = widget.pack.lesson(widget.controller.curriculum);
    reader = ReadAloudController(backend: widget.speechBackend);
    WidgetsBinding.instance.addObserver(this);
    resetRound();
  }

  void resetRound() {
    round = MiniGameRound.fromExercise(
      widget.pack.kind,
      lesson.exercises[index],
      index + lesson.id.hashCode,
    );
    collected = {};
    slots = List.filled(round.slots, null);
    selectedShape = null;
    tried = false;
    solved = false;
    hint = null;
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state != AppLifecycleState.resumed) unawaited(reader.stop());
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    reader.dispose();
    boardScroll.dispose();
    super.dispose();
  }

  String get instruction => switch (widget.pack.kind) {
    MiniGameKind.collect => 'Põe ${round.quantity} objectos no cesto.',
    MiniGameKind.words => 'Junta as partes para formar ${round.target}.',
    MiniGameKind.shapes => 'Leva a forma igual para o contorno.',
  };
  void check(bool matches) {
    if (solved || finished) return;
    unawaited(reader.stop());
    setState(() {
      if (!tried && matches) correct++;
      tried = true;
      solved = matches;
      hint = matches
          ? 'Conseguiste! Cada tentativa ajuda a aprender.'
          : switch (widget.pack.kind) {
              MiniGameKind.collect =>
                'Vamos contar juntos. Podes tirar objectos do cesto e tentar de novo.',
              MiniGameKind.words =>
                'Diz a palavra devagar. Toca numa peça para a mudar e tenta de novo.',
              MiniGameKind.shapes =>
                'Olha para os lados e os cantos. Experimenta outra forma.',
            };
    });
  }

  void placeTile(int tile, int slot) {
    if (solved || slots.contains(tile) || slots[slot] != null) return;
    setState(() {
      slots[slot] = tile;
      hint = null;
    });
  }

  Future<void> finish() async {
    if (saving || saved) return;
    unawaited(reader.stop());
    setState(() {
      finished = true;
      saving = true;
    });
    if (boardScroll.hasClients) boardScroll.jumpTo(0);
    final success = await saveAction(
      context,
      () => widget.controller.recordResult(lesson, correct),
    );
    if (mounted) {
      setState(() {
        saving = false;
        saved = success;
      });
    }
  }

  Future<void> leave() async {
    unawaited(reader.stop());
    if (saving) return;
    final go =
        saved ||
        await showDialog<bool>(
              context: context,
              builder: (context) => AlertDialog(
                title: const Text('Fazer uma pausa?'),
                content: Text(
                  finished
                      ? 'A prática ainda não foi guardada.'
                      : 'Esta aventura ainda não terminou. Podes voltar e começar de novo.',
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context, false),
                    child: const Text('Continuar'),
                  ),
                  TextButton(
                    onPressed: () => Navigator.pop(context, true),
                    child: const Text('Fazer uma pausa'),
                  ),
                ],
              ),
            ) ==
            true;
    if (go && mounted) {
      setState(() => allowExit = true);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) Navigator.pop(context);
      });
    }
  }

  @override
  Widget build(BuildContext context) => PopScope(
    canPop: saved || allowExit,
    onPopInvokedWithResult: (didPop, result) {
      if (!didPop) unawaited(leave());
    },
    child: Scaffold(
      appBar: AppBar(title: Text(widget.pack.title)),
      body: PageBody(
        scrollController: boardScroll,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Surface(
              color: solved || finished
                  ? const Color(0xFFE1F5EB)
                  : const Color(0xFFFFE9AE),
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  PiuGuide(happy: solved || finished),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Text(
                      finished
                          ? 'Boa aventura! Fizeste os quatro desafios.'
                          : hint ?? instruction,
                      style: const TextStyle(
                        fontSize: 19,
                        fontWeight: FontWeight.w700,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            if (finished) ...[
              const Surface(
                child: Column(
                  children: [
                    Icon(
                      Icons.celebration_rounded,
                      size: 64,
                      color: Color(0xFFE4A530),
                    ),
                    SizedBox(height: 14),
                    Text(
                      'Tentaste e conseguiste!',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    SizedBox(height: 12),
                    Text(
                      'Agora podes descansar ou escolher outra aventura.',
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              if (saving)
                const Center(child: CircularProgressIndicator())
              else if (!saved)
                FilledButton(
                  onPressed: finish,
                  child: const Text('Tentar guardar novamente'),
                )
              else
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Terminar a aventura'),
                  ),
                ),
            ] else ...[
              Text(
                'Desafio ${index + 1} de ${lesson.exercises.length}',
                style: const TextStyle(fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 8),
              LinearProgressIndicator(
                value: (index + (solved ? 1 : 0)) / lesson.exercises.length,
                minHeight: 8,
                borderRadius: BorderRadius.circular(8),
              ),
              const SizedBox(height: 12),
              ReadAloudButton(
                reader: reader,
                readingKey: 'game-$index',
                text: hint ?? instruction,
              ),
              const SizedBox(height: 16),
              if (widget.pack.kind == MiniGameKind.collect) collectBoard(),
              if (widget.pack.kind == MiniGameKind.words) wordBoard(),
              if (widget.pack.kind == MiniGameKind.shapes) shapeBoard(),
              const SizedBox(height: 18),
              if (!solved && widget.pack.kind != MiniGameKind.shapes)
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed:
                        widget.pack.kind == MiniGameKind.words &&
                            slots.any((s) => s == null)
                        ? null
                        : () => check(
                            widget.pack.kind == MiniGameKind.collect
                                ? collected.length == round.quantity
                                : round.wordMatches(slots),
                          ),
                    child: const Text('Verificar'),
                  ),
                ),
              if (solved) ...[
                Semantics(
                  liveRegion: true,
                  child: const Text(
                    'Muito bem! Desafio resolvido.',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: green,
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: () {
                      unawaited(reader.stop());
                      if (index + 1 == lesson.exercises.length) {
                        unawaited(finish());
                      } else {
                        setState(() {
                          index++;
                          resetRound();
                        });
                        if (boardScroll.hasClients) boardScroll.jumpTo(0);
                      }
                    },
                    child: Text(
                      index + 1 == lesson.exercises.length
                          ? 'Concluir aventura'
                          : 'Próximo desafio',
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 14),
              TextButton(
                onPressed: leave,
                child: const Text('Fazer uma pausa'),
              ),
            ],
          ],
        ),
      ),
    ),
  );
  Widget collectBoard() => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        'Toca para recolher. Precisas de ${round.quantity}.',
        style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w700),
      ),
      const SizedBox(height: 12),
      Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          for (var i = 0; i < round.quantity + 2; i++)
            SizedBox(
              width: 64,
              height: 64,
              child: OutlinedButton(
                key: ValueKey('collect-$i'),
                style: OutlinedButton.styleFrom(
                  padding: EdgeInsets.zero,
                  backgroundColor: Colors.white,
                ),
                onPressed: solved || collected.contains(i)
                    ? null
                    : () => setState(() {
                        collected.add(i);
                        hint = null;
                      }),
                child: Semantics(
                  label: 'Recolher objecto ${i + 1}',
                  child: collected.contains(i)
                      ? const Icon(Icons.check_rounded, color: green)
                      : PictureToken(token: round.token, size: 36),
                ),
              ),
            ),
        ],
      ),
      const SizedBox(height: 18),
      Surface(
        color: const Color(0xFFFFF0CC),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.shopping_basket_rounded,
                  size: 40,
                  color: Color(0xFFB57931),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'No cesto: ${collected.length}',
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            AnimatedSize(
              duration: MediaQuery.disableAnimationsOf(context)
                  ? Duration.zero
                  : const Duration(milliseconds: 220),
              child: Wrap(
                spacing: 6,
                runSpacing: 6,
                children: [
                  for (final i in collected)
                    SizedBox(
                      width: 54,
                      height: 54,
                      child: IconButton(
                        key: ValueKey('return-$i'),
                        tooltip: 'Tirar objecto do cesto',
                        onPressed: solved
                            ? null
                            : () => setState(() {
                                collected.remove(i);
                                hint = null;
                              }),
                        icon: PictureToken(token: round.token, size: 32),
                      ),
                    ),
                ],
              ),
            ),
            if (collected.isEmpty) const Text('O cesto está vazio.'),
          ],
        ),
      ),
    ],
  );
  Widget wordTile(int tile) => Container(
    width: 70,
    height: 60,
    alignment: Alignment.center,
    decoration: BoxDecoration(
      color: const Color(0xFFDDF1ED),
      border: Border.all(color: green, width: 2),
      borderRadius: BorderRadius.circular(14),
    ),
    child: Text(
      round.tiles[tile],
      style: const TextStyle(fontSize: 23, fontWeight: FontWeight.w800),
    ),
  );
  Widget wordBoard() => Column(
    children: [
      Center(child: PictureToken(token: round.token, size: 88)),
      const SizedBox(height: 16),
      const Text(
        'Arrasta as peças ou toca nelas.',
        style: TextStyle(fontSize: 17),
      ),
      const SizedBox(height: 14),
      Wrap(
        spacing: 10,
        runSpacing: 10,
        children: [
          for (var slot = 0; slot < slots.length; slot++)
            DragTarget<int>(
              onWillAcceptWithDetails: (details) =>
                  !solved &&
                  !slots.contains(details.data) &&
                  slots[slot] == null,
              onAcceptWithDetails: (details) => placeTile(details.data, slot),
              builder: (_, candidates, _) => Semantics(
                label: 'Espaço ${slot + 1}',
                button: true,
                child: InkWell(
                  key: ValueKey('slot-$slot'),
                  onTap: solved || slots[slot] == null
                      ? null
                      : () => setState(() {
                          slots[slot] = null;
                          hint = null;
                        }),
                  child: Container(
                    width: 78,
                    height: 68,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: candidates.isNotEmpty
                          ? const Color(0xFFFFDF8C)
                          : Colors.white,
                      border: Border.all(color: green, width: 2),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: slots[slot] == null
                        ? const Icon(Icons.add_rounded, color: green)
                        : Text(
                            round.tiles[slots[slot]!],
                            style: const TextStyle(
                              fontSize: 23,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                  ),
                ),
              ),
            ),
        ],
      ),
      const SizedBox(height: 22),
      Wrap(
        spacing: 10,
        runSpacing: 10,
        children: [
          for (var tile = 0; tile < round.tiles.length; tile++)
            if (!slots.contains(tile))
              Draggable<int>(
                data: tile,
                maxSimultaneousDrags: solved ? 0 : 1,
                feedback: Material(
                  color: Colors.transparent,
                  child: wordTile(tile),
                ),
                childWhenDragging: Opacity(opacity: .3, child: wordTile(tile)),
                child: Semantics(
                  button: true,
                  label: 'Peça ${round.tiles[tile]}',
                  child: InkWell(
                    key: ValueKey('tile-$tile'),
                    onTap: solved || !slots.contains(null)
                        ? null
                        : () => placeTile(tile, slots.indexOf(null)),
                    child: wordTile(tile),
                  ),
                ),
              ),
        ],
      ),
    ],
  );
  Widget shapeBoard() => Column(
    children: [
      const Text(
        'Arrasta uma forma. Ou toca na forma e depois no contorno.',
        style: TextStyle(fontSize: 17, height: 1.4),
      ),
      const SizedBox(height: 14),
      DragTarget<String>(
        onWillAcceptWithDetails: (_) => !solved,
        onAcceptWithDetails: (d) => check(d.data == round.target),
        builder: (_, candidates, _) => InkWell(
          key: const ValueKey('shape-target'),
          onTap: solved || selectedShape == null
              ? null
              : () => check(selectedShape == round.target),
          child: Semantics(
            label: 'Contorno de ${round.target}',
            button: true,
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: candidates.isNotEmpty
                    ? const Color(0xFFFFDF8C)
                    : Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              child: ShapeOutline(name: round.target),
            ),
          ),
        ),
      ),
      const SizedBox(height: 20),
      Wrap(
        spacing: 12,
        runSpacing: 12,
        children: [
          for (final shape in round.tiles)
            Draggable<String>(
              data: shape,
              maxSimultaneousDrags: solved ? 0 : 1,
              feedback: Material(
                color: Colors.transparent,
                child: ShapePicture(shape: gameShape(shape)),
              ),
              child: Semantics(
                label: shape,
                button: true,
                selected: selectedShape == shape,
                child: InkWell(
                  key: ValueKey('shape-$shape'),
                  onTap: solved
                      ? null
                      : () => setState(() => selectedShape = shape),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(
                        color: selectedShape == shape
                            ? purple
                            : Colors.transparent,
                        width: 3,
                      ),
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: ShapePicture(shape: gameShape(shape)),
                  ),
                ),
              ),
            ),
        ],
      ),
    ],
  );
}
