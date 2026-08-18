class AIAssistantService {
  /// Gera um resumo inteligente e estruturado a partir do texto
  static String summarize(String content) {
    if (content.trim().isEmpty) return 'Não há conteúdo suficiente para resumir.';

    final lines = content.split(RegExp(r'\n+')).where((l) => l.trim().isNotEmpty).toList();
    final sentences = content
        .split(RegExp(r'[.!?]+'))
        .map((s) => s.trim())
        .where((s) => s.length > 10)
        .toList();

    final buffer = StringBuffer();
    buffer.writeln('✨ **Resumo Inteligente (NotaIA)**:\n');

    if (sentences.isEmpty && lines.isNotEmpty) {
      buffer.writeln('• ${lines.first}');
      return buffer.toString();
    }

    final topSentences = sentences.take(3).toList();
    for (var sentence in topSentences) {
      buffer.writeln('• $sentence.');
    }

    // Insights rápidos
    final wordsCount = content.trim().split(RegExp(r'\s+')).length;
    buffer.writeln('\n💡 *Leitura estimada:* ${(wordsCount / 120).ceil()} min (${wordsCount} palavras)');

    return buffer.toString();
  }

  /// Aprimora a escrita, pontuação e clareza do texto
  static String enhanceText(String content) {
    if (content.trim().isEmpty) return content;

    final lines = content.split('\n');
    final formattedLines = lines.map((line) {
      var trimmed = line.trim();
      if (trimmed.isEmpty) return '';

      // Capitaliza a primeira letra de cada linha se for minúscula
      if (trimmed.isNotEmpty) {
        trimmed = trimmed[0].toUpperCase() + trimmed.substring(1);
      }

      // Adiciona ponto final se não houver pontuação e não for item de lista
      if (!trimmed.endsWith('.') &&
          !trimmed.endsWith('!') &&
          !trimmed.endsWith('?') &&
          !trimmed.endsWith(':') &&
          !trimmed.startsWith('-') &&
          !trimmed.startsWith('*') &&
          !trimmed.startsWith('#')) {
        trimmed = '$trimmed.';
      }

      return trimmed;
    }).toList();

    return formattedLines.join('\n');
  }

  /// Extrai itens de ação e cria um checklist estruturado em Markdown
  static String extractActionItems(String content) {
    if (content.trim().isEmpty) return '- [ ] Nenhuma tarefa identificada.';

    final sentences = content
        .split(RegExp(r'[\n.!?]+'))
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .toList();

    final keywords = [
      'preciso', 'fazer', 'enviar', 'comprar', 'reunir', 'reunião',
      'estudar', 'verificar', 'ligar', 'lembrar', 'urgente', 'entregar',
      'pagar', 'revisar', 'escrever', 'agendar', 'organizar', 'criar'
    ];

    final actionItems = <String>[];

    for (var s in sentences) {
      final lower = s.toLowerCase();
      if (keywords.any((k) => lower.contains(k))) {
        actionItems.add('- [ ] ${s[0].toUpperCase()}${s.substring(1)}');
      }
    }

    if (actionItems.isEmpty) {
      // Se não encontrou por palavra-chave, converte as linhas principais em tarefas
      for (var s in sentences.take(4)) {
        actionItems.add('- [ ] $s');
      }
    }

    return '📋 **Plano de Ação / Checklist:**\n\n${actionItems.join('\n')}';
  }

  /// Sugere tags automáticas com base no conteúdo
  static List<String> suggestTags(String content) {
    final text = content.toLowerCase();
    final tags = <String>{};

    if (text.contains('reunião') || text.contains('projeto') || text.contains('cliente') || text.contains('trabalho')) {
      tags.add('Trabalho');
    }
    if (text.contains('estudo') || text.contains('aula') || text.contains('curso') || text.contains('ler') || text.contains('livro')) {
      tags.add('Estudos');
    }
    if (text.contains('ideia') || text.contains('insight') || text.contains('inovação') || text.contains('criar')) {
      tags.add('Ideias');
    }
    if (text.contains('pagar') || text.contains('compra') || text.contains('dinheiro') || text.contains('banco') || text.contains('r\$')) {
      tags.add('Finanças');
    }
    if (text.contains('urgente') || text.contains('hoje') || text.contains('importante') || text.contains('prazo')) {
      tags.add('Urgente');
    }
    if (text.contains('saúde') || text.contains('médico') || text.contains('treino') || text.contains('academia')) {
      tags.add('Saúde');
    }

    if (tags.isEmpty) {
      tags.add('Geral');
    }

    return tags.toList();
  }

  /// Gera um título conciso automaticamente
  static String generateTitle(String content) {
    if (content.trim().isEmpty) return 'Nota sem título';

    final firstLine = content.trim().split('\n').first.trim();
    if (firstLine.length <= 40) {
      return firstLine.replaceAll(RegExp(r'^[#*-\s]+'), '');
    }
    return '${firstLine.substring(0, 37).trim()}...';
  }
}
