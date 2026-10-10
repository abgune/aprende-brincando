part of '../app.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key, required this.controller});
  final LearningController controller;
  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final formKey = GlobalKey<FormState>();
  final name = TextEditingController();
  int age = 6, avatar = 0;
  @override
  void dispose() {
    name.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: widget.controller,
    builder: (context, _) => Scaffold(
      appBar: AppBar(title: const Text('Quem vai aprender?')),
      body: PageBody(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (final profile in widget.controller.profiles)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  minVerticalPadding: 18,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(22),
                  ),
                  tileColor: Colors.white,
                  leading: CircleAvatar(
                    child: Icon(avatarIcons[profile.avatar]),
                  ),
                  title: Text(
                    profile.name,
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                  subtitle: Text('${profile.age} anos'),
                  trailing: profile.id == widget.controller.active?.id
                      ? const Icon(Icons.check_circle_rounded, color: green)
                      : const Icon(Icons.arrow_forward_rounded),
                  onTap: widget.controller.saving
                      ? null
                      : () async {
                          final success = await saveAction(
                            context,
                            () => widget.controller.selectProfile(profile.id),
                          );
                          if (success && context.mounted) {
                            Navigator.of(context).pop();
                          }
                        },
                ),
              ),
            if (widget.controller.profiles.length < 8)
              Surface(
                child: Form(
                  key: formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Criar perfil',
                        style: TextStyle(
                          fontSize: 23,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Escolhe uma alcunha e um símbolo. Tudo fica guardado neste dispositivo.',
                        style: TextStyle(height: 1.5),
                      ),
                      const SizedBox(height: 20),
                      TextFormField(
                        controller: name,
                        maxLength: 24,
                        textCapitalization: TextCapitalization.words,
                        decoration: const InputDecoration(
                          labelText: 'Nome ou alcunha',
                        ),
                        validator: (v) => v == null || v.trim().isEmpty
                            ? 'Escreve um nome curto.'
                            : null,
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'Idade',
                        style: TextStyle(fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        children: [
                          for (final value in [5, 6, 7, 8])
                            ChoiceChip(
                              label: Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 6,
                                ),
                                child: Text('$value anos'),
                              ),
                              selected: age == value,
                              onSelected: (_) => setState(() => age = value),
                            ),
                        ],
                      ),
                      const SizedBox(height: 18),
                      const Text(
                        'O teu símbolo',
                        style: TextStyle(fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 10,
                        runSpacing: 10,
                        children: [
                          for (
                            var index = 0;
                            index < avatarIcons.length;
                            index++
                          )
                            IconButton.filledTonal(
                              isSelected: avatar == index,
                              tooltip: [
                                'Patinhas',
                                'Foguetão',
                                'Flor',
                                'Raio',
                              ][index],
                              style: IconButton.styleFrom(
                                minimumSize: const Size(56, 56),
                                backgroundColor: avatar == index
                                    ? green
                                    : canvas,
                                foregroundColor: avatar == index
                                    ? Colors.white
                                    : ink,
                              ),
                              onPressed: () => setState(() => avatar = index),
                              icon: Icon(avatarIcons[index]),
                            ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton(
                          onPressed: widget.controller.saving
                              ? null
                              : () async {
                                  if (!formKey.currentState!.validate()) return;
                                  final success = await saveAction(
                                    context,
                                    () => widget.controller.addProfile(
                                      name.text,
                                      age,
                                      avatar,
                                    ),
                                  );
                                  if (success && context.mounted) {
                                    Navigator.of(context).pop();
                                  }
                                },
                          child: Text(
                            widget.controller.saving
                                ? 'A guardar…'
                                : 'Vamos aprender',
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              )
            else
              const Text('Já existem oito perfis neste dispositivo.'),
          ],
        ),
      ),
    ),
  );
}
