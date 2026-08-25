/// Modelo concreto de Sensor Inteligente do sistema Cici.
///
/// Estende [DispositivoInteligente] e incorpora o mixin [LogAuditoriaMixin].
///
/// Demonstra:
/// - Herança (`extends` + `super`)
/// - Mixin (`with`)
/// - Encapsulamento estrito (`_tipo`, `_ultimaLeitura`, `_unidade`)
/// - Null Safety completo (nullable `_ultimaLeitura`)
/// - Construtor padrão, nomeado e factory
/// - `@override toString()`
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

/// Sensor inteligente que realiza leituras do ambiente.
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
  /// - [tipo]: tipo do sensor (temperatura, umidade, etc.).
  /// - [ultimaLeitura]: última leitura registrada (nullable).
  /// - [limiarAlerta]: valor acima do qual o sensor emite alerta (nullable).
  Sensor({
    required super.id,
    required super.nome,
    super.ligado,
    super.comodo,
    required TipoSensor tipo,
    double? ultimaLeitura,
    double? limiarAlerta,
  })  : _tipo = tipo,
        _ultimaLeitura = ultimaLeitura,
        _emAlerta = false,
        _limiarAlerta = limiarAlerta;

  // ==========================================================================
  // CONSTRUTOR NOMEADO: temperatura
  // ==========================================================================

  /// Cria um [Sensor] pré-configurado para medição de temperatura.
  ///
  /// - Tipo: [TipoSensor.temperatura].
  /// - Limiar de alerta: **40°C** (padrão de segurança).
  /// - Já inicia **ligado**.
  Sensor.temperatura({
    required String id,
    required String nome,
    String? comodo,
  })  : _tipo = TipoSensor.temperatura,
        _ultimaLeitura = null,
        _emAlerta = false,
        _limiarAlerta = 40.0,
        super(id: id, nome: nome, ligado: true, comodo: comodo);

  // ==========================================================================
  // CONSTRUTOR FACTORY: fromMap
  // ==========================================================================

  /// Desserializa um [Map] para criar uma instância de [Sensor].
  ///
  /// Realiza validação condicional nos campos obrigatórios.
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

    return Sensor(
      id: id,
      nome: nome,
      ligado: (map['ligado'] as bool?) ?? false,
      comodo: map['comodo'] as String?,
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
  // MÉTODOS DE NEGÓCIO
  // ==========================================================================

  /// Registra uma nova leitura no sensor.
  ///
  /// Lança [DispositivoOfflineException] se o sensor estiver desligado.
  /// Verifica o limiar de alerta e atualiza o estado [emAlerta].
  void registrarLeitura(double valor) {
    if (!ligado) {
      throw DispositivoOfflineException(
        nomeDispositivo: nome,
        mensagem: 'Não é possível registrar leitura no sensor "$nome": '
            'sensor desligado.',
      );
    }

    _ultimaLeitura = valor;

    // Verificação de alerta usando null-aware operator (?.)
    final limiar = _limiarAlerta;
    if (limiar != null && valor >= limiar) {
      _emAlerta = true;
      registrarLog(
          '⚠️ ALERTA no sensor "$nome": leitura ${valor.toStringAsFixed(1)}'
          '${_tipo.unidade} excedeu limiar de ${limiar.toStringAsFixed(1)}'
          '${_tipo.unidade}.');
    } else {
      _emAlerta = false;
      registrarLog(
          'Leitura registrada em "$nome": ${valor.toStringAsFixed(1)}'
          '${_tipo.unidade}.');
    }
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
    return 'Sensor('
        'id: $id, '
        'nome: "$nome", '
        'tipo: ${_tipo.rotulo}, '
        'estado: $estado, '
        'leitura: $leitura, '
        'status: $alerta, '
        'cômodo: $local'
        ')';
  }
}
