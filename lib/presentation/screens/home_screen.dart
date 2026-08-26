import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';

import '../../models/dispositivo_inteligente.dart';
import '../controllers/casa_controller.dart';
import '../theme/cici_theme.dart';
import '../widgets/device_card.dart';
import '../widgets/room_chip.dart';
import '../widgets/stat_card.dart';
import 'alerts_screen.dart';
import 'assistant_screen.dart';
import 'device_detail_screen.dart';

/// Dashboard principal do app Cici — estilo Alexa.
///
/// Exibe resumo, filtro por cômodo e grid de dispositivos.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CiciTheme.backgroundDark,
      body: SafeArea(
        child: Consumer<CasaController>(
          builder: (context, controller, _) {
            // Mostrar snackbar se houver feedback
            _mostrarFeedback(context, controller);

            return CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                // -- HEADER --
                SliverToBoxAdapter(
                  child: _buildHeader(context, controller),
                ),

                // -- STAT CARDS --
                SliverToBoxAdapter(
                  child: _buildStatCards(controller),
                ),

                // -- ROOM FILTER --
                SliverToBoxAdapter(
                  child: _buildRoomFilter(controller),
                ),

                // -- SECTION TITLE --
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Dispositivos', style: CiciTheme.headingSm),
                        Text(
                          '${controller.dispositivosFiltrados.length} itens',
                          style: CiciTheme.bodySm,
                        ),
                      ],
                    ),
                  ),
                ),

                // -- DEVICE GRID --
                _buildDeviceGrid(context, controller),

                // bottom padding
                const SliverToBoxAdapter(
                  child: SizedBox(height: 100),
                ),
              ],
            );
          },
        ),
      ),

      // -- FAB ALERTAS --
      floatingActionButton: Consumer<CasaController>(
        builder: (context, controller, _) {
          return Stack(
            children: [
              FloatingActionButton(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const AlertsScreen(),
                  ),
                ),
                child: const Icon(Icons.notifications_outlined, size: 26),
              ),
              if (controller.existeAlerta)
                Positioned(
                  right: 0,
                  top: 0,
                  child: Container(
                    width: 16,
                    height: 16,
                    decoration: BoxDecoration(
                      color: CiciTheme.dangerRed,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: CiciTheme.backgroundDark,
                        width: 2,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        '${controller.sensoresEmAlerta.length}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ).animate(
                    onPlay: (c) => c.repeat(reverse: true),
                  ).scale(
                    begin: const Offset(1, 1),
                    end: const Offset(1.2, 1.2),
                    duration: 800.ms,
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  // =========================================================================
  // HEADER
  // =========================================================================

  Widget _buildHeader(BuildContext context, CasaController controller) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
      child: Row(
        children: [
          // Logo
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  CiciTheme.primaryBlue,
                  CiciTheme.accentCyan,
                ],
              ),
              borderRadius: CiciTheme.radiusMd,
            ),
            child: const Icon(Icons.home_rounded, color: Colors.white, size: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Cici', style: CiciTheme.headingLg),
                Text(
                  'Casa Inteligente',
                  style: CiciTheme.bodyMd,
                ),
              ],
            ),
          ),
          // Botão Cici AI Hub
          GestureDetector(
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const AssistantScreen(),
              ),
            ),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: CiciTheme.primaryBlue.withOpacity(0.15),
                borderRadius: CiciTheme.radiusMd,
                border: Border.all(color: CiciTheme.primaryBlue.withOpacity(0.4)),
              ),
              child: const Icon(
                Icons.mic_rounded,
                color: CiciTheme.primaryBlueLight,
                size: 22,
              ),
            ),
          ),
          const SizedBox(width: 8),
          // Avatar / settings
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: CiciTheme.surfaceDark,
              borderRadius: CiciTheme.radiusMd,
              border: Border.all(color: CiciTheme.glassBorder),
            ),
            child: const Icon(
              Icons.tune_rounded,
              color: CiciTheme.textSecondary,
              size: 22,
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 500.ms).slideY(
          begin: -0.1,
          end: 0,
          duration: 500.ms,
          curve: Curves.easeOut,
        );
  }

  // =========================================================================
  // STAT CARDS
  // =========================================================================

  Widget _buildStatCards(CasaController controller) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
      child: Row(
        children: [
          Expanded(
            child: StatCard(
              icon: Icons.power_settings_new_rounded,
              label: 'Ligados',
              value: '${controller.totalLigados}/${controller.totalDispositivos}',
              color: CiciTheme.successGreen,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: StatCard(
              icon: Icons.bolt_rounded,
              label: 'Consumo',
              value: '${controller.consumoTotal.toStringAsFixed(2)}',
              color: CiciTheme.warningAmber,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: StatCard(
              icon: Icons.warning_amber_rounded,
              label: 'Alertas',
              value: '${controller.sensoresEmAlerta.length}',
              color: controller.existeAlerta
                  ? CiciTheme.dangerRed
                  : CiciTheme.textMuted,
            ),
          ),
        ],
      ),
    ).animate().fadeIn(delay: 200.ms, duration: 500.ms);
  }

  // =========================================================================
  // ROOM FILTER
  // =========================================================================

  Widget _buildRoomFilter(CasaController controller) {
    final comodos = controller.comodos;

    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 12, 0, 4),
      child: SizedBox(
        height: 44,
        child: ListView(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20),
          children: [
            // "Todos"
            RoomChip(
              label: 'Todos',
              icon: Icons.home_outlined,
              isSelected: controller.comodoSelecionado == null,
              onTap: () => controller.selecionarComodo(null),
            ),
            const SizedBox(width: 8),
            // Cômodos dinâmicos
            ...comodos.map(
              (comodo) => Padding(
                padding: const EdgeInsets.only(right: 8),
                child: RoomChip(
                  label: comodo,
                  icon: _iconeComodo(comodo),
                  isSelected: controller.comodoSelecionado == comodo,
                  onTap: () => controller.selecionarComodo(comodo),
                ),
              ),
            ),
          ],
        ),
      ),
    ).animate().fadeIn(delay: 300.ms, duration: 400.ms);
  }

  IconData _iconeComodo(String comodo) {
    switch (comodo.toLowerCase()) {
      case 'sala':
        return Icons.weekend_outlined;
      case 'quarto':
        return Icons.bed_outlined;
      case 'cozinha':
        return Icons.kitchen_outlined;
      case 'banheiro':
        return Icons.bathtub_outlined;
      default:
        return Icons.room_outlined;
    }
  }

  // =========================================================================
  // DEVICE GRID
  // =========================================================================

  Widget _buildDeviceGrid(
      BuildContext context, CasaController controller) {
    final dispositivos = controller.dispositivosFiltrados;

    if (dispositivos.isEmpty) {
      return SliverToBoxAdapter(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(40),
            child: Column(
              children: [
                Icon(Icons.devices_other_rounded,
                    size: 48, color: CiciTheme.textMuted),
                const SizedBox(height: 12),
                Text(
                  'Nenhum dispositivo neste cômodo',
                  style: CiciTheme.bodyMd,
                ),
              ],
            ),
          ),
        ),
      );
    }

    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      sliver: SliverGrid(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: _gridColumns(context),
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 0.95,
        ),
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            final dispositivo = dispositivos[index];
            return DeviceCard(
              dispositivo: dispositivo,
              onToggle: () => controller.toggleDispositivo(dispositivo),
              onTap: () => _abrirDetalhe(context, dispositivo),
            );
          },
          childCount: dispositivos.length,
        ),
      ),
    );
  }

  int _gridColumns(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width > 900) return 4;
    if (width > 600) return 3;
    return 2;
  }

  // =========================================================================
  // NAVEGAÇÃO
  // =========================================================================

  void _abrirDetalhe(
      BuildContext context, DispositivoInteligente dispositivo) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => DeviceDetailScreen(dispositivo: dispositivo),
      ),
    );
  }

  // =========================================================================
  // FEEDBACK (SNACKBAR)
  // =========================================================================

  void _mostrarFeedback(BuildContext context, CasaController controller) {
    final msg = controller.ultimoFeedback;
    if (msg != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(msg),
            duration: const Duration(seconds: 2),
          ),
        );
        controller.limparFeedback();
      });
    }
  }
}
