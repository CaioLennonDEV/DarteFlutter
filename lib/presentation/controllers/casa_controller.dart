import 'package:flutter/material.dart';

import '../../exceptions/dispositivo_exceptions.dart';
import '../../models/dispositivo_inteligente.dart';
import '../../models/lampada.dart';
import '../../models/sensor.dart';
import '../../models/termostato.dart';
import '../../services/cici_nlp_processor.dart';
import '../../services/gerenciador_casa_inteligente.dart';
import '../widgets/chat_bubble.dart';

/// Controller central do app Cici.
///
/// Encapsula o [GerenciadorCasaInteligente] e expõe estado reativo
/// via [ChangeNotifier] para o Provider.
class CasaController extends ChangeNotifier {
  /// Instância do gerenciador de domínio.
  final GerenciadorCasaInteligente _gerenciador;

  /// Instância do processador de linguagem natural.
  late final CiciNlpProcessor _nlp;

  /// Histórico de mensagens do chat do hub.
  final List<ChatMessage> _mensagens = [];

  /// Indica se o assistente está fingindo processar o comando.
  bool _assistenteProcessando = false;

  /// Cômodo atualmente selecionado para filtragem (null = todos).
  String? _comodoSelecionado;

  /// Mensagem de feedback para o UI (snackbar).
  String? _ultimoFeedback;

  CasaController()
      : _gerenciador = GerenciadorCasaInteligente(nomeResidencia: 'Casa Cici') {
    _nlp = CiciNlpProcessor(_gerenciador);
    _popularDados();
    _inicializarMensagemBoasVindas();
  }

  // =========================================================================
  // GETTERS
  // =========================================================================

  GerenciadorCasaInteligente get gerenciador => _gerenciador;
  String? get comodoSelecionado => _comodoSelecionado;
  String? get ultimoFeedback => _ultimoFeedback;

  /// Lista de dispositivos filtrada pelo cômodo selecionado.
  List<DispositivoInteligente> get dispositivosFiltrados {
    final comodo = _comodoSelecionado;
    if (comodo == null) return _gerenciador.dispositivos;
    return _gerenciador.dispositivosPorComodo(comodo);
  }

  /// Lista de cômodos disponíveis (sem duplicatas).
  List<String> get comodos {
    final set = <String>{};
    for (final d in _gerenciador.dispositivos) {
      final c = d.comodo;
      if (c != null && c.isNotEmpty) set.add(c);
    }
    return set.toList()..sort();
  }

  int get totalDispositivos => _gerenciador.totalDispositivos;
  int get totalLigados => _gerenciador.totalLigados;
  double get consumoTotal => _gerenciador.consumoTotalKwh;
  bool get existeAlerta => _gerenciador.existeAlerta;
  List<Sensor> get sensoresEmAlerta => _gerenciador.sensoresEmAlerta;
  List<Lampada> get lampadas => _gerenciador.lampadas;
  List<Termostato> get termostatos => _gerenciador.termostatos;
  List<Sensor> get sensores => _gerenciador.sensores;

  // =========================================================================
  // AÇÕES
  // =========================================================================

  /// Seleciona um cômodo para filtragem. `null` = todos.
  void selecionarComodo(String? comodo) {
    _comodoSelecionado = comodo;
    notifyListeners();
  }

  /// Liga/desliga um dispositivo (toggle).
  void toggleDispositivo(DispositivoInteligente dispositivo) {
    try {
      if (dispositivo.ligado) {
        dispositivo.desligar();
        _ultimoFeedback = '⚫ "${dispositivo.nome}" desligado.';
      } else {
        dispositivo.ligar();
        _ultimoFeedback = '🟢 "${dispositivo.nome}" ligado.';
      }
    } on DispositivoOfflineException catch (e) {
      _ultimoFeedback = '❌ ${e.mensagem}';
    } catch (e) {
      _ultimoFeedback = '❌ Erro: $e';
    }
    notifyListeners();
  }

  /// Ajusta o brilho de uma lâmpada.
  void ajustarBrilho(Lampada lampada, int novoBrilho) {
    try {
      lampada.brilho = novoBrilho;
      lampada.registrarConsumo(0.005);
      _ultimoFeedback =
          '💡 Brilho de "${lampada.nome}" ajustado para $novoBrilho%.';
    } on DispositivoOfflineException catch (e) {
      _ultimoFeedback = '❌ ${e.mensagem}';
    } on EstadoInvalidoException catch (e) {
      _ultimoFeedback = '❌ ${e.mensagem}';
    } catch (e) {
      _ultimoFeedback = '❌ Erro: $e';
    }
    notifyListeners();
  }

  /// Ajusta a temperatura-alvo de um termostato.
  void ajustarTemperatura(Termostato termostato, double novaTemp) {
    try {
      termostato.temperaturaAlvo = novaTemp;
      termostato.registrarConsumo(0.02);
      _ultimoFeedback =
          '🌡️ Temperatura de "${termostato.nome}" ajustada para ${novaTemp.toStringAsFixed(1)}°C.';
    } on DispositivoOfflineException catch (e) {
      _ultimoFeedback = '❌ ${e.mensagem}';
    } on EstadoInvalidoException catch (e) {
      _ultimoFeedback = '❌ ${e.mensagem}';
    } catch (e) {
      _ultimoFeedback = '❌ Erro: $e';
    }
    notifyListeners();
  }

  /// Altera o modo do termostato.
  void alterarModoTermostato(Termostato termostato, ModoTermostato modo) {
    try {
      termostato.modo = modo;
      _ultimoFeedback =
          '🌡️ Modo de "${termostato.nome}" alterado para ${modo.rotulo}.';
    } on DispositivoOfflineException catch (e) {
      _ultimoFeedback = '❌ ${e.mensagem}';
    } catch (e) {
      _ultimoFeedback = '❌ Erro: $e';
    }
    notifyListeners();
  }

