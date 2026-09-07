/// Especialização de Domínio: Equipamento Compartilhado (Audiovisual, TI ou Laboratório).
///
/// Atende ao **Requisito 2**:
/// - Herança com `extends`, inicializadores com `super` e sobrescrita de métodos com `@override`.
/// - Variedade de Construtores: Padrão Gerativo, Nomeado e Factory com validação.
/// - Encapsulamento de biblioteca (`_`) e `@override toString()`.
library;

import 'recurso_agendavel.dart';

/// Classe concreta especializada para Equipamentos Móveis e de Laboratório.
class Equipamento extends RecursoAgendavel {
  final String categoria;
  final String numeroSerie;
  final double potenciaWatts;
  int _horasUsoAcumuladas;

  /// 1. Construtor Padrão Gerativo com parâmetros super e açúcar sintático.
  Equipamento({
    required super.id,
    required super.nome,
    required super.localizacao,
    required this.categoria,
    required this.numeroSerie,
    required this.potenciaWatts,
    super.capacidadeInicial = 1,
    super.emManutencaoInicial,
    int horasUsoIniciais = 0,
  }) : _horasUsoAcumuladas = horasUsoIniciais;

  /// 2. Construtor Nomeado: Equipamento de Laboratório Especializado.
  Equipamento.laboratorio({
    required String id,
    required String nome,
    required this.numeroSerie,
    required String localizacao,
  })  : categoria = 'Laboratório Avançado',
        potenciaWatts = 850.0,
        _horasUsoAcumuladas = 0,
        super(
          id: id,
          nome: nome,
          localizacao: localizacao,
          capacidadeInicial: 1,
          emManutencaoInicial: false,
        );

  /// 2. Construtor Nomeado: Kit de Realidade Virtual / Audiovisual Portátil.
  Equipamento.kitAudiovisual({
    required String id,
    required String nome,
    required this.numeroSerie,
  })  : categoria = 'Audiovisual Portátil',
        potenciaWatts = 120.0,
        _horasUsoAcumuladas = 15,
        super(
          id: id,
          nome: nome,
          localizacao: 'Armário de TI - Bloco B',
          capacidadeInicial: 1,
          emManutencaoInicial: false,
        );

  /// 3. Construtor Factory com validação semântica e parsing de dicionário Map.
  factory Equipamento.fromMap(Map<String, dynamic> map) {
    final horas = map['horasUso'] as int? ?? 0;
    if (horas < 0) {
      throw ArgumentError('Horas de uso acumuladas não podem ser negativas.');
    }

    // Regra de fábrica: se horas de uso > 1500, inicializa já marcado em manutenção preventiva
    final requerManutencao = horas >= 1500;

    return Equipamento(
      id: map['id'] as String? ?? 'EQP-000',
      nome: map['nome'] as String? ?? 'Equipamento Padrão',
      localizacao: map['localizacao'] as String? ?? 'Depósito Geral',
      categoria: map['categoria'] as String? ?? 'Diversos',
      numeroSerie: map['numeroSerie'] as String? ?? 'SN-GENERICO',
      potenciaWatts: (map['potenciaWatts'] as num?)?.toDouble() ?? 100.0,
      capacidadeInicial: 1,
      emManutencaoInicial: map['emManutencao'] as bool? ?? requerManutencao,
      horasUsoIniciais: horas,
    );
  }

  // --- Encapsulamento de Atributo Específico ---
  int get horasUsoAcumuladas => _horasUsoAcumuladas;

  set horasUsoAcumuladas(int valor) {
    if (valor < 0) {
      throw ArgumentError('Horas de uso não podem ser negativas.');
    }
    _horasUsoAcumuladas = valor;
    registrarLog('Horas de uso do equipamento "$nome" atualizadas para $_horasUsoAcumuladas h.');
  }

  /// Registra uso e atualiza telemetria de desgaste do equipamento.
  void registrarHorasUso(int horas) {
    if (horas <= 0) return;
    _horasUsoAcumuladas += horas;
    registrarLog('Uso registrado: +$horas h adicionadas ao equipamento "$nome". Total: $_horasUsoAcumuladas h.');
    if (_horasUsoAcumuladas >= 1500) {
      emManutencao = true;
      registrarLog('ALERTA: Equipamento "$nome" atingiu limite de 1500h. Bloqueado para manutenção.');
    }
  }

  @override
  bool validarCompatibilidade(Map<String, dynamic> requisitos) {
    final categoriaDesejada = requisitos['categoria'] as String?;
    if (categoriaDesejada != null &&
        !categoria.toLowerCase().contains(categoriaDesejada.toLowerCase())) {
      return false;
    }
    return true;
  }

  @override
  double calcularCustoReserva(Duration duracao) {
    // Tarifa: R$ 25,00 por hora de locação de equipamento + taxa de consumo elétrico
    final horas = duracao.inMinutes / 60.0;
    final custoBaseHora = 25.0;
    final consumoKwh = (potenciaWatts / 1000.0) * horas;
    final custoEnergia = consumoKwh * 0.95; // R$ 0,95 por kWh
    return (custoBaseHora * horas) + custoEnergia;
  }

  @override
  String toString() =>
      '${super.toString()} | Equipamento [Cat: $categoria | Série: $numeroSerie | Potência: ${potenciaWatts}W | Uso: ${_horasUsoAcumuladas}h]';
}
