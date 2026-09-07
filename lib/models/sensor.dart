/// Modelo concreto de Sensor Inteligente do sistema Cici.
///
/// Estende [DispositivoInteligente] e incorpora o mixin [LogAuditoriaMixin].
///
/// Demonstra:
/// - Herança (`extends` + `super`)
/// - Mixin (`with`)
/// - Encapsulamento estrito (`_tipo`, `_ultimaLeitura`, `_unidade`)
/// - Null Safety completo (nullable `_ultimaLeitura`, `_limiarAlerta`)
/// - Construtor padrão, nomeado e factory
/// - Simulação de restrições móveis (telemetria de bateria e conectividade de rede)
/// - Sobrescrita de métodos abstratos e de `@override toString()`
library;

import '../exceptions/dispositivo_exceptions.dart';
import 'dispositivo_inteligente.dart';

// ===========================================================================
// Enum TipoSensor
// ===========================================================================

/// Tipos de sensor suportados pelo sistema Cici.
enum TipoSensor {
  /// Sensor de temperatura ambiente (°C).
  temperatura('Temperatura', '°C'),

  /// Sensor de umidade relativa do ar (%).
  umidade('Umidade', '%'),

  /// Sensor de presença/movimento (binário).
  movimento('Movimento', ''),

  /// Sensor de fumaça/gás (ppm).
  fumaca('Fumaça', 'ppm'),

  /// Sensor de luminosidade (lux).
  luminosidade('Luminosidade', 'lux');

  /// Rótulo amigável do tipo de sensor.
  final String rotulo;

  /// Unidade de medida da leitura.
  final String unidade;

  const TipoSensor(this.rotulo, this.unidade);

  /// Converte uma [String] para o enum correspondente.
  ///
  /// Retorna [TipoSensor.temperatura] se o valor não for reconhecido.
  static TipoSensor fromString(String? valor) {
    if (valor == null) return TipoSensor.temperatura;
    return TipoSensor.values.firstWhere(
      (t) => t.name == valor,
      orElse: () => TipoSensor.temperatura,
    );
  }
}

// ===========================================================================
// Classe Sensor
// ===========================================================================

/// Sensor inteligente que realiza leituras e telemetria no ecossistema móvel.
class Sensor extends DispositivoInteligente with LogAuditoriaMixin {
  // ---- Atributos privados ----

  /// Tipo do sensor.
  final TipoSensor _tipo;

  /// Última leitura realizada pelo sensor (nullable — pode não ter lido ainda).
  double? _ultimaLeitura;

  /// Indica se o sensor está em estado de alerta.
  bool _emAlerta;

  /// Limiar para disparo de alerta.
  final double? _limiarAlerta;

  // ==========================================================================
  // CONSTRUTOR PADRÃO GERATIVO
  // ==========================================================================

  /// Cria um [Sensor] com todos os parâmetros configuráveis.
  ///
  /// Sensores móveis/sem fio utilizam bateria recarregável (padrão inicial: 100%).
  Sensor({
    required super.id,
    required super.nome,
    super.ligado,
    super.comodo,
    super.conectadoRede,
    int nivelBateriaInicial = 100,
    required TipoSensor tipo,
    double? ultimaLeitura,
    double? limiarAlerta,
  })  : _tipo = tipo,
        _ultimaLeitura = ultimaLeitura,
        _emAlerta = false,
        _limiarAlerta = limiarAlerta,
        super(nivelBateriaInicial: nivelBateriaInicial);

  // ==========================================================================
  // CONSTRUTOR NOMEADO: temperatura
  // ==========================================================================

  /// Cria um [Sensor] pré-configurado para medição de temperatura.
  ///
  /// - Tipo: [TipoSensor.temperatura].
  /// - Limiar de alerta: **40°C** (padrão de segurança).
  /// - Bateria inicial: **100%**.
  /// - Já inicia **ligado**.
  Sensor.temperatura({
    required String id,
    required String nome,
    String? comodo,
    int nivelBateria = 100,
  })  : _tipo = TipoSensor.temperatura,
        _ultimaLeitura = null,
        _emAlerta = false,
        _limiarAlerta = 40.0,
        super(
          id: id,
          nome: nome,
          ligado: true,
          comodo: comodo,
          nivelBateriaInicial: nivelBateria,
        );

  // ==========================================================================
  // CONSTRUTOR FACTORY: fromMap
  // ==========================================================================

  /// Desserializa um [Map] para criar uma instância de [Sensor].
  ///
  /// Realiza validação condicional nos campos obrigatórios e trata valores nulos com `??`.
  factory Sensor.fromMap(Map<String, dynamic> map) {
    final id = map['id'] as String?;
    final nome = map['nome'] as String?;

    if (id == null || id.trim().isEmpty) {
      throw EstadoInvalidoException(
        campo: 'id',
        valorRecebido: id,
        mensagem: 'O campo "id" é obrigatório para criar um Sensor.',
      );
    }

    if (nome == null || nome.trim().isEmpty) {
      throw EstadoInvalidoException(
        campo: 'nome',
        valorRecebido: nome,
        mensagem: 'O campo "nome" é obrigatório para criar um Sensor.',
      );
    }

    final bateria = (map['bateria'] as num?)?.toInt() ?? 100;
    if (bateria <= 5) {
      throw RecursoCriticoException(
        'Impossível inicializar sensor "$nome": bateria insuficiente para inicialização operacional.',
        bateria,
      );
    }

    return Sensor(
      id: id,
      nome: nome,
      ligado: (map['ligado'] as bool?) ?? false,
      comodo: map['comodo'] as String?,
      conectadoRede: (map['conectadoRede'] as bool?) ?? true,
      nivelBateriaInicial: bateria,
      tipo: TipoSensor.fromString(map['tipo'] as String?),
      ultimaLeitura: (map['ultimaLeitura'] as num?)?.toDouble(),
      limiarAlerta: (map['limiarAlerta'] as num?)?.toDouble(),
    );
  }

