import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../models/dispositivo_inteligente.dart';
import '../../models/lampada.dart';
import '../../models/sensor.dart';
import '../../models/termostato.dart';
import '../theme/cici_theme.dart';

/// Card visual de um dispositivo inteligente no grid do dashboard.
///
/// Exibe ícone, nome, estado (toggle), e informação contextual
/// (brilho para lâmpadas, temperatura para termostatos, leitura para sensores).
class DeviceCard extends StatelessWidget {
  final DispositivoInteligente dispositivo;
  final VoidCallback onTap;
  final VoidCallback onToggle;

  const DeviceCard({
    super.key,
    required this.dispositivo,
    required this.onTap,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    final ligado = dispositivo.ligado;
    final cor = _corDispositivo;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        decoration: BoxDecoration(
          color: ligado
              ? cor.withValues(alpha: 0.12)
              : CiciTheme.cardDark,
          borderRadius: CiciTheme.radiusXl,
          border: Border.all(
            color: ligado
                ? cor.withValues(alpha: 0.4)
                : CiciTheme.glassBorder,
            width: ligado ? 1.5 : 0.5,
          ),
          boxShadow: ligado
              ? [
                  BoxShadow(
                    color: cor.withValues(alpha: 0.2),
                    blurRadius: 16,
                    spreadRadius: 1,
                  )
                ]
              : CiciTheme.cardShadow,
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header: ícone + toggle
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Ícone do dispositivo
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: ligado
                          ? cor.withValues(alpha: 0.2)
                          : CiciTheme.surfaceDark,
                      borderRadius: CiciTheme.radiusMd,
                    ),
                    child: Icon(
                      _icone,
                      color: ligado ? cor : CiciTheme.textMuted,
                      size: 24,
                    ),
                  ),
                  // Toggle switch
                  Transform.scale(
                    scale: 0.8,
                    child: Switch(
                      value: ligado,
                      onChanged: (_) => onToggle(),
                    ),
                  ),
                ],
              ),

              const Spacer(),

              // Nome do dispositivo
              Text(
                dispositivo.nome,
                style: CiciTheme.bodyLg.copyWith(
                  fontWeight: FontWeight.w600,
                  color: ligado
                      ? CiciTheme.textPrimary
                      : CiciTheme.textMuted,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),

              // Info contextual
              Text(
                _infoContextual,
                style: CiciTheme.bodySm.copyWith(
                  color: ligado
                      ? cor.withValues(alpha: 0.8)
                      : CiciTheme.textMuted,
                ),
              ),

              // Cômodo
              const SizedBox(height: 4),
              Row(
                children: [
                  Icon(
                    Icons.room_outlined,
                    size: 12,
                    color: CiciTheme.textMuted,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    dispositivo.comodo ?? 'N/D',
                    style: CiciTheme.bodySm,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    ).animate().fadeIn(duration: 400.ms).scale(
          begin: const Offset(0.95, 0.95),
          end: const Offset(1, 1),
          duration: 400.ms,
          curve: Curves.easeOut,
        );
  }

  /// Cor temática por tipo de dispositivo.
  Color get _corDispositivo {
    if (dispositivo is Lampada) return CiciTheme.lampadaColor;
    if (dispositivo is Termostato) return CiciTheme.termostatoColor;
    if (dispositivo is Sensor) {
      final sensor = dispositivo as Sensor;
      return sensor.emAlerta ? CiciTheme.dangerRed : CiciTheme.sensorColor;
    }
    return CiciTheme.primaryBlue;
  }

  /// Ícone por tipo de dispositivo.
  IconData get _icone {
    if (dispositivo is Lampada) return Icons.lightbulb_outline_rounded;
    if (dispositivo is Termostato) return Icons.thermostat_rounded;
    if (dispositivo is Sensor) {
      final sensor = dispositivo as Sensor;
      switch (sensor.tipo) {
        case TipoSensor.temperatura:
          return Icons.device_thermostat_rounded;
        case TipoSensor.umidade:
          return Icons.water_drop_outlined;
        case TipoSensor.movimento:
          return Icons.directions_walk_rounded;
        case TipoSensor.fumaca:
          return Icons.local_fire_department_outlined;
        case TipoSensor.luminosidade:
          return Icons.wb_sunny_outlined;
      }
    }
    return Icons.devices_other_rounded;
  }

  /// Informação contextual por tipo de dispositivo.
  String get _infoContextual {
    if (dispositivo is Lampada) {
      final l = dispositivo as Lampada;
      return dispositivo.ligado
          ? 'Brilho: ${l.brilho}%'
          : 'Desligada';
    }
    if (dispositivo is Termostato) {
      final t = dispositivo as Termostato;
      return dispositivo.ligado
          ? '${t.temperaturaAlvo}°C • ${t.modo.rotulo}'
          : 'Desligado';
    }
    if (dispositivo is Sensor) {
      final s = dispositivo as Sensor;
      if (s.emAlerta) return '⚠️ ALERTA: ${s.leituraFormatada}';
      return s.ligado ? s.leituraFormatada : 'Desligado';
    }
    return dispositivo.ligado ? 'Ligado' : 'Desligado';
  }
}
