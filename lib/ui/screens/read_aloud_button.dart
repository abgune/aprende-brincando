part of '../app.dart';

class ReadAloudButton extends StatelessWidget {
  const ReadAloudButton({
    super.key,
    required this.reader,
    required this.readingKey,
    required this.text,
  });
  final ReadAloudController reader;
  final String readingKey, text;
  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: reader,
    builder: (context, _) => Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        OutlinedButton.icon(
          icon: Icon(
            reader.activeId != null && reader.activeKey == readingKey
                ? Icons.stop_circle_rounded
                : Icons.volume_up_rounded,
          ),
          label: Text(
            reader.preparing
                ? 'A preparar a voz…'
                : reader.activeId != null && reader.activeKey == readingKey
                ? 'Parar'
                : 'Ouvir',
          ),
          onPressed: reader.preparing
              ? null
              : () => reader.toggle(readingKey, text),
        ),
        if (reader.error != null)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Semantics(
              liveRegion: true,
              child: Text(
                reader.error!,
                style: const TextStyle(fontSize: 14, height: 1.5),
              ),
            ),
          ),
      ],
    ),
  );
}
