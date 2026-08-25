import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'presentation/controllers/casa_controller.dart';
import 'presentation/screens/home_screen.dart';
import 'presentation/theme/cici_theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(
    ChangeNotifierProvider(
      create: (_) => CasaController(),
      child: const CiciApp(),
    ),
  );
}

/// App principal Cici — Automação Residencial Inteligente.
class CiciApp extends StatelessWidget {
  const CiciApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Cici — Casa Inteligente',
      debugShowCheckedModeBanner: false,
      theme: CiciTheme.darkTheme,
      home: const HomeScreen(),
    );
  }
}