  // ==========================================================================
  // GETTERS
  // ==========================================================================

  /// Tipo do sensor.
  TipoSensor get tipo => _tipo;

  /// Última leitura registrada, ou `null` se ainda não houve leitura.
  double? get ultimaLeitura => _ultimaLeitura;

  /// Indica se o sensor está em estado de alerta.
  bool get emAlerta => _emAlerta;

  /// Limiar configurado para alerta, ou `null` se não configurado.
  double? get limiarAlerta => _limiarAlerta;

  /// Unidade de medida do sensor.
  String get unidade => _tipo.unidade;

  /// Descrição formatada da última leitura (trata null com `??`).
  String get leituraFormatada {
    final leitura = _ultimaLeitura;
    if (leitura == null) return 'Sem leitura';
    return '${leitura.toStringAsFixed(1)}${_tipo.unidade}';
  }

  // ==========================================================================
  // MÉTODOS DE NEGÓCIO E RESTRIÇÕES MÓVEIS
  // ==========================================================================

  /// Registra uma nova leitura no sensor com validações de conectividade e estado.
  void registrarLeitura(double valor) {
    if (!conectadoRede) {
      throw FalhaConectividadeException(nomeDispositivo: nome);
    }

    if (!ligado) {
      throw DispositivoOfflineException(
        nomeDispositivo: nome,
        mensagem: 'Não é possível registrar leitura no sensor "$nome": sensor desligado.',
      );
    }

    _ultimaLeitura = valor;

    final limiar = _limiarAlerta;
    if (limiar != null && valor >= limiar) {
      _emAlerta = true;
      registrarLog(
        '⚠️ ALERTA no sensor "$nome": leitura ${valor.toStringAsFixed(1)}${_tipo.unidade} excedeu limiar de ${limiar.toStringAsFixed(1)}${_tipo.unidade}.',
      );
    } else {
      _emAlerta = false;
      registrarLog(
        'Leitura registrada em "$nome": ${valor.toStringAsFixed(1)}${_tipo.unidade}.',
      );
    }
  }

  /// Processa carga de trabalho com degradação de bateria (restrição de hardware móvel).
  @override
  void processarCargaTrabalho(double intensidade) {
    if (!conectadoRede) {
      throw FalhaConectividadeException(nomeDispositivo: nome);
    }

    if (!ligado) {
      throw DispositivoOfflineException(nomeDispositivo: nome);
    }

    final batAtual = nivelBateria ?? 100;
    final consumoBateria = (intensidade * 3.0).round();

    if (batAtual - consumoBateria <= 5) {
      nivelBateria = 0;
      registrarLog('ALERTA CRÍTICO: Bateria do sensor "$nome" esgotada durante processamento de telemetria.');
      throw RecursoCriticoException(
        'Bateria esgotada no sensor móvel "$nome". Operação suspensa.',
        0,
      );
    }

    nivelBateria = batAtual - consumoBateria;
    registrarLog(
      'Carga de telemetria de $intensidade processada no sensor "$nome". Bateria restante: $nivelBateria%.',
    );
  }

  // ==========================================================================
  // MÉTODOS SOBREPOSTOS (CONTRATOS)
  // ==========================================================================

  /// Liga o sensor e registra no log de auditoria.
  @override
  void ligar() {
    if (ligado) return;
    setLigado(true);
    registrarLog('Sensor "$nome" (${_tipo.rotulo}) LIGADO.');
  }

  /// Desliga o sensor e registra no log de auditoria.
  @override
  void desligar() {
    if (!ligado) return;
    setLigado(false);
    _emAlerta = false;
    registrarLog('Sensor "$nome" (${_tipo.rotulo}) DESLIGADO.');
  }

  /// Serializa o sensor para um [Map].
  Map<String, dynamic> toMap() {
    return {
      'tipo': _tipo.name,
      'id': id,
      'nome': nome,
      'ligado': ligado,
      'comodo': comodo,
      'conectadoRede': conectadoRede,
      'bateria': nivelBateria,
      'ultimaLeitura': _ultimaLeitura,
      'limiarAlerta': _limiarAlerta,
    };
  }

  // ==========================================================================
  // @override toString()
  // ==========================================================================

  /// Representação textual detalhada do sensor.
  @override
  String toString() {
    final estado = ligado ? '📡 LIGADO' : '⚫ DESLIGADO';
    final leitura = leituraFormatada;
    final alerta = _emAlerta ? '🚨 EM ALERTA' : '✅ Normal';
    final local = comodo ?? 'não definido';
    final rede = conectadoRede ? 'Rede OK' : 'Sem Conexão';
    final bat = nivelBateria != null ? ' | Bateria: $nivelBateria%' : '';
    return 'Sensor('
        'id: $id, '
        'nome: "$nome", '
        'tipo: ${_tipo.rotulo}, '
        'estado: $estado, '
        'leitura: $leitura, '
        'status: $alerta, '
        'cômodo: $local, '
        'rede: $rede$bat'
        ')';
  }
}
