/// Modelo concreto de Lâmpada Inteligente do sistema Cici.
///
/// Estende [DispositivoInteligente] e incorpora os mixins
/// [LogAuditoriaMixin] e [MonitoramentoEnergiaMixin].
///
/// Demonstra:
/// - Herança (`extends` + `super`)
/// - Mixins (`with`)
/// - Encapsulamento estrito (`_brilho`, `_corHex`)
/// - Getters/Setters com validação
/// - Construtor padrão, nomeado e factory
/// - Sobrescrita de métodos abstratos e de `@override toString()`
library;

import '../exceptions/dispositivo_exceptions.dart';
import 'dispositivo_inteligente.dart';

/// Lâmpada inteligente com controle de brilho e cor.
class Lampada extends DispositivoInteligente
    with LogAuditoriaMixin, MonitoramentoEnergiaMixin {
  // ---- Atributos privados ----

  /// Intensidade do brilho em porcentagem (0–100).
  int _brilho;

  /// Cor em formato hexadecimal (ex: "#FFFFFF"). Nullable.
  String? _corHex;

  // ==========================================================================
  // CONSTRUTOR PADRÃO GERATIVO
  // ==========================================================================

  /// Cria uma [Lampada] com todos os parâmetros configuráveis.
  ///
  /// - [brilho]: intensidade de 0 a 100 (padrão: 100).
  /// - [corHex]: cor em hexadecimal (ex: "#FFD700").
  Lampada({
    required super.id,
    required super.nome,
    super.ligado,
    super.comodo,
    super.conectadoRede,
    super.nivelBateriaInicial,
    int brilho = 100,
    String? corHex,
  })  : _brilho = brilho.clamp(0, 100),
        _corHex = corHex;

  // ==========================================================================
  // CONSTRUTOR NOMEADO: modoEconomico
  // ==========================================================================

  /// Cria uma [Lampada] pré-configurada em modo econômico.
  ///
  /// - Brilho fixado em **20%**.
  /// - Cor quente "#FFD580" (âmbar suave) para menor consumo visual.
  /// - Já inicia **ligada**.
  Lampada.modoEconomico({
    required String id,
    required String nome,
    String? comodo,
  })  : _brilho = 20,
        _corHex = '#FFD580',
        super(id: id, nome: nome, ligado: true, comodo: comodo);

  // ==========================================================================
  // CONSTRUTOR FACTORY: fromMap
  // ==========================================================================

  /// Desserializa um [Map] para criar uma instância de [Lampada].
  ///
  /// Realiza validação condicional:
  /// - Se `'id'` ou `'nome'` estiverem ausentes, lança [EstadoInvalidoException].
  /// - Valores nulos são tratados com `??` (nunca usa `!`).
  factory Lampada.fromMap(Map<String, dynamic> map) {
    final id = map['id'] as String?;
    final nome = map['nome'] as String?;

    if (id == null || id.trim().isEmpty) {
      throw EstadoInvalidoException(
        campo: 'id',
        valorRecebido: id,
        mensagem: 'O campo "id" é obrigatório para criar uma Lampada.',
      );
    }

    if (nome == null || nome.trim().isEmpty) {
      throw EstadoInvalidoException(
        campo: 'nome',
        valorRecebido: nome,
        mensagem: 'O campo "nome" é obrigatório para criar uma Lampada.',
      );
    }

    return Lampada(
      id: id,
      nome: nome,
      ligado: (map['ligado'] as bool?) ?? false,
      comodo: map['comodo'] as String?,
      conectadoRede: (map['conectadoRede'] as bool?) ?? true,
      nivelBateriaInicial: (map['bateria'] as num?)?.toInt(),
      brilho: (map['brilho'] as num?)?.toInt() ?? 100,
      corHex: map['corHex'] as String?,
    );
  }

  // ==========================================================================
  // GETTERS
  // ==========================================================================

  /// Intensidade do brilho atual (0–100).
  int get brilho => _brilho;

  /// Cor atual em hexadecimal, ou `null` se não definida.
  String? get corHex => _corHex;

  // ==========================================================================
  // SETTERS COM VALIDAÇÃO
  // ==========================================================================

  /// Define o brilho da lâmpada.
  ///
  /// Lança [EstadoInvalidoException] se o valor estiver fora de 0–100.
  /// Lança [DispositivoOfflineException] se a lâmpada estiver desligada.
  set brilho(int novoBrilho) {
    if (!ligado) {
      throw DispositivoOfflineException(
        nomeDispositivo: nome,
        mensagem:
            'Não é possível ajustar o brilho de "$nome": lâmpada desligada.',
      );
    }
    if (novoBrilho < 0 || novoBrilho > 100) {
      throw EstadoInvalidoException(
        campo: 'brilho',
        valorRecebido: novoBrilho,
        mensagem:
            'O brilho deve estar entre 0 e 100%. Valor recebido: $novoBrilho.',
      );
    }
    _brilho = novoBrilho;
    registrarLog('Brilho de "$nome" ajustado para $_brilho%.');
  }

  /// Define a cor da lâmpada em formato hexadecimal.
  set corHex(String? novaCor) {
    _corHex = novaCor;
    registrarLog('Cor de "$nome" alterada para ${novaCor ?? "padrão"}.');
  }

  // ==========================================================================
  // MÉTODOS SOBREPOSTOS (CONTRATOS)
  // ==========================================================================

  /// Liga a lâmpada e registra no log de auditoria.
  @override
  void ligar() {
    if (ligado) return; // já está ligada, operação idempotente
    setLigado(true);
    registrarConsumo(0.01); // consumo inicial ao ligar
    registrarLog('Lâmpada "$nome" LIGADA (brilho: $_brilho%).');
  }

  /// Desliga a lâmpada e registra no log de auditoria.
  @override
  void desligar() {
    if (!ligado) return; // já está desligada
    setLigado(false);
    registrarLog('Lâmpada "$nome" DESLIGADA.');
  }

  /// Simula processamento de carga de trabalho e consumo energético.
  @override
  void processarCargaTrabalho(double intensidade) {
    if (!conectadoRede) {
      throw FalhaConectividadeException(nomeDispositivo: nome);
    }
    if (!ligado) {
      throw DispositivoOfflineException(nomeDispositivo: nome);
    }
    final consumo = (intensidade * 0.05);
    registrarConsumo(consumo);
    registrarLog(
      'Lâmpada "$nome" processou ciclo luminoso (intensidade: $intensidade, consumo: ${consumo.toStringAsFixed(3)} kWh).',
    );
  }

  /// Serializa a lâmpada para um [Map].
  Map<String, dynamic> toMap() {
    return {
      'tipo': 'lampada',
      'id': id,
      'nome': nome,
      'ligado': ligado,
      'comodo': comodo,
      'conectadoRede': conectadoRede,
      'bateria': nivelBateria,
      'brilho': _brilho,
      'corHex': _corHex,
    };
  }

  // ==========================================================================
  // @override toString()
  // ==========================================================================

  /// Representação textual detalhada da lâmpada.
  @override
  String toString() {
    final estado = ligado ? '💡 LIGADA' : '⚫ DESLIGADA';
    final cor = _corHex ?? 'padrão';
    final local = comodo ?? 'não definido';
    final rede = conectadoRede ? 'Rede OK' : 'Sem Conexão';
    return 'Lampada('
        'id: $id, '
        'nome: "$nome", '
        'estado: $estado, '
        'brilho: $_brilho%, '
        'cor: $cor, '
        'cômodo: $local, '
        'rede: $rede, '
        'consumo: ${consumoAcumuladoKwh.toStringAsFixed(3)} kWh'
        ')';
  }
}
