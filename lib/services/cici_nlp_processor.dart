import '../exceptions/dispositivo_exceptions.dart';
import '../models/dispositivo_inteligente.dart';
import '../models/lampada.dart';
import '../models/sensor.dart';
import '../models/termostato.dart';
import 'gerenciador_casa_inteligente.dart';

/// Resultado do processamento de um comando de voz/texto.
class NlpResultado {
  /// Mensagem de resposta humanizada da Cici.
  final String resposta;

  /// Indica se o comando foi compreendido e executado.
  final bool executado;

  /// Indica se a palavra de ativação "cici" foi detectada.
  final bool ciciAtivada;

  NlpResultado({
    required this.resposta,
    required this.executado,
    required this.ciciAtivada,
  });
}

/// Motor de Processamento de Linguagem Natural (NLP) local do Cici AI Hub.
///
/// Analisa sentenças de texto, identifica intenções e entidades (dispositivos,
/// valores, cômodos) e executa ações diretas no gerenciador de dispositivos.
class CiciNlpProcessor {
  final GerenciadorCasaInteligente gerenciador;

  CiciNlpProcessor(this.gerenciador);

  /// Processa um comando de texto e retorna um [NlpResultado] com a resposta.
  NlpResultado processarComando(String comandoOriginal) {
    final comando = comandoOriginal.toLowerCase().trim();

    // 1. Verificar Wake Word "cici"
    if (!comando.contains('cici')) {
      return NlpResultado(
        resposta: '💤 (Para me ativar, comece dizendo "Cici", ex: "Cici, ligue a luz da sala")',
        executado: false,
        ciciAtivada: false,
      );
    }

    // Limpar o comando retirando a palavra "cici" e pontuações
    var texto = comando
        .replaceAll('cici', '')
        .replaceAll(',', '')
        .replaceAll('!', '')
        .replaceAll('?', '')
        .replaceAll('  ', ' ')
        .trim();

    // Se o comando for apenas "cici"
    if (texto.isEmpty) {
      return NlpResultado(
        resposta: 'Estou ouvindo! O que deseja controlar? 🎙️ (Diga algo como "ligar a luz" ou "qual o consumo total?")',
        executado: true,
        ciciAtivada: true,
      );
    }

    try {
      // 2. Mapeamento de Intenções Globais
      if (_contemQualquer(texto, ['ligar tudo', 'ligue tudo', 'acender tudo', 'acenda tudo'])) {
        return _executarLigarDesligarTudo(true);
      }
      if (_contemQualquer(texto, ['desligar tudo', 'desligue tudo', 'apagar tudo', 'apague tudo'])) {
        return _executarLigarDesligarTudo(false);
      }
      if (_contemQualquer(texto, ['consumo', 'energia', 'gasto', 'kwh'])) {
        return _obterConsumoEnergia();
      }
      if (_contemQualquer(texto, ['alertas', 'problemas', 'sensores em alerta', 'alerta'])) {
        return _obterAlertasAtivos();
      }

      // 3. Resolver Entidade: Identificar o dispositivo mencionado
      final dispositivo = _identificarDispositivo(texto);
      if (dispositivo == null) {
        return NlpResultado(
          resposta: '🤔 Não consegui identificar a qual dispositivo você se refere no comando: "$texto". '
              'Tente especificar melhor, ex: "Luz da Sala" ou "Sensor Temp. Cozinha".',
          executado: false,
          ciciAtivada: true,
        );
      }

      // 4. Mapeamento de Intenções por Dispositivo
      final numero = _extrairNumero(texto);

      // Intenção: AJUSTAR TEMPERATURA (apenas para Termostato)
      if (_contemQualquer(texto, ['temperatura', 'temp', 'grau', 'graus', 'º']) ||
          (dispositivo is Termostato && numero != null)) {
        if (dispositivo is! Termostato) {
          return NlpResultado(
            resposta: '❌ Desculpe, mas "${dispositivo.nome}" não é um termostato para ajustar temperatura.',
            executado: false,
            ciciAtivada: true,
          );
        }
        if (numero == null) {
          return NlpResultado(
            resposta: '🌡️ Para qual temperatura devo ajustar o termostato "${dispositivo.nome}"? '
                'Diga algo como: "Cici, ajuste a temperatura da sala para 22 graus".',
            executado: false,
            ciciAtivada: true,
          );
        }
        dispositivo.temperaturaAlvo = numero;
        return NlpResultado(
          resposta: '✅ Feito! Ajustei o termostato "${dispositivo.nome}" para ${numero.toStringAsFixed(1)}°C.',
          executado: true,
          ciciAtivada: true,
        );
      }

      // Intenção: AJUSTAR BRILHO (apenas para Lâmpada)
      if (_contemQualquer(texto, ['brilho', 'intensidade', '%', 'por cento']) ||
          (dispositivo is Lampada && numero != null)) {
        if (dispositivo is! Lampada) {
          return NlpResultado(
            resposta: '❌ Desculpe, mas "${dispositivo.nome}" não suporta controle de brilho.',
            executado: false,
            ciciAtivada: true,
          );
        }
        if (numero == null) {
          return NlpResultado(
            resposta: '💡 Qual nível de brilho deseja para a lâmpada "${dispositivo.nome}"? '
                'Diga algo como: "Cici, brilho do quarto em 50 porcento".',
            executado: false,
            ciciAtivada: true,
          );
        }
        dispositivo.brilho = numero.round();
        return NlpResultado(
          resposta: '✅ Entendido! Defini o brilho da lâmpada "${dispositivo.nome}" para ${numero.round()}%.',
          executado: true,
          ciciAtivada: true,
        );
      }

      // Intenção: LIGAR DISPOSITIVO
      if (_contemQualquer(texto, ['ligar', 'ligue', 'acender', 'acenda', 'ativar', 'ative'])) {
        dispositivo.ligar();
        return NlpResultado(
          resposta: '✅ Certo. Liguei o dispositivo "${dispositivo.nome}".',
          executado: true,
          ciciAtivada: true,
        );
      }

      // Intenção: DESLIGAR DISPOSITIVO
      if (_contemQualquer(texto, ['desligar', 'desligue', 'apagar', 'apague', 'desativar', 'desative'])) {
        dispositivo.desligar();
        return NlpResultado(
          resposta: '✅ Ok. Desliguei o dispositivo "${dispositivo.nome}".',
          executado: true,
          ciciAtivada: true,
        );
      }

      // Intenção: CONSULTAR STATUS
      if (_contemQualquer(texto, ['status', 'estado', 'como esta', 'como está', 'leitura', 'informação', 'informacao'])) {
        return NlpResultado(
          resposta: '📊 Status atual: $dispositivo',
          executado: true,
          ciciAtivada: true,
        );
      }

      // Se detectou dispositivo mas nenhuma intenção clara, inverte o estado atual como atalho
      if (dispositivo.ligado) {
        dispositivo.desligar();
        return NlpResultado(
          resposta: '✅ Apaguei o dispositivo "${dispositivo.nome}" para você.',
          executado: true,
          ciciAtivada: true,
        );
      } else {
        dispositivo.ligar();
        return NlpResultado(
          resposta: '✅ Acendi o dispositivo "${dispositivo.nome}" para você.',
          executado: true,
          ciciAtivada: true,
        );
      }
    } on DispositivoOfflineException catch (e) {
      return NlpResultado(
        resposta: '❌ Ops! ${e.mensagem}',
        executado: false,
        ciciAtivada: true,
      );
    } on EstadoInvalidoException catch (e) {
      return NlpResultado(
        resposta: '⚠️ Valor fora do limite permitido: ${e.mensagem}',
        executado: false,
        ciciAtivada: true,
      );
    } catch (e) {
      return NlpResultado(
        resposta: '❌ Desculpe, ocorreu um erro ao executar esse comando: $e',
        executado: false,
        ciciAtivada: true,
      );
    }
  }

