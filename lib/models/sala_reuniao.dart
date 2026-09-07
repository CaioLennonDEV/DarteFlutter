/// Especialização de Domínio: Sala de Reunião e Espaço Colaborativo.
///
/// Atende ao **Requisito 2**:
/// - Herança com `extends`, inicializadores com `super` e sobrescrita de métodos com `@override`.
/// - Variedade de Construtores: Padrão Gerativo, Nomeado e Factory com validação condicional.
/// - Encapsulamento de biblioteca (`_`) e `@override toString()`.
library;

import 'recurso_agendavel.dart';

/// Classe concreta especializada para Salas de Reunião e Conferência.
class SalaReuniao extends RecursoAgendavel {
  final bool possuiProjetor;
  final bool possuiVideoconferencia;
  int _qtdCadeirasExtras;

  /// 1. Construtor Padrão Gerativo com parâmetros super e açúcar sintático.
  SalaReuniao({
    required super.id,
    required super.nome,
    required super.localizacao,
    required super.capacidadeInicial,
    super.emManutencaoInicial,
    required this.possuiProjetor,
    required this.possuiVideoconferencia,
    int cadeirasExtrasIniciais = 0,
  }) : _qtdCadeirasExtras = cadeirasExtrasIniciais;

  /// 2. Construtor Nomeado: Auditório / Sala de Alta Capacidade.
  SalaReuniao.auditorio({
    required String id,
    required String nome,
    required String localizacao,
    int capacidade = 100,
  })  : possuiProjetor = true,
        possuiVideoconferencia = true,
        _qtdCadeirasExtras = 20,
        super(
          id: id,
          nome: nome,
          localizacao: localizacao,
          capacidadeInicial: capacidade,
          emManutencaoInicial: false,
        );

  /// 2. Construtor Nomeado: Sala Executiva de Diretoria.
  SalaReuniao.executiva({
    required String id,
    required String nome,
    required String localizacao,
  })  : possuiProjetor = true,
        possuiVideoconferencia = true,
        _qtdCadeirasExtras = 4,
        super(
          id: id,
          nome: nome,
          localizacao: localizacao,
          capacidadeInicial: 12,
          emManutencaoInicial: false,
        );

  /// 3. Construtor Factory com parsing e validação semântica a partir de Map.
  factory SalaReuniao.fromMap(Map<String, dynamic> map) {
    final cap = map['capacidade'] as int? ?? 10;
    if (cap <= 0) {
      throw ArgumentError('Capacidade da sala de reunião deve ser estritamente positiva.');
    }

    return SalaReuniao(
      id: map['id'] as String? ?? 'SALA-000',
      nome: map['nome'] as String? ?? 'Sala de Reunião Padrão',
      localizacao: map['localizacao'] as String? ?? 'Bloco Central',
      capacidadeInicial: cap,
      emManutencaoInicial: map['emManutencao'] as bool? ?? false,
      possuiProjetor: map['possuiProjetor'] as bool? ?? true,
      possuiVideoconferencia: map['possuiVideoconferencia'] as bool? ?? false,
      cadeirasExtrasIniciais: map['cadeirasExtras'] as int? ?? 0,
    );
  }

  // --- Encapsulamento de Atributo Específico ---
  int get qtdCadeirasExtras => _qtdCadeirasExtras;

  set qtdCadeirasExtras(int valor) {
    if (valor < 0) {
      throw ArgumentError('A quantidade de cadeiras extras não pode ser negativa.');
    }
    _qtdCadeirasExtras = valor;
    registrarLog('Cadeiras extras da sala "$nome" atualizadas para $_qtdCadeirasExtras unidades.');
  }

  /// Capacidade total efetiva (capacidade base + assentos extras disponíveis).
  int get capacidadeTotalEfetiva => capacidade + _qtdCadeirasExtras;

  @override
  bool validarCompatibilidade(Map<String, dynamic> requisitos) {
    final precisaProjetor = requisitos['projetor'] as bool? ?? false;
    final precisaVideo = requisitos['videoconferencia'] as bool? ?? false;
    final vagasNecessarias = requisitos['participantes'] as int? ?? 1;

    if (precisaProjetor && !possuiProjetor) return false;
    if (precisaVideo && !possuiVideoconferencia) return false;
    if (vagasNecessarias > capacidadeTotalEfetiva) return false;

    return true;
  }

  @override
  double calcularCustoReserva(Duration duracao) {
    // Tarifa base: R$ 50,00 por hora + R$ 20,00 se tiver videoconferência
    final horas = duracao.inMinutes / 60.0;
    final taxaBase = 50.0;
    final adicionalVideo = possuiVideoconferencia ? 20.0 : 0.0;
    return (taxaBase + adicionalVideo) * horas;
  }

  @override
  String toString() =>
      '${super.toString()} | SalaReuniao [Projetor: $possuiProjetor | Vídeo: $possuiVideoconferencia | Cadeiras Extras: $_qtdCadeirasExtras | Cap. Efetiva: $capacidadeTotalEfetiva]';
}
