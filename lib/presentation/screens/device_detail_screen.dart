import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';

import '../../models/dispositivo_inteligente.dart';
import '../../models/lampada.dart';
import '../../models/sensor.dart';
import '../../models/termostato.dart';
import '../controllers/casa_controller.dart';
import '../theme/cici_theme.dart';
import '../widgets/status_indicator.dart';

/// Tela de detalhe e controle de um dispositivo individual.
///
/// Exibe controles específicos por tipo:
/// - **Lâmpada**: slider de brilho, toggle
/// - **Termostato**: slider de temperatura, seletor de modo
/// - **Sensor**: leitura, botão simular, histórico de alertas
class DeviceDetailScreen extends StatelessWidget {
  final DispositivoInteligente dispositivo;

  const DeviceDetailScreen({super.key, required this.dispositivo});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CiciTheme.backgroundDark,
      appBar: AppBar(
        backgroundColor: CiciTheme.backgroundDark,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(dispositivo.nome, style: CiciTheme.headingSm),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: Consumer<CasaController>(
              builder: (context, controller, _) {
                return StatusIndicator(
                  ligado: dispositivo.ligado,
                  emAlerta: dispositivo is Sensor &&
                      (dispositivo as Sensor).emAlerta,
                  size: 14,
                );
              },
            ),
          ),
        ],
      ),
      body: Consumer<CasaController>(
        builder: (context, controller, _) {
          return SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                // -- Ícone grande animado --
                _buildIconeGrande(),
                const SizedBox(height: 24),

                // -- Toggle Liga/Desliga --
                _buildToggle(controller),
                const SizedBox(height: 24),

                // -- Controles específicos --
                if (dispositivo is Lampada) _buildControleLampada(controller),
                if (dispositivo is Termostato)
                  _buildControleTermostato(controller),
                if (dispositivo is Sensor) _buildControleSensor(controller),

                const SizedBox(height: 24),

                // -- Info do dispositivo --
                _buildInfoCard(),

                const SizedBox(height: 24),

                // -- Logs de auditoria --
                _buildLogsAuditoria(),

                const SizedBox(height: 40),
              ],
            ),
          );
        },
      ),
    );
  }

  // =========================================================================
  // ÍCONE GRANDE ANIMADO
  // =========================================================================

  Widget _buildIconeGrande() {
    final cor = _corDispositivo;
    final ligado = dispositivo.ligado;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 400),
      width: 120,
      height: 120,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: ligado
            ? cor.withValues(alpha: 0.15)
            : CiciTheme.surfaceDark,
        border: Border.all(
          color: ligado
              ? cor.withValues(alpha: 0.5)
              : CiciTheme.glassBorder,
          width: 2,
        ),
        boxShadow: ligado
            ? [
                BoxShadow(
                  color: cor.withValues(alpha: 0.3),
                  blurRadius: 30,
                  spreadRadius: 5,
                ),
              ]
            : null,
      ),
      child: Icon(
        _icone,
        size: 48,
        color: ligado ? cor : CiciTheme.textMuted,
      ),
    ).animate().scale(
          begin: const Offset(0.8, 0.8),
          end: const Offset(1, 1),
          duration: 600.ms,
          curve: Curves.elasticOut,
        );
  }

  // =========================================================================
  // TOGGLE LIGA/DESLIGA
  // =========================================================================

  Widget _buildToggle(CasaController controller) {
    final ligado = dispositivo.ligado;

    return GestureDetector(
      onTap: () => controller.toggleDispositivo(dispositivo),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
        decoration: BoxDecoration(
          color: ligado
              ? CiciTheme.successGreen.withValues(alpha: 0.15)
              : CiciTheme.surfaceDark,
          borderRadius: CiciTheme.radiusFull,
          border: Border.all(
            color: ligado
                ? CiciTheme.successGreen.withValues(alpha: 0.5)
                : CiciTheme.glassBorder,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              ligado ? Icons.power_settings_new_rounded : Icons.power_off_rounded,
              color: ligado ? CiciTheme.successGreen : CiciTheme.textMuted,
              size: 22,
            ),
            const SizedBox(width: 10),
            Text(
              ligado ? 'LIGADO' : 'DESLIGADO',
              style: CiciTheme.labelBold.copyWith(
                color: ligado ? CiciTheme.successGreen : CiciTheme.textMuted,
                letterSpacing: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // =========================================================================
  // CONTROLE: LÂMPADA (BRILHO)
  // =========================================================================

  Widget _buildControleLampada(CasaController controller) {
    final lampada = dispositivo as Lampada;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: CiciTheme.solidCard,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('💡 Controle de Brilho', style: CiciTheme.headingSm),
          const SizedBox(height: 16),

          // Valor central
          Center(
            child: Text(
              '${lampada.brilho}%',
              style: CiciTheme.numberLg.copyWith(
                color: CiciTheme.lampadaColor,
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Slider
          SliderTheme(
            data: SliderThemeData(
              activeTrackColor: CiciTheme.lampadaColor,
              thumbColor: CiciTheme.lampadaColor,
              inactiveTrackColor: CiciTheme.surfaceDark,
              overlayColor: CiciTheme.lampadaColor.withValues(alpha: 0.2),
              trackHeight: 6,
            ),
            child: Slider(
              value: lampada.brilho.toDouble(),
              min: 0,
              max: 100,
              divisions: 20,
              label: '${lampada.brilho}%',
              onChanged: lampada.ligado
                  ? (v) => controller.ajustarBrilho(lampada, v.round())
                  : null,
            ),
          ),

          // Cor atual
          if (lampada.corHex != null) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                Text('Cor: ', style: CiciTheme.bodyMd),
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: _parseHex(lampada.corHex ?? '#FFFFFF'),
                    shape: BoxShape.circle,
                    border: Border.all(color: CiciTheme.glassBorder),
                  ),
                ),
                const SizedBox(width: 8),
                Text(lampada.corHex ?? '', style: CiciTheme.bodySm),
              ],
            ),
          ],

          // Consumo
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(Icons.bolt_rounded,
                  size: 16, color: CiciTheme.warningAmber),
              const SizedBox(width: 6),
              Text(
                'Consumo: ${lampada.consumoAcumuladoKwh.toStringAsFixed(3)} kWh',
                style: CiciTheme.bodyMd,
              ),
            ],
          ),
        ],
      ),
    ).animate().fadeIn(delay: 200.ms, duration: 400.ms);
  }

  // =========================================================================
  // CONTROLE: TERMOSTATO (TEMPERATURA + MODO)
  // =========================================================================

  Widget _buildControleTermostato(CasaController controller) {
    final termostato = dispositivo as Termostato;

    return Column(
      children: [
        // Card de temperatura
        Container(
          padding: const EdgeInsets.all(20),
          decoration: CiciTheme.solidCard,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('🌡️ Controle de Temperatura', style: CiciTheme.headingSm),
              const SizedBox(height: 16),

              // Temperaturas
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildTempDisplay(
                    'Alvo',
                    '${termostato.temperaturaAlvo.toStringAsFixed(1)}°C',
                    CiciTheme.termostatoColor,
                  ),
                  _buildTempDisplay(
                    'Atual',
                    '${termostato.temperaturaAtual.toStringAsFixed(1)}°C',
                    CiciTheme.textSecondary,
                  ),
                  _buildTempDisplay(
                    'Status',
                    termostato.temperaturaEstavel ? '✅ Estável' : '⚠️ Ajustando',
                    termostato.temperaturaEstavel
                        ? CiciTheme.successGreen
                        : CiciTheme.warningAmber,
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Slider
              Slider(
                value: termostato.temperaturaAlvo,
                min: Termostato.temperaturaMinima,
                max: Termostato.temperaturaMaxima,
                divisions: 32,
                label: '${termostato.temperaturaAlvo.toStringAsFixed(1)}°C',
                onChanged: termostato.ligado
                    ? (v) => controller.ajustarTemperatura(
                        termostato, double.parse(v.toStringAsFixed(1)))
                    : null,
              ),

              // Range info
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('${Termostato.temperaturaMinima}°C',
                        style: CiciTheme.bodySm),
                    Text('${Termostato.temperaturaMaxima}°C',
                        style: CiciTheme.bodySm),
                  ],
                ),
              ),

              // Consumo
              const SizedBox(height: 12),
              Row(
                children: [
                  const Icon(Icons.bolt_rounded,
                      size: 16, color: CiciTheme.warningAmber),
                  const SizedBox(width: 6),
                  Text(
                    'Consumo: ${termostato.consumoAcumuladoKwh.toStringAsFixed(3)} kWh',
                    style: CiciTheme.bodyMd,
                  ),
                ],
              ),
            ],
          ),
        ).animate().fadeIn(delay: 200.ms, duration: 400.ms),

        const SizedBox(height: 16),

        // Card de modo
        Container(
          padding: const EdgeInsets.all(20),
          decoration: CiciTheme.solidCard,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('⚙️ Modo de Operação', style: CiciTheme.headingSm),
              const SizedBox(height: 12),
              Row(
                children: ModoTermostato.values.map((modo) {
                  final selecionado = termostato.modo == modo;
                  return Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: GestureDetector(
                        onTap: termostato.ligado
                            ? () => controller.alterarModoTermostato(
                                termostato, modo)
                            : null,
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 250),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color: selecionado
                                ? CiciTheme.primaryBlue.withValues(alpha: 0.2)
                                : CiciTheme.surfaceDark,
                            borderRadius: CiciTheme.radiusMd,
                            border: Border.all(
                              color: selecionado
                                  ? CiciTheme.primaryBlue
                                  : CiciTheme.glassBorder,
                            ),
                          ),
                          child: Center(
                            child: Text(
                              modo.rotulo,
                              style: CiciTheme.bodySm.copyWith(
                                color: selecionado
                                    ? CiciTheme.primaryBlue
                                    : CiciTheme.textMuted,
                                fontWeight: selecionado
                                    ? FontWeight.w600
                                    : FontWeight.normal,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        ).animate().fadeIn(delay: 300.ms, duration: 400.ms),
      ],
    );
  }

  Widget _buildTempDisplay(String label, String value, Color color) {
    return Column(
      children: [
        Text(label, style: CiciTheme.bodySm),
        const SizedBox(height: 4),
        Text(
          value,
          style: CiciTheme.headingSm.copyWith(color: color, fontSize: 16),
        ),
      ],
    );
  }

  // =========================================================================
  // CONTROLE: SENSOR (LEITURA + SIMULAR)
  // =========================================================================

  Widget _buildControleSensor(CasaController controller) {
    final sensor = dispositivo as Sensor;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: CiciTheme.solidCard,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('📡 ${sensor.tipo.rotulo}', style: CiciTheme.headingSm),
              if (sensor.emAlerta)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: CiciTheme.dangerRed.withValues(alpha: 0.2),
                    borderRadius: CiciTheme.radiusFull,
                    border: Border.all(
                        color: CiciTheme.dangerRed.withValues(alpha: 0.5)),
                  ),
                  child: Text(
                    '⚠️ ALERTA',
                    style: CiciTheme.bodySm.copyWith(
                      color: CiciTheme.dangerRed,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 20),

          // Leitura grande
          Center(
            child: Text(
              sensor.leituraFormatada,
              style: CiciTheme.numberLg.copyWith(
                color: sensor.emAlerta
                    ? CiciTheme.dangerRed
                    : CiciTheme.sensorColor,
                fontSize: 42,
              ),
            ),
          ),

          // Limiar
          if (sensor.limiarAlerta != null) ...[
            const SizedBox(height: 8),
            Center(
              child: Text(
                'Limiar de alerta: ${sensor.limiarAlerta?.toStringAsFixed(1)}${sensor.unidade}',
                style: CiciTheme.bodySm,
              ),
            ),
          ],

          const SizedBox(height: 20),

          // Botão simular leitura
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: sensor.ligado
                  ? () {
                      // Gerar leitura aleatória baseada no tipo
                      final random = Random();
                      double valor;
                      switch (sensor.tipo) {
                        case TipoSensor.temperatura:
                          valor = 18.0 + random.nextDouble() * 30;
                        case TipoSensor.umidade:
                          valor = 30.0 + random.nextDouble() * 70;
                        case TipoSensor.fumaca:
                          valor = random.nextDouble() * 80;
                        case TipoSensor.luminosidade:
                          valor = random.nextDouble() * 1000;
                        case TipoSensor.movimento:
                          valor = random.nextBool() ? 1.0 : 0.0;
                      }
                      controller.simularLeituraSensor(sensor, valor);
                    }
                  : null,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Simular Leitura'),
              style: ElevatedButton.styleFrom(
                backgroundColor: CiciTheme.primaryBlue,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: CiciTheme.radiusMd,
                ),
              ),
            ),
          ),
        ],
      ),
    ).animate().fadeIn(delay: 200.ms, duration: 400.ms);
  }

  // =========================================================================
  // INFO CARD
  // =========================================================================

  Widget _buildInfoCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: CiciTheme.solidCard,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('📋 Informações', style: CiciTheme.headingSm),
          const SizedBox(height: 12),
          _infoRow('ID', dispositivo.id),
          _infoRow('Nome', dispositivo.nome),
          _infoRow('Cômodo', dispositivo.comodo ?? 'N/D'),
          _infoRow('Estado', dispositivo.ligado ? 'Ligado' : 'Desligado'),
          _infoRow('Tipo', dispositivo.runtimeType.toString()),
        ],
      ),
    ).animate().fadeIn(delay: 400.ms, duration: 400.ms);
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: CiciTheme.bodyMd),
          Text(value, style: CiciTheme.bodyLg.copyWith(fontSize: 14)),
        ],
      ),
    );
  }

  // =========================================================================
  // LOGS DE AUDITORIA
  // =========================================================================

  Widget _buildLogsAuditoria() {
    // Logs disponíveis apenas para dispositivos com LogAuditoriaMixin
    final logs = _obterLogs();
    if (logs.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: CiciTheme.solidCard,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.history_rounded,
                  color: CiciTheme.textSecondary, size: 20),
              const SizedBox(width: 8),
              Text('Log de Auditoria', style: CiciTheme.headingSm),
            ],
          ),
          const SizedBox(height: 12),
          ...logs.take(10).map(
                (log) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 3),
                  child: Text(
                    log,
                    style: CiciTheme.bodySm.copyWith(
                      fontFamily: 'monospace',
                      fontSize: 11,
                    ),
                  ),
                ),
              ),
        ],
      ),
    ).animate().fadeIn(delay: 500.ms, duration: 400.ms);
  }

  List<String> _obterLogs() {
    if (dispositivo is Lampada) {
      return (dispositivo as Lampada)
          .logs
          .map((l) => l.toString())
          .toList()
          .reversed
          .toList();
    }
    if (dispositivo is Termostato) {
      return (dispositivo as Termostato)
          .logs
          .map((l) => l.toString())
          .toList()
          .reversed
          .toList();
    }
    if (dispositivo is Sensor) {
      return (dispositivo as Sensor)
          .logs
          .map((l) => l.toString())
          .toList()
          .reversed
          .toList();
    }
    return [];
  }

  // =========================================================================
  // HELPERS
  // =========================================================================

  Color get _corDispositivo {
    if (dispositivo is Lampada) return CiciTheme.lampadaColor;
    if (dispositivo is Termostato) return CiciTheme.termostatoColor;
    if (dispositivo is Sensor) {
      return (dispositivo as Sensor).emAlerta
          ? CiciTheme.dangerRed
          : CiciTheme.sensorColor;
    }
    return CiciTheme.primaryBlue;
  }

  IconData get _icone {
    if (dispositivo is Lampada) return Icons.lightbulb_rounded;
    if (dispositivo is Termostato) return Icons.thermostat_rounded;
    if (dispositivo is Sensor) {
      switch ((dispositivo as Sensor).tipo) {
        case TipoSensor.temperatura:
          return Icons.device_thermostat_rounded;
        case TipoSensor.umidade:
          return Icons.water_drop_rounded;
        case TipoSensor.movimento:
          return Icons.directions_walk_rounded;
        case TipoSensor.fumaca:
          return Icons.local_fire_department_rounded;
        case TipoSensor.luminosidade:
          return Icons.wb_sunny_rounded;
      }
    }
    return Icons.devices_other_rounded;
  }

  Color _parseHex(String hex) {
    final clean = hex.replaceAll('#', '');
    if (clean.length == 6) {
      return Color(int.parse('FF$clean', radix: 16));
    }
    return Colors.white;
  }
}
