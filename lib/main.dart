import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'content/curriculum.dart';
import 'data/local_store.dart';
import 'state/learning_controller.dart';
import 'ui/app.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const Bootstrap());
}

class Bootstrap extends StatefulWidget {
  const Bootstrap({super.key});
  @override
  State<Bootstrap> createState() => _BootstrapState();
}

class _BootstrapState extends State<Bootstrap> {
  LearningController? controller;
  Object? error;
  @override
  void initState() {
    super.initState();
    initialize();
  }

  Future<void> initialize() async {
    setState(() => error = null);
    LearningController? next;
    try {
      final curriculum = await Curriculum.load();
      final preferences = await SharedPreferences.getInstance();
      next = LearningController(
        curriculum: curriculum,
        store: PreferencesStore(preferences),
      );
      await next.load();
      if (!mounted) {
        next.dispose();
        return;
      }
      setState(() => controller = next);
    } catch (e) {
      next?.dispose();
      if (mounted) setState(() => error = e);
    }
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (controller != null) return LearningApp(controller: controller!);
    return MaterialApp(
      theme: appTheme,
      home: Scaffold(
        body: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: error == null
                  ? const CircularProgressIndicator()
                  : Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.cloud_off_rounded, size: 56),
                        const SizedBox(height: 20),
                        const Text(
                          'Não foi possível abrir os dados locais.',
                          textAlign: TextAlign.center,
                        ),
                        const Text(
                          'Os dados foram preservados. Tente novamente ou consulte a documentação de recuperação.',
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 20),
                        FilledButton(
                          onPressed: initialize,
                          child: const Text('Tentar novamente'),
                        ),
                      ],
                    ),
            ),
          ),
        ),
      ),
    );
  }
}
