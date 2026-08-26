import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../theme/cici_theme.dart';

/// O anel de luz azul concêntrico pulsante da Alexa (Cici AI Hub).
///
/// Apresenta animações de pulsação e brilho (glow) que se adaptam
/// conforme o estado do assistente (ocioso ou processando comando).
class AlexaRing extends StatelessWidget {
  /// Indica se a Cici está ativamente processando uma mensagem ou falando.
  final bool isProcessing;

  const AlexaRing({
    super.key,
    required this.isProcessing,
  });

  @override
  Widget build(BuildContext context) {
    final corPrincipal = isProcessing ? CiciTheme.accentCyan : CiciTheme.primaryBlue;
    final corSecundaria = isProcessing ? CiciTheme.primaryBlue : CiciTheme.accentCyan;

    return Center(
      child: Stack(
        alignment: Alignment.center,
        children: [
          // 1. Halo Externo com blur e brilho (Glow Pulsante)
          Container(
            width: 140,
            height: 140,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  corPrincipal.withOpacity(0.4),
                  corSecundaria.withOpacity(0.0),
                ],
                stops: const [0.5, 1.0],
              ),
            ),
          )
              .animate(
                onPlay: (controller) => controller.repeat(reverse: true),
              )
              .scale(
                begin: const Offset(0.85, 0.85),
                end: const Offset(1.2, 1.2),
                duration: isProcessing ? 800.ms : 2000.ms,
                curve: Curves.easeInOut,
              ),

          // 2. Halo Intermediário
          Container(
            width: 110,
            height: 110,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: corPrincipal.withOpacity(0.35),
                width: 4,
              ),
            ),
          )
              .animate(
                onPlay: (controller) => controller.repeat(reverse: true),
              )
              .scale(
                begin: const Offset(0.9, 0.9),
                end: const Offset(1.1, 1.1),
                duration: isProcessing ? 600.ms : 1500.ms,
                curve: Curves.easeInOut,
              ),

          // 3. Anel de Luz nítido central
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: SweepGradient(
                colors: [
                  corPrincipal,
                  corSecundaria,
                  corPrincipal.withOpacity(0.3),
                  corPrincipal,
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: corPrincipal.withOpacity(0.6),
                  blurRadius: 20,
                  spreadRadius: 2,
                ),
              ],
            ),
          )
              .animate(
                onPlay: (controller) => controller.repeat(reverse: false),
              )
              .rotate(
                duration: isProcessing ? 1500.ms : 4000.ms,
                curve: Curves.linear,
              ),

          // 4. Orb Central (Espaço oco escuro)
          Container(
            width: 72,
            height: 72,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: CiciTheme.backgroundDark,
            ),
            child: Icon(
              isProcessing ? Icons.graphic_eq_rounded : Icons.mic_rounded,
              color: corPrincipal,
              size: 28,
            )
                .animate(
                  onPlay: (controller) => controller.repeat(reverse: true),
                )
                .fadeIn(duration: 800.ms),
          ),
        ],
      ),
    );
  }
}