  // =========================================================================
  // AUXILIARES DE INTENÇÃO GERAL
  // =========================================================================

  NlpResultado _executarLigarDesligarTudo(bool ligar) {
    // Coleções funcionais (.map e .forEach) para aplicar a ação em lote
    final dispositivosModificados = gerenciador.dispositivos.where((d) => d.ligado != ligar).toList();
    if (dispositivosModificados.isEmpty) {
      return NlpResultado(
        resposta: 'Todos os dispositivos já estão no estado desejado.',
        executado: true,
        ciciAtivada: true,
      );
    }

    for (final d in dispositivosModificados) {
      if (ligar) {
        d.ligar();
      } else {
        d.desligar();
      }
    }

    return NlpResultado(
      resposta: '✅ Executado! '
          '${ligar ? "Liguei" : "Desliguei"} todos os ${dispositivosModificados.length} dispositivos cadastrados.',
      executado: true,
      ciciAtivada: true,
    );
  }

  NlpResultado _obterConsumoEnergia() {
    final consumo = gerenciador.consumoTotalKwh;
    final totalDispositivos = gerenciador.totalDispositivos;
    final ligados = gerenciador.totalLigados;

    return NlpResultado(
      resposta: '⚡ O consumo total acumulado da casa é de ${consumo.toStringAsFixed(3)} kWh. '
          'Temos atualmente $ligados de $totalDispositivos dispositivos ligados.',
      executado: true,
      ciciAtivada: true,
    );
  }

