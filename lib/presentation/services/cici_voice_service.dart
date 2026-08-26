import 'dart:html' as html;
import 'package:flutter/foundation.dart';

/// Serviço de reconhecimento de voz nativo do navegador para o Cici AI Hub.
///
/// Gerencia a Web Speech API para detecção de comandos de voz e da palavra
/// de ativação (wake word) "Cici".
class CiciVoiceService {
  html.SpeechRecognition? _recognition;
  bool _isListening = false;

  /// Retorna se o serviço está ouvindo ativamente.
  bool get isListening => _isListening;

  /// Retorna se o navegador atual suporta reconhecimento de voz nativo.
  bool get isSupported {
    if (!kIsWeb) return false;
    return html.SpeechRecognition.supported;
  }

  /// Inicializa e inicia o reconhecimento de voz.
  ///
  /// - [onResult]: Callback disparado quando o navegador traduz a fala em texto.
  /// - [onEnd]: Callback disparado quando a escuta é encerrada.
  /// - [onError]: Callback disparado em caso de falha de permissão ou rede.
  /// - [continuous]: Se `true`, a Cici fica em modo "Sempre Ouvindo".
  void startListening({
    required Function(String text, bool isFinal) onResult,
    required VoidCallback onEnd,
    required Function(String error) onError,
    bool continuous = false,
  }) {
    if (!isSupported) {
      onError('Reconhecimento de voz não suportado neste navegador. Use o Chrome ou Edge.');
      return;
    }

    try {
      // Parar qualquer instância anterior ativa
      stopListening();

      _recognition = html.SpeechRecognition()
        ..continuous = continuous
        ..interimResults = true // Capturar resultados provisórios para escuta rápida
        ..lang = 'pt-BR';

      _recognition!.onResult.listen((html.SpeechRecognitionEvent event) {
        final results = event.results;
        if (results != null && results.isNotEmpty) {
          final lastResult = results.last;
          final text = lastResult.first.transcript;
          final isFinal = lastResult.isFinal ?? true;

          if (text != null && text.trim().isNotEmpty) {
            onResult(text, isFinal);
          }
        }
      });

      _recognition!.onEnd.listen((_) {
        _isListening = false;
        onEnd();
      });

      _recognition!.onError.listen((html.SpeechRecognitionError event) {
        _isListening = false;
        if (event.error != 'no-speech') {
          onError('Erro de voz: ${event.error}');
        }
      });

      _recognition!.start();
      _isListening = true;
    } catch (e) {
      _isListening = false;
      onError('Erro ao iniciar microfone: $e');
    }
  }

  /// Para a escuta do microfone.
  void stopListening() {
    try {
      _recognition?.stop();
    } catch (_) {}
    _isListening = false;
  }
}
