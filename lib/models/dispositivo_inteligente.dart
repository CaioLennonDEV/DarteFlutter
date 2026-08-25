/// Classe abstrata base e mixins do sistema Cici de automação residencial.
///
/// Define o contrato [DispositivoInteligente] que todas as entidades
/// concretas (lâmpadas, termostatos, sensores) devem implementar.
///
/// Inclui os mixins:
/// - [LogAuditoriaMixin]: registra ações com timestamp.
/// - [MonitoramentoEnergiaMixin]: rastreia consumo de energia acumulado.
library;

import '../exceptions/dispositivo_exceptions.dart';

// ===========================================================================
// MIXIN: LogAuditoriaMixin
// ===========================================================================

/// Mixin que adiciona capacidade de auditoria a qualquer dispositivo.
///
/// Mantém um log interno de [RegistroLog] com todas as ações executadas,
/// permitindo rastreabilidade completa.
mixin LogAuditoriaMixin {
  /// Lista interna de registros de auditoria.
  final List<RegistroLog> _logs = [];

  /// Retorna uma cópia imutável dos logs registrados.
  List<RegistroLog> get logs => List.unmodifiable(_logs);

  /// Registra uma ação no log de auditoria com timestamp automático.
  void registrarLog(String acao) {
    _logs.add(RegistroLog(
      acao: acao,
      timestamp: DateTime.now(),
    ));
  }

  /// Retorna os últimos [n] registros de log, ou todos se [n] for maior
  /// que o total de logs.
  List<RegistroLog> ultimosLogs(int n) {
    final inicio = _logs.length > n ? _logs.length - n : 0;
    return _logs.sublist(inicio);
  }
}

/// Representa uma entrada individual no log de auditoria.
class RegistroLog {
  /// Descrição da ação registrada.
  final String acao;

  /// Momento exato em que a ação foi registrada.
  final DateTime timestamp;

  const RegistroLog({required this.acao, required this.timestamp});

  @override
  String toString() {
    final hora = '${timestamp.hour.toString().padLeft(2, '0')}:'
        '${timestamp.minute.toString().padLeft(2, '0')}:'
        '${timestamp.second.toString().padLeft(2, '0')}';
    return '[$hora] $acao';
  }
}

// ===========================================================================
// MIXIN: MonitoramentoEnergiaMixin
// ===========================================================================

/// Mixin que adiciona rastreamento de consumo energético (em kWh).
///
/// Permite registrar consumo incremental e consultar o total acumulado.
mixin MonitoramentoEnergiaMixin {
  /// Consumo acumulado em kWh (privado ao mixin).
  double _consumoAcumuladoKwh = 0.0;

  /// Retorna o consumo total acumulado em kWh.
  double get consumoAcumuladoKwh => _consumoAcumuladoKwh;

  /// Registra consumo de energia adicional em kWh.
  ///
  /// Lança [EstadoInvalidoException] se [kwh] for negativo.
  void registrarConsumo(double kwh) {
    if (kwh < 0) {
      throw EstadoInvalidoException(
        campo: 'consumo (kWh)',
        valorRecebido: kwh,
        mensagem: 'O consumo registrado não pode ser negativo: $kwh kWh.',
      );
    }
    _consumoAcumuladoKwh += kwh;
  }

  /// Reseta o consumo acumulado para zero.
  void resetarConsumo() {
    _consumoAcumuladoKwh = 0.0;
  }
}

// ===========================================================================
// CLASSE ABSTRATA: DispositivoInteligente
// ===========================================================================

/// Classe abstrata que define o contrato base para todos os dispositivos
/// inteligentes do sistema Cici.
///
/// Todas as entidades concretas (Lampada, Termostato, Sensor) devem
/// estender esta classe, implementar [ligar], [desligar] e sobrescrever
/// [toString].
abstract class DispositivoInteligente {
  // ---- Atributos privados com encapsulamento estrito ----

  /// Identificador único do dispositivo.
  final String _id;

  /// Nome amigável do dispositivo (ex: "Luz da Sala").
  String _nome;

  /// Estado de ligado/desligado.
  bool _ligado;

  /// Cômodo onde o dispositivo está instalado (nullable).
  String? _comodo;

  // ---- Construtor padrão gerativo ----

  /// Cria um [DispositivoInteligente] com seus atributos base.
  ///
  /// - [id]: identificador único (imutável via `final`).
  /// - [nome]: nome amigável do dispositivo.
  /// - [ligado]: estado inicial (padrão: `false`).
  /// - [comodo]: cômodo de instalação (nullable).
  DispositivoInteligente({
    required String id,
    required String nome,
    bool ligado = false,
    String? comodo,
  })  : _id = id,
        _nome = nome,
        _ligado = ligado,
        _comodo = comodo;

  // ---- Getters (acesso controlado) ----

  /// Identificador único do dispositivo (somente leitura).
  String get id => _id;

  /// Nome amigável do dispositivo.
  String get nome => _nome;

  /// Indica se o dispositivo está ligado.
  bool get ligado => _ligado;

  /// Cômodo onde o dispositivo está instalado, ou `null`.
  String? get comodo => _comodo;

  // ---- Setters com validação ----

  /// Define o nome do dispositivo.
  ///
  /// Lança [EstadoInvalidoException] se o nome for vazio.
  set nome(String novoNome) {
    if (novoNome.trim().isEmpty) {
      throw EstadoInvalidoException(
        campo: 'nome',
        valorRecebido: novoNome,
        mensagem: 'O nome do dispositivo não pode ser vazio.',
      );
    }
    _nome = novoNome.trim();
  }

  /// Define o cômodo de instalação do dispositivo.
  set comodo(String? novoComodo) {
    _comodo = novoComodo?.trim();
  }

  // ---- Métodos abstratos (contratos) ----

  /// Liga o dispositivo. Cada subclasse define seu comportamento específico.
  void ligar();

  /// Desliga o dispositivo. Cada subclasse define seu comportamento específico.
  void desligar();

  // ---- Métodos protegidos para uso pelas subclasses ----

  /// Define o estado de ligado/desligado internamente.
  /// Deve ser usado apenas pelas subclasses nos métodos [ligar]/[desligar].
  // ignore: use_setters_to_change_properties
  void setLigado(bool valor) {
    _ligado = valor;
  }

  // ---- toString (contrato a ser sobrescrito) ----

  /// Representação textual base. Subclasses DEVEM sobrescrever com `@override`.
  @override
  String toString() =>
      'DispositivoInteligente(id: $_id, nome: $_nome, ligado: $_ligado)';

  // ---- Factory fromMap ----

  /// Factory que desserializa um [Map] genérico para o tipo correto
  /// de dispositivo, com base no campo `'tipo'`.
  ///
  /// Tipos suportados: `'lampada'`, `'termostato'`, `'sensor'`.
  ///
  /// Lança [EstadoInvalidoException] se o tipo não for reconhecido ou
  /// se campos obrigatórios estiverem ausentes.
  ///
  /// Nota: Este factory é declarado aqui apenas como documentação do
  /// contrato. A implementação real está em cada subclasse.
  // A implementação concreta está em cada subclasse (Lampada.fromMap, etc.).
}