  NlpResultado _obterAlertasAtivos() {
    final alertas = gerenciador.sensoresEmAlerta;
    if (alertas.isEmpty) {
      return NlpResultado(
        resposta: '✅ Excelente notícia! Não há nenhum sensor em estado de alerta no momento.',
        executado: true,
        ciciAtivada: true,
      );
    }

    final descricaoAlertas = alertas.map((s) => '${s.nome} (${s.leituraFormatada})').join(', ');
    return NlpResultado(
      resposta: '🚨 Alerta! Temos os seguintes sensores em alerta ativo: $descricaoAlertas.',
      executado: true,
      ciciAtivada: true,
    );
  }

  // =========================================================================
  // PARSER E AUXILIARES DE TEXTO
  // =========================================================================

  /// Identifica o dispositivo mencionado no texto do comando.
  DispositivoInteligente? _identificarDispositivo(String texto) {
    final dispositivos = gerenciador.dispositivos;

    // 1. Tentar correspondência exata ou contida no nome do dispositivo
    for (final d in dispositivos) {
      final nomeFormatado = d.nome.toLowerCase();
      if (texto.contains(nomeFormatado)) {
        return d;
      }
    }

    // 2. Tentar por partes de palavras (ex: comando "sala" mapear para "Luz da Sala")
    for (final d in dispositivos) {
      final partes = d.nome.toLowerCase().split(' ');
      for (final parte in partes) {
        if (parte.length > 3 && texto.contains(parte)) {
          return d;
        }
      }
    }

    // 3. Tentar pelo cômodo (ex: "termostato sala" -> mapear pro termostato do cômodo sala)
    for (final d in dispositivos) {
      final comodo = d.comodo;
      if (comodo != null) {
        final comodoFormatado = comodo.toLowerCase();
        if (texto.contains(comodoFormatado)) {
          // Filtrar pelo tipo
          if (texto.contains('luz') || texto.contains('lampada') || texto.contains('lâmpada')) {
            if (d is Lampada) return d;
          }
          if (texto.contains('termostato') || texto.contains('temperatura') || texto.contains('clima')) {
            if (d is Termostato) return d;
          }
          if (texto.contains('sensor') || texto.contains('detector') || texto.contains('umidade')) {
            if (d is Sensor) return d;
          }
        }
      }
    }

    return null;
  }

  /// Extrai o primeiro número (inteiro ou decimal) de uma frase.
  double? _extrairNumero(String texto) {
    final regExp = RegExp(r'\d+([.,]\d+)?');
    final match = regExp.firstMatch(texto);
    if (match != null) {
      final numStr = match.group(0)!.replaceAll(',', '.');
      return double.tryParse(numStr);
    }
    return null;
  }

  /// Verifica se a string contém alguma das palavras da lista.
  bool _contemQualquer(String texto, List<String> termos) {
    for (final termo in termos) {
      if (texto.contains(termo)) {
        return true;
      }
    }
    return false;
  }
}
