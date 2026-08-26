import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../controllers/casa_controller.dart';
import '../theme/cici_theme.dart';
import '../widgets/alexa_ring.dart';
import '../widgets/chat_bubble.dart';

/// Tela do Cici AI Hub — painel de controle por chat/voz (estilo Alexa).
class AssistantScreen extends StatefulWidget {
  const AssistantScreen({super.key});

  @override
  State<AssistantScreen> createState() => _AssistantScreenState();
}

class _AssistantScreenState extends State<AssistantScreen> {
  final TextEditingController _inputController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  // Chips de sugestões comuns para facilitar os testes rápidos do usuário
  final List<String> _sugestoes = [
    'Cici, ligar a Luz da Sala',
    'Cici, apague a Luz do Quarto',
    'Cici, qual o consumo total?',
    'Cici, como está o Sensor Umidade?',
    'Cici, temperatura da Sala para 23 graus',
    'Cici, ligar tudo',
    'Cici, desligar tudo',
  ];

  @override
  void dispose() {
    _inputController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  /// Rola a lista de chat de forma suave até o final.
  void _irParaOFim() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeOut,
      );
    }
  }

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
        title: Text('Cici AI Hub', style: CiciTheme.headingSm),
        actions: [
          IconButton(
            icon: const Icon(Icons.cleaning_services_rounded, size: 18),
            tooltip: 'Sugestões',
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Use os chips de sugestão na base do chat!')),
              );
            },
          ),
        ],
      ),
      body: Consumer<CasaController>(
        builder: (context, controller, _) {
          // Garante rolagem para o fim sempre que o estado/mensagens atualizarem
          WidgetsBinding.instance.addPostFrameCallback((_) => _irParaOFim());

          return Column(
            children: [
              const SizedBox(height: 16),

              // ── ALEXA / CICI LIGHT RING (ANEL ANIMADO) ──
              AlexaRing(
                isProcessing: controller.assistenteProcessando,
              ),

              const SizedBox(height: 16),

              // ── HISTÓRICO DE DIÁLOGO ──
              Expanded(
                child: controller.mensagens.isEmpty
                    ? Center(
                        child: Text(
                          'Inicie uma conversa com a Cici.',
                          style: CiciTheme.bodyMd,
                        ),
                      )
                    : ListView.builder(
                        controller: _scrollController,
                        physics: const BouncingScrollPhysics(),
                        itemCount: controller.mensagens.length,
                        itemBuilder: (context, index) {
                          final msg = controller.mensagens[index];
                          return ChatBubble(message: msg);
                        },
                      ),
              ),

              // ── BARRA DE SUGESTÕES (CHIPS RAPIDOS) ──
              _buildSuggestionsBar(controller),

              // ── CAMPO DE TEXTO E INPUT ──
              _buildInputArea(controller),
            ],
          );
        },
      ),
    );
  }

  // =========================================================================
  // BARRA DE SUGESTÕES (CHIPS)
  // =========================================================================

  Widget _buildSuggestionsBar(CasaController controller) {
    return Container(
      height: 48,
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _sugestoes.length,
        itemBuilder: (context, index) {
          final sugestao = _sugestoes[index];
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ActionChip(
              backgroundColor: CiciTheme.surfaceDark,
              side: const BorderSide(color: CiciTheme.glassBorder),
              shape: RoundedRectangleBorder(borderRadius: CiciTheme.radiusFull),
              label: Text(
                sugestao,
                style: CiciTheme.bodySm.copyWith(color: CiciTheme.textSecondary),
              ),
              onPressed: controller.assistenteProcessando
                  ? null
                  : () {
                      controller.enviarMensagemAssistente(sugestao);
                    },
            ),
          );
        },
      ),
    );
  }

  // =========================================================================
  // INPUT AREA (CAMPO + BOTOES)
  // =========================================================================

  Widget _buildInputArea(CasaController controller) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      decoration: BoxDecoration(
        color: CiciTheme.surfaceDark,
        border: const Border(
          top: BorderSide(color: CiciTheme.glassBorder, width: 0.5),
        ),
      ),
      child: Row(
        children: [
          // Campo de texto
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: CiciTheme.backgroundDark,
                borderRadius: CiciTheme.radiusXl,
                border: Border.all(color: CiciTheme.glassBorder),
              ),
              child: Row(
                children: [
                  const SizedBox(width: 14),
                  // Ícone de escuta
                  Icon(
                    controller.assistenteProcessando
                        ? Icons.graphic_eq_rounded
                        : Icons.keyboard_rounded,
                    color: CiciTheme.textMuted,
                    size: 20,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextField(
                      controller: _inputController,
                      enabled: !controller.assistenteProcessando,
                      style: CiciTheme.bodyLg,
                      cursorColor: CiciTheme.primaryBlue,
                      decoration: InputDecoration(
                        hintText: controller.assistenteProcessando
                            ? 'Cici está pensando...'
                            : 'Fale ou digite algo...',
                        hintStyle: CiciTheme.bodyMd.copyWith(color: CiciTheme.textMuted),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      onSubmitted: (texto) {
                        _enviarMensagem(controller, texto);
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 10),

          // Botão enviar ou Microfone simulado
          GestureDetector(
            onTap: controller.assistenteProcessando
                ? null
                : () {
                    _enviarMensagem(controller, _inputController.text);
                  },
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: controller.assistenteProcessando
                    ? CiciTheme.surfaceDark
                    : CiciTheme.primaryBlue,
                shape: BoxShape.circle,
                boxShadow: controller.assistenteProcessando
                    ? null
                    : [
                        BoxShadow(
                          color: CiciTheme.primaryBlue.withOpacity(0.3),
                          blurRadius: 8,
                          spreadRadius: 1,
                        )
                      ],
              ),
              child: Icon(
                _inputController.text.trim().isEmpty && !controller.assistenteProcessando
                    ? Icons.mic_rounded
                    : Icons.send_rounded,
                color: Colors.white,
                size: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _enviarMensagem(CasaController controller, String texto) {
    if (texto.trim().isEmpty) {
      // Simulação rápida: se o usuário clicar no mic com o campo vazio, envia um comando aleatório
      final random = _sugestoes[0];
      controller.enviarMensagemAssistente(random);
      return;
    }

    controller.enviarMensagemAssistente(texto);
    _inputController.clear();
    setState(() {}); // Força rebuild pra atualizar ícone de microfone/enviar
  }
}
