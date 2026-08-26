import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../theme/cici_theme.dart';

/// Representa uma mensagem individual na conversa.
class ChatMessage {
  final String text;
  final DateTime timestamp;
  final bool isUser;

  ChatMessage({
    required this.text,
    required this.timestamp,
    required this.isUser,
  });
}

/// Widget visual para exibir balões de conversa no estilo chat.
class ChatBubble extends StatelessWidget {
  final ChatMessage message;

  const ChatBubble({
    super.key,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    final isUser = message.isUser;
    final alignment = isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start;
    final bubbleColor = isUser ? CiciTheme.primaryBlue : CiciTheme.cardElevated;
    final borderRadius = isUser
        ? CiciTheme.radiusLg.copyWith(bottomRight: Radius.zero)
        : CiciTheme.radiusLg.copyWith(topLeft: Radius.zero);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 16),
      child: Column(
        crossAxisAlignment: alignment,
        children: [
          Row(
            mainAxisAlignment:
                isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (!isUser) ...[
                // Avatar da Cici
                Container(
                  margin: const EdgeInsets.only(right: 8, top: 4),
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: CiciTheme.accentCyan.withOpacity(0.15),
                    shape: BoxShape.circle,
                    border: Border.all(color: CiciTheme.accentCyan.withOpacity(0.3)),
                  ),
                  child: const Icon(
                    Icons.bubble_chart_rounded,
                    color: CiciTheme.accentCyan,
                    size: 16,
                  ),
                ),
              ],
              Flexible(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: bubbleColor,
                    borderRadius: borderRadius,
                    border: Border.all(
                      color: isUser
                          ? CiciTheme.primaryBlue.withOpacity(0.2)
                          : CiciTheme.glassBorder,
                      width: 0.5,
                    ),
                  ),
                  child: Text(
                    message.text,
                    style: CiciTheme.bodyLg.copyWith(
                      color: isUser ? Colors.white : CiciTheme.textPrimary,
                      fontSize: 15,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          // Horário
          Padding(
            padding: EdgeInsets.only(
              left: isUser ? 0 : 42,
              right: isUser ? 4 : 0,
            ),
            child: Text(
              _formatarHora(message.timestamp),
              style: CiciTheme.bodySm.copyWith(
                fontSize: 10,
                color: CiciTheme.textMuted,
              ),
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 350.ms).slideY(
          begin: 0.1,
          end: 0,
          duration: 350.ms,
          curve: Curves.easeOutQuad,
        );
  }

  String _formatarHora(DateTime dt) {
    return '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }
}
