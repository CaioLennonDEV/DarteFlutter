import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';

import '../../models/lampada.dart';
import '../../models/sensor.dart';
import '../../models/termostato.dart';
import '../controllers/casa_controller.dart';
import '../theme/cici_theme.dart';

/// Tela de alertas e logs de auditoria do sistema Cici.
class AlertsScreen extends StatelessWidget {
  const AlertsScreen({super.key});

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
        title: Text('Alertas & Logs', style: CiciTheme.headingSm),
      ),
      body: Consumer<CasaController>(
        builder: (context, controller, _) {
          final alertas = controller.sensoresEmAlerta;

          return SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── ALERTAS ATIVOS ──
                _buildSecaoTitulo(
                  '🚨 Alertas Ativos',
                  '${alertas.length} alerta${alertas.length != 1 ? "s" : ""}',
                ),
                const SizedBox(height: 12),

                if (alertas.isEmpty)
                  _buildEmptyState(
                    Icons.check_circle_outline_rounded,
                    'Nenhum alerta ativo',
                    'Todos os sensores estão operando normalmente.',
                    CiciTheme.successGreen,
                  )
                else
                  ...alertas.asMap().entries.map((entry) {
                    final i = entry.key;
                    final sensor = entry.value;
                    return _buildAlertCard(sensor, i);
                  }),

                const SizedBox(height: 32),

                // ── RELATÓRIO DO SISTEMA ──
                _buildSecaoTitulo('📊 Relatório do Sistema', ''),
                const SizedBox(height: 12),
                _buildRelatorioCard(controller),

                const SizedBox(height: 32),

                // ── LOG DE AUDITORIA GERAL ──
                _buildSecaoTitulo('📝 Log de Auditoria Geral', ''),
                const SizedBox(height: 12),
                _buildLogsGerais(controller),

                const SizedBox(height: 40),
              ],
            ),
          );
        },
      ),
    );
  }

  // =========================================================================
  // SEÇÃO TÍTULO
  // =========================================================================

  Widget _buildSecaoTitulo(String titulo, String subtitulo) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(titulo, style: CiciTheme.headingSm),
        if (subtitulo.isNotEmpty)
          Text(subtitulo, style: CiciTheme.bodySm),
      ],
    );
  }

  // =========================================================================
  // EMPTY STATE
  // =========================================================================

  Widget _buildEmptyState(
      IconData icon, String titulo, String subtitulo, Color cor) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: cor.withOpacity(0.08),
        borderRadius: CiciTheme.radiusXl,
        border: Border.all(color: cor.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          Icon(icon, size: 40, color: cor),
          const SizedBox(height: 12),
          Text(
            titulo,
            style: CiciTheme.headingSm.copyWith(color: cor),
          ),
          const SizedBox(height: 4),
          Text(subtitulo, style: CiciTheme.bodyMd, textAlign: TextAlign.center),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms);
  }

  // =========================================================================
  // ALERT CARD
  // =========================================================================

  Widget _buildAlertCard(Sensor sensor, int index) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: CiciTheme.dangerRed.withOpacity(0.1),
          borderRadius: CiciTheme.radiusLg,
          border:
              Border.all(color: CiciTheme.dangerRed.withOpacity(0.3)),
        ),
        child: Row(
          children: [
            // Ícone pulsante
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: CiciTheme.dangerRed.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.warning_amber_rounded,
                color: CiciTheme.dangerRed,
                size: 24,
              ),
            ),
            const SizedBox(width: 14),
            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    sensor.nome,
                    style: CiciTheme.bodyLg.copyWith(
                      fontWeight: FontWeight.w600,
                      color: CiciTheme.dangerRed,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${sensor.tipo.rotulo}: ${sensor.leituraFormatada}',
                    style: CiciTheme.bodyMd,
                  ),
                  if (sensor.limiarAlerta != null)
                    Text(
                      'Limiar: ${sensor.limiarAlerta?.toStringAsFixed(1)}${sensor.unidade}',
                      style: CiciTheme.bodySm,
                    ),
                ],
              ),
            ),
            // Cômodo
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: CiciTheme.surfaceDark,
                borderRadius: CiciTheme.radiusFull,
              ),
              child: Text(
                sensor.comodo ?? 'N/D',
                style: CiciTheme.bodySm,
              ),
            ),
          ],
        ),
      ),
    ).animate(delay: (100 * index).ms).fadeIn(duration: 400.ms).slideX(
          begin: 0.1,
          end: 0,
          duration: 400.ms,
        );
  }

  // =========================================================================
  // RELATÓRIO
  // =========================================================================

  Widget _buildRelatorioCard(CasaController controller) {
    final relatorio = controller.gerenciador.gerarRelatorio();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: CiciTheme.solidCard,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: relatorio.map((linha) {
          if (linha.startsWith('╔') ||
              linha.startsWith('╚') ||
              linha.startsWith('║')) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 1),
              child: Text(
                linha,
                style: CiciTheme.bodySm.copyWith(
                  fontFamily: 'monospace',
                  color: CiciTheme.primaryBlue,
                ),
              ),
            );
          }
          if (linha.startsWith('🚨')) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 2),
              child: Text(
                linha,
                style: CiciTheme.bodyMd.copyWith(
                  color: CiciTheme.dangerRed,
                  fontWeight: FontWeight.w600,
                ),
              ),
            );
          }
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 1),
            child: Text(linha, style: CiciTheme.bodySm),
          );
        }).toList(),
      ),
    ).animate().fadeIn(delay: 200.ms, duration: 500.ms);
  }

  // =========================================================================
  // LOGS GERAIS
  // =========================================================================

  Widget _buildLogsGerais(CasaController controller) {
    // Coletar logs de todos os dispositivos
    final todosLogs = <String>[];

    for (final d in controller.gerenciador.dispositivos) {
      if (d is Lampada) {
        todosLogs.addAll(d.logs.map((l) => '💡 ${d.nome}: $l'));
      } else if (d is Termostato) {
        todosLogs.addAll(d.logs.map((l) => '🌡️ ${d.nome}: $l'));
      } else if (d is Sensor) {
        todosLogs.addAll(d.logs.map((l) => '📡 ${d.nome}: $l'));
      }
    }

    if (todosLogs.isEmpty) {
      return _buildEmptyState(
        Icons.history_rounded,
        'Nenhum log registrado',
        'As ações dos dispositivos aparecerão aqui.',
        CiciTheme.textMuted,
      );
    }

    // Mostrar últimos 20 logs (invertidos — mais recente primeiro)
    final logsRecentes = todosLogs.reversed.take(20).toList();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: CiciTheme.solidCard,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: logsRecentes.map((log) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 3),
            child: Text(
              log,
              style: CiciTheme.bodySm.copyWith(
                fontFamily: 'monospace',
                fontSize: 11,
                height: 1.4,
              ),
            ),
          );
        }).toList(),
      ),
    ).animate().fadeIn(delay: 300.ms, duration: 500.ms);
  }
}