  /// Simula uma leitura no sensor.
  void simularLeituraSensor(Sensor sensor, double valor) {
    try {
      sensor.registrarLeitura(valor);
      _ultimoFeedback =
          '📡 Leitura de "${sensor.nome}": ${valor.toStringAsFixed(1)}${sensor.unidade}.';
    } on DispositivoOfflineException catch (e) {
      _ultimoFeedback = '❌ ${e.mensagem}';
    } catch (e) {
      _ultimoFeedback = '❌ Erro: $e';
    }
    notifyListeners();
  }

  /// Limpa o feedback.
  void limparFeedback() {
    _ultimoFeedback = null;
  }

  // =========================================================================
  // DADOS INICIAIS DE DEMONSTRAÇÃO
  // =========================================================================

  void _popularDados() {
    // -- Lâmpadas --
    final luzSala = Lampada(
      id: 'lamp-001',
      nome: 'Luz da Sala',
      comodo: 'Sala',
      brilho: 80,
      corHex: '#FFFFFF',
    );

    final luzQuarto = Lampada.modoEconomico(
      id: 'lamp-002',
      nome: 'Luz do Quarto',
      comodo: 'Quarto',
    );

    final luzCozinha = Lampada.fromMap({
      'id': 'lamp-003',
      'nome': 'Luz da Cozinha',
      'comodo': 'Cozinha',
      'brilho': 60,
      'corHex': '#FFE4B5',
    });

    // -- Termostatos --
    final termoSala = Termostato(
      id: 'term-001',
      nome: 'Termostato Sala',
      comodo: 'Sala',
      temperaturaAlvo: 24.0,
      modo: ModoTermostato.resfriamento,
    );

    final termoQuarto = Termostato.configuracaoPadrao(
      id: 'term-002',
      nome: 'Termostato Quarto',
      comodo: 'Quarto',
    );

    // -- Sensores --
    final sensorUmidade = Sensor(
      id: 'sens-001',
      nome: 'Sensor Umidade',
      comodo: 'Banheiro',
      tipo: TipoSensor.umidade,
      limiarAlerta: 85.0,
    );

    final sensorTemp = Sensor.temperatura(
      id: 'sens-002',
      nome: 'Sensor Temp.',
      comodo: 'Cozinha',
    );

    final sensorFumaca = Sensor.fromMap({
      'id': 'sens-003',
      'nome': 'Detector Fumaça',
      'comodo': 'Cozinha',
      'tipo': 'fumaca',
      'limiarAlerta': 50.0,
    });

    // Registrar todos
    _gerenciador.adicionarDispositivo(luzSala);
    _gerenciador.adicionarDispositivo(luzQuarto);
    _gerenciador.adicionarDispositivo(luzCozinha);
    _gerenciador.adicionarDispositivo(termoSala);
    _gerenciador.adicionarDispositivo(termoQuarto);
    _gerenciador.adicionarDispositivo(sensorUmidade);
    _gerenciador.adicionarDispositivo(sensorTemp);
    _gerenciador.adicionarDispositivo(sensorFumaca);

    // Ligar alguns para demonstração
    luzSala.ligar();
    luzQuarto.ligar(); // já inicia ligada pelo construtor nomeado
    termoSala.ligar();
    termoQuarto.ligar(); // já inicia ligado pelo construtor nomeado
    sensorUmidade.ligar();
    sensorTemp.ligar();
    sensorFumaca.ligar();

    // Simular leituras
    sensorUmidade.registrarLeitura(72.5);
    sensorTemp.registrarLeitura(28.3);
    sensorFumaca.registrarLeitura(12.0);

    // Simular consumo
    luzSala.registrarConsumo(0.15);
    termoSala.registrarConsumo(0.80);
  }

  // =========================================================================
  // ASSISTENTE INTELIGENTE (CHATHUB)
  // =========================================================================

  List<ChatMessage> get mensagens => List.unmodifiable(_mensagens);
  bool get assistenteProcessando => _assistenteProcessando;

  void _inicializarMensagemBoasVindas() {
    _mensagens.add(ChatMessage(
      text: 'Olá! Sou a Cici, sua assistente residencial. 🎙️\n\n'
          'Me ative dizendo meu nome no comando, por exemplo:\n'
          '• "Cici, ligue a luz da sala"\n'
          '• "Cici, qual o consumo de energia?"\n'
          '• "Cici, ajuste a temperatura do quarto para 22 graus"\n'
          '• "Cici, ligar tudo"',
      timestamp: DateTime.now(),
      isUser: false,
    ));
  }

  /// Envia uma mensagem no chat do assistente.
  Future<void> enviarMensagemAssistente(String texto) async {
    if (texto.trim().isEmpty) return;

    // 1. Adicionar mensagem do usuário
    _mensagens.add(ChatMessage(
      text: texto,
      timestamp: DateTime.now(),
      isUser: true,
    ));
    _assistenteProcessando = true;
    notifyListeners();

    // 2. Simular atraso de processamento ("pensando" / "falando")
    await Future.delayed(const Duration(milliseconds: 900));

    // 3. Processar comando
    final resultado = _nlp.processarComando(texto);

    // 4. Adicionar resposta da Cici
    _mensagens.add(ChatMessage(
      text: resultado.resposta,
      timestamp: DateTime.now(),
      isUser: false,
    ));

    _assistenteProcessando = false;
    notifyListeners();
  }
}
