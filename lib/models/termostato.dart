/// Modelo concreto de Termostato Inteligente do sistema Cici.
///
/// Estende [DispositivoInteligente] e incorpora os mixins
/// [LogAuditoriaMixin] e [MonitoramentoEnergiaMixin].
///
/// Demonstra:
/// - Herança (`extends` + `super`)
/// - Mixins (`with`)
/// - Encapsulamento estrito (`_temperaturaAlvo`, `_modo`)
/// - Getters/Setters com validação rigorosa (16°C–32°C)
/// - Construtor padrão, nomeado e factory
/// - Sobrescrita de métodos abstratos e de `@override toString()`
library;

import '../exceptions/dispositivo_exceptions.dart';
import 'dispositivo_inteligente.dart';

// ===========================================================================
// Enum ModoTermostato
// ===========================================================================

/// Modos de operação do termostato.
enum ModoTermostato {
  /// Aquece o ambiente até atingir a temperatura-alvo.
  aquecimento('Aquecimento'),

  /// Resfria o ambiente até atingir a temperatura-alvo.
  resfriamento('Resfriamento'),

  /// Alterna automaticamente entre aquecimento e resfriamento.
  automatico('Automático');

  /// Rótulo amigável do modo.
  final String rotulo;
  const ModoTermostato(this.rotulo);

  /// Converte uma [String] para o enum correspondente.
  ///
  /// Retorna [ModoTermostato.automatico] se o valor não for reconhecido.
  static ModoTermostato fromString(String? valor) {
    if (valor == null) return ModoTermostato.automatico;
    return ModoTermostato.values.firstWhere(
      (m) => m.name == valor,
      orElse: () => ModoTermostato.automatico,
    );
  }
}

// ===========================================================================
// Classe Termostato
// ===========================================================================

