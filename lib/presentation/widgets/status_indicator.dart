import 'package:flutter/material.dart';

import '../theme/cici_theme.dart';

/// Indicador visual de status (ligado/desligado/alerta).
class StatusIndicator extends StatelessWidget {
  final bool ligado;
  final bool emAlerta;
  final double size;

  const StatusIndicator({
    super.key,
    required this.ligado,
    this.emAlerta = false,
    this.size = 10,
  });

  @override
  Widget build(BuildContext context) {
    final cor = emAlerta
        ? CiciTheme.dangerRed
        : (ligado ? CiciTheme.successGreen : CiciTheme.textMuted);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: cor,
        shape: BoxShape.circle,
        boxShadow: (ligado || emAlerta)
            ? [
                BoxShadow(
                  color: cor.withOpacity(0.6),
                  blurRadius: 8,
                  spreadRadius: 2,
                ),
              ]
            : null,
      ),
    );
  }
}
