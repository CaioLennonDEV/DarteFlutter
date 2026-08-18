import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import 'core/constants/app_strings.dart';
import 'core/constants/app_theme.dart';
import 'core/services/local_storage_service.dart';
import 'data/datasources/note_local_datasource.dart';
import 'data/repositories/note_repository_impl.dart';
import 'domain/models/note_model.dart';
import 'domain/repositories/note_repository.dart';
import 'presentation/controllers/notes_controller.dart';
import 'presentation/controllers/theme_controller.dart';
import 'presentation/views/home/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Configure Global Error Logging to Console & Screen
  FlutterError.onError = (FlutterErrorDetails details) {
    debugPrint('🚨 [NotaIA FlutterError]: ${details.exceptionAsString()}');
    debugPrint('${details.stack}');
  };

  PlatformDispatcher.instance.onError = (error, stack) {
    debugPrint('🚨 [NotaIA UncaughtError]: $error');
    debugPrint('$stack');
    return true;
  };

  // Custom Error Widget so it NEVER renders a blank gray screen
  ErrorWidget.builder = (FlutterErrorDetails details) {
    return Material(
      color: const Color(0xFF0F172A),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.error_outline, color: Colors.redAccent, size: 28),
                    SizedBox(width: 10),
                    Text(
                      'Ops! Ocorreu um erro:',
                      style: TextStyle(color: Colors.redAccent, fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.black45,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.redAccent.withOpacity(0.4)),
                  ),
                  child: Text(
                    details.exceptionAsString(),
                    style: const TextStyle(color: Colors.white, fontSize: 13, fontFamily: 'monospace'),
                  ),
                ),
                const SizedBox(height: 16),
                const Text('Stack Trace:', style: TextStyle(color: Colors.grey, fontSize: 12)),
                const SizedBox(height: 6),
                Text(
                  details.stack.toString(),
                  style: const TextStyle(color: Colors.grey, fontSize: 11, fontFamily: 'monospace'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  };

  // Initialize Date Formatting for pt_BR
  try {
    await initializeDateFormatting('pt_BR', null);
  } catch (e) {
    debugPrint('Erro ao inicializar locale pt_BR: $e');
  }

  // Initialize 100% Local NoSQL Persistence (Hive + SharedPreferences)
  await LocalStorageService.init();

  // Create repository instance
  final localDataSource = NoteLocalDataSourceImpl();
  final noteRepository = NoteRepositoryImpl(localDataSource: localDataSource);

  // Populate initial sample notes if empty for immediate exploration
  await _seedInitialDataIfEmpty(noteRepository);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeController()),
        ChangeNotifierProvider(
          create: (_) => NotesController(repository: noteRepository),
        ),
      ],
      child: const NotaIAApp(),
    ),
  );
}

Future<void> _seedInitialDataIfEmpty(NoteRepository repository) async {
  try {
    final existingNotes = await repository.getAllNotes();
    if (existingNotes.isEmpty) {
      final now = DateTime.now();

      final welcomeNote = NoteModel(
        id: const Uuid().v4(),
        title: '✨ Bem-vindo ao NotaIA!',
        content:
            'O NotaIA é seu assistente moderno para anotações rápidas e inteligentes.\n\n'
            'Principais recursos inclusos:\n'
            '• 🎙️ Gravação de áudio com transcrição e resumo IA\n'
            '• 🎨 Quadro de desenho e rascunhos à mão (Doodles)\n'
            '• 🔤 Seleção de fontes personalizadas e tamanhos\n'
            '• 🏷️ Ícones/Emojis de destaque estilo Notion\n'
            '• 💾 Persistência 100% local com Hive NoSQL\n'
            '• 🌙 Suporte completo a Dark/Light Mode e Docker Web',
        createdAt: now,
        updatedAt: now,
        isPinned: true,
        colorIndex: 3,
        categoryId: 'ideias',
        emoji: '🧠',
        fontFamily: 'Inter',
        tags: ['BoasVindas', 'NotaIA', 'Dicas'],
        aiSummary: '✨ Aplicativo de anotações inteligente com áudio, desenho, persistência local NoSQL e IA.',
      );

      final workNote = NoteModel(
        id: const Uuid().v4(),
        title: '🚀 Alinhamento de Sprint & DevOps',
        content:
            'Pontos discutidos na reunião de arquitetura:\n'
            '1. Validar Dockerfile multi-stage com Nginx Alpine\n'
            '2. Testar persistência local em navegadores e mobile\n'
            '3. Configurar gravação de áudio e canvas de desenho\n'
            '4. Publicar repositório no GitHub com .gitignore limpo',
        createdAt: now.subtract(const Duration(hours: 2)),
        updatedAt: now.subtract(const Duration(hours: 2)),
        isPinned: false,
        colorIndex: 2,
        categoryId: 'trabalho',
        emoji: '🚀',
        fontFamily: 'Playfair Display',
        tags: ['DevOps', 'Docker', 'Sprint'],
      );

      final ideasNote = NoteModel(
        id: const Uuid().v4(),
        title: '💡 Ideias para Próximos Recursos',
        content:
            'Explorar no futuro:\n'
            '- Sincronização P2P criptografada\n'
            '- Exportação em Markdown e PDF com um clique\n'
            '- Reconhecimento de voz em tempo real',
        createdAt: now.subtract(const Duration(days: 1)),
        updatedAt: now.subtract(const Duration(days: 1)),
        isPinned: false,
        colorIndex: 1,
        categoryId: 'ideias',
        emoji: '💡',
        fontFamily: 'Fira Code',
        tags: ['Inovação', 'Roadmap'],
      );

      await repository.saveNote(welcomeNote);
      await repository.saveNote(workNote);
      await repository.saveNote(ideasNote);
    }
  } catch (e, stack) {
    debugPrint('🚨 [NotaIA Seed Error]: $e\n$stack');
  }
}

class NotaIAApp extends StatelessWidget {
  const NotaIAApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeController = context.watch<ThemeController>();

    return MaterialApp(
      title: AppStrings.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeController.themeMode,
      home: const HomeScreen(),
    );
  }
}