/// Termostato inteligente com controle de temperatura e modo de operação.
class Termostato extends DispositivoInteligente
    with LogAuditoriaMixin, MonitoramentoEnergiaMixin {
  // ---- Constantes de regras de negócio ----

  /// Temperatura mínima permitida (°C).
  static const double temperaturaMinima = 16.0;

  /// Temperatura máxima permitida (°C).
  static const double temperaturaMaxima = 32.0;

  // ---- Atributos privados ----

  /// Temperatura-alvo configurada pelo usuário (°C).
  double _temperaturaAlvo;

  /// Temperatura ambiente atual lida pelo sensor interno (°C).
  double _temperaturaAtual;

  /// Modo de operação do termostato.
  ModoTermostato _modo;

  // ==========================================================================
  // CONSTRUTOR PADRÃO GERATIVO
  // ==========================================================================

  /// Cria um [Termostato] com todos os parâmetros configuráveis.
  ///
  /// - [temperaturaAlvo]: deve estar entre 16°C e 32°C.
  /// - [temperaturaAtual]: leitura do sensor interno (padrão: 22°C).
  /// - [modo]: modo de operação (padrão: automático).
  Termostato({
    required super.id,
    required super.nome,
    super.ligado,
    super.comodo,
    super.conectadoRede,
    super.nivelBateriaInicial,
    double temperaturaAlvo = 22.0,
    double temperaturaAtual = 22.0,
    ModoTermostato modo = ModoTermostato.automatico,
  })  : _temperaturaAlvo = temperaturaAlvo.clamp(
            temperaturaMinima, temperaturaMaxima),
        _temperaturaAtual = temperaturaAtual,
        _modo = modo;

  // ==========================================================================
  // CONSTRUTOR NOMEADO: configuracaoPadrao
  // ==========================================================================

  /// Cria um [Termostato] com configuração padrão confortável.
  ///
  /// - Temperatura-alvo: **23°C**.
  /// - Modo: **automático**.
  /// - Já inicia **ligado**.
  Termostato.configuracaoPadrao({
    required String id,
    required String nome,
    String? comodo,
  })  : _temperaturaAlvo = 23.0,
        _temperaturaAtual = 22.0,
        _modo = ModoTermostato.automatico,
        super(id: id, nome: nome, ligado: true, comodo: comodo);

  // ==========================================================================
  // CONSTRUTOR FACTORY: fromMap
  // ==========================================================================

  /// Desserializa um [Map] para criar uma instância de [Termostato].
  ///
  /// Realiza validação condicional nos campos obrigatórios e na faixa
  /// de temperatura.
  factory Termostato.fromMap(Map<String, dynamic> map) {
    final id = map['id'] as String?;
    final nome = map['nome'] as String?;

    if (id == null || id.trim().isEmpty) {
      throw EstadoInvalidoException(
        campo: 'id',
        valorRecebido: id,
        mensagem: 'O campo "id" é obrigatório para criar um Termostato.',
      );
    }

    if (nome == null || nome.trim().isEmpty) {
      throw EstadoInvalidoException(
        campo: 'nome',
        valorRecebido: nome,
        mensagem: 'O campo "nome" é obrigatório para criar um Termostato.',
      );
    }

    final tempAlvo = (map['temperaturaAlvo'] as num?)?.toDouble() ?? 22.0;

    // Validação condicional: rejeita valores fora do range
    if (tempAlvo < temperaturaMinima || tempAlvo > temperaturaMaxima) {
      throw EstadoInvalidoException(
        campo: 'temperaturaAlvo',
        valorRecebido: tempAlvo,
        mensagem: 'A temperatura-alvo deve estar entre '
            '${temperaturaMinima}°C e ${temperaturaMaxima}°C. '
            'Valor recebido: ${tempAlvo}°C.',
      );
    }

    return Termostato(
      id: id,
      nome: nome,
      ligado: (map['ligado'] as bool?) ?? false,
      comodo: map['comodo'] as String?,
      conectadoRede: (map['conectadoRede'] as bool?) ?? true,
      nivelBateriaInicial: (map['bateria'] as num?)?.toInt(),
      temperaturaAlvo: tempAlvo,
      temperaturaAtual:
          (map['temperaturaAtual'] as num?)?.toDouble() ?? 22.0,
      modo: ModoTermostato.fromString(map['modo'] as String?),
    );
  }

  // ==========================================================================
  // GETTERS
  // ==========================================================================

  /// Temperatura-alvo configurada (°C).
  double get temperaturaAlvo => _temperaturaAlvo;

  /// Temperatura ambiente atual (°C).
  double get temperaturaAtual => _temperaturaAtual;

  /// Modo de operação atual.
  ModoTermostato get modo => _modo;

  /// Diferença entre a temperatura atual e o alvo (°C).
  double get diferencaTemperatura =>
      (_temperaturaAtual - _temperaturaAlvo).abs();

  /// Indica se o ambiente atingiu a temperatura-alvo (tolerância: ±0.5°C).
  bool get temperaturaEstavel => diferencaTemperatura <= 0.5;

  // ==========================================================================
  // SETTERS COM VALIDAÇÃO
  // ==========================================================================

  /// Define a temperatura-alvo do termostato.
  ///
  /// Lança [EstadoInvalidoException] se o valor estiver fora de 16°C–32°C.
  /// Lança [DispositivoOfflineException] se o termostato estiver desligado.
  set temperaturaAlvo(double novaTemperatura) {
    if (!ligado) {
      throw DispositivoOfflineException(
        nomeDispositivo: nome,
        mensagem: 'Não é possível ajustar a temperatura de "$nome": '
            'termostato desligado.',
      );
    }
    if (novaTemperatura < temperaturaMinima ||
        novaTemperatura > temperaturaMaxima) {
      throw EstadoInvalidoException(
        campo: 'temperaturaAlvo',
        valorRecebido: novaTemperatura,
        mensagem: 'Temperatura-alvo deve estar entre '
            '${temperaturaMinima}°C e ${temperaturaMaxima}°C. '
            'Valor recebido: ${novaTemperatura}°C.',
      );
    }
    _temperaturaAlvo = novaTemperatura;
    registrarLog('Temperatura-alvo de "$nome" ajustada para ${_temperaturaAlvo}°C.');
  }

  /// Define o modo de operação do termostato.
  ///
  /// Lança [DispositivoOfflineException] se o termostato estiver desligado.
  set modo(ModoTermostato novoModo) {
    if (!ligado) {
      throw DispositivoOfflineException(
        nomeDispositivo: nome,
        mensagem: 'Não é possível alterar o modo de "$nome": termostato desligado.',
      );
    }
    _modo = novoModo;
    registrarLog('Modo de "$nome" alterado para ${_modo.rotulo}.');
  }

  /// Simula a leitura de uma nova temperatura ambiente.
  void atualizarTemperaturaAtual(double novaLeitura) {
    _temperaturaAtual = novaLeitura;
    registrarLog(
        'Temperatura ambiente de "$nome" atualizada para ${_temperaturaAtual}°C.');
  }

  // ==========================================================================
  // MÉTODOS SOBREPOSTOS (CONTRATOS)
  // ==========================================================================

  /// Liga o termostato e registra no log de auditoria.
  @override
  void ligar() {
    if (ligado) return;
    setLigado(true);
    registrarConsumo(0.05); // consumo ao ligar
    registrarLog(
        'Termostato "$nome" LIGADO (alvo: ${_temperaturaAlvo}°C, '
        'modo: ${_modo.rotulo}).');
  }

  /// Desliga o termostato e registra no log de auditoria.
  @override
  void desligar() {
    if (!ligado) return;
    setLigado(false);
    registrarLog('Termostato "$nome" DESLIGADO.');
  }

  /// Simula processamento de ciclo térmico e carga de trabalho.
  @override
  void processarCargaTrabalho(double intensidade) {
    if (!conectadoRede) {
      throw FalhaConectividadeException(nomeDispositivo: nome);
    }
    if (!ligado) {
      throw DispositivoOfflineException(nomeDispositivo: nome);
    }
    final consumo = (intensidade * 0.25);
    registrarConsumo(consumo);
    registrarLog(
      'Termostato "$nome" processou ciclo de climatização (intensidade: $intensidade, consumo: ${consumo.toStringAsFixed(3)} kWh).',
    );
  }

  /// Serializa o termostato para um [Map].
  Map<String, dynamic> toMap() {
    return {
      'tipo': 'termostato',
      'id': id,
      'nome': nome,
      'ligado': ligado,
      'comodo': comodo,
      'conectadoRede': conectadoRede,
      'bateria': nivelBateria,
      'temperaturaAlvo': _temperaturaAlvo,
      'temperaturaAtual': _temperaturaAtual,
      'modo': _modo.name,
    };
  }

  // ==========================================================================
  // @override toString()
  // ==========================================================================

  /// Representação textual detalhada do termostato.
  @override
  String toString() {
    final estado = ligado ? '🔥 LIGADO' : '⚫ DESLIGADO';
    final estabilidade = temperaturaEstavel ? '✅ Estável' : '⚠️ Ajustando';
    final local = comodo ?? 'não definido';
    final rede = conectadoRede ? 'Rede OK' : 'Sem Conexão';
    return 'Termostato('
        'id: $id, '
        'nome: "$nome", '
        'estado: $estado, '
        'alvo: ${_temperaturaAlvo}°C, '
        'atual: ${_temperaturaAtual}°C, '
        'modo: ${_modo.rotulo}, '
        'status: $estabilidade, '
        'cômodo: $local, '
        'rede: $rede, '
        'consumo: ${consumoAcumuladoKwh.toStringAsFixed(3)} kWh'
        ')';
  }
}
