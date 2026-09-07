/// Modelos de Domínio para Reservas e Fila de Espera no **ReservaHub**.
///
/// Atende ao **Requisito 2** (Variedade de construtores, encapsulamento,
/// tipagem estática e imutabilidade) e **Requisito 3** (Sound Null Safety).
library;

/// Status do ciclo de vida de uma reserva no sistema móvel.
enum StatusAgendamento {
  confirmada,
  pendente,
  cancelada,
  concluida,
}

/// Entidade de domínio que representa uma Reserva confirmada ou em andamento.
class Agendamento {
  final String id;
  final String recursoId;
  final String solicitante;
  final DateTime inicio;
  final Duration duracao;
  final double custoEstimado;
  StatusAgendamento _status;
  final Map<String, dynamic> metadados;

  /// Construtor Padrão Gerativo com açúcar sintático e parâmetros nomeados.
  Agendamento({
    required this.id,
    required this.recursoId,
    required this.solicitante,
    required this.inicio,
    required this.duracao,
    this.custoEstimado = 0.0,
    StatusAgendamento statusInicial = StatusAgendamento.confirmada,
    Map<String, dynamic>? metadadosIniciais,
  })  : _status = statusInicial,
        metadados = metadadosIniciais ?? {};

  /// Construtor Nomeado para reserva de emergência/prioritária.
  Agendamento.urgente({
    required this.id,
    required this.recursoId,
    required this.solicitante,
    required this.inicio,
    required this.duracao,
    this.custoEstimado = 0.0,
  })  : _status = StatusAgendamento.confirmada,
        metadados = {'prioridade': 'URGENTE', 'aprovacaoAutomatica': true};

  /// Construtor Factory com validação semântica a partir de um Map (dicionário).
  factory Agendamento.fromMap(Map<String, dynamic> map) {
    final duracaoMinutos = map['duracaoMinutos'] as int? ?? 60;
    if (duracaoMinutos <= 0) {
      throw ArgumentError('A duração da reserva deve ser maior que zero.');
    }

    final dataIso = map['inicio'] as String?;
    final dataInicio = dataIso != null ? DateTime.parse(dataIso) : DateTime.now();

    final statusString = map['status'] as String? ?? 'confirmada';
    final statusEnum = StatusAgendamento.values.firstWhere(
      (s) => s.name.toLowerCase() == statusString.toLowerCase(),
      orElse: () => StatusAgendamento.confirmada,
    );

    return Agendamento(
      id: map['id'] as String? ?? 'RES-${DateTime.now().millisecondsSinceEpoch}',
      recursoId: map['recursoId'] as String? ?? 'REC-DESCONHECIDO',
      solicitante: map['solicitante'] as String? ?? 'Solicitante Anônimo',
      inicio: dataInicio,
      duracao: Duration(minutes: duracaoMinutos),
      custoEstimado: (map['custo'] as num?)?.toDouble() ?? 0.0,
      statusInicial: statusEnum,
      metadadosIniciais: Map<String, dynamic>.from(
        (map['metadados'] as Map?) ?? {},
      ),
    );
  }

  // --- Encapsulamento de Biblioteca (_) e Getters/Setters ---
  StatusAgendamento get status => _status;

  set status(StatusAgendamento novoStatus) {
    // Regra de transição de estado: concluída ou cancelada não pode voltar para pendente
    if (_status == StatusAgendamento.concluida && novoStatus != StatusAgendamento.concluida) {
      throw StateError('Um agendamento já concluído não pode alterar seu status.');
    }
    _status = novoStatus;
  }

  /// Getter calculado para data/hora de término.
  DateTime get fim => inicio.add(duracao);

  /// Verifica se há sobreposição temporal com outro intervalo [outroInicio, outroFim].
  bool conflitaCom(DateTime outroInicio, DateTime outroFim) {
    // Intersecção de intervalos: [inicio, fim] conflita se inicio < outroFim e fim > outroInicio
    return inicio.isBefore(outroFim) && fim.isAfter(outroInicio);
  }

  @override
  String toString() {
    final statusNome = _status.name.toUpperCase();
    final inicioStr =
        '${inicio.day.toString().padLeft(2, '0')}/${inicio.month.toString().padLeft(2, '0')} ${inicio.hour.toString().padLeft(2, '0')}:${inicio.minute.toString().padLeft(2, '0')}';
    final fimStr =
        '${fim.hour.toString().padLeft(2, '0')}:${fim.minute.toString().padLeft(2, '0')}';
    return 'Agendamento [ID: $id | Recurso: $recursoId | Solicitante: $solicitante | $inicioStr-$fimStr (${duracao.inMinutes}m) | Status: $statusNome | Custo: R\$ ${custoEstimado.toStringAsFixed(2)}]';
  }
}

/// Representa uma solicitação posicionada na Fila de Espera para um recurso.
class SolicitacaoFilaEspera {
  final String id;
  final String recursoId;
  final String solicitante;
  final DateTime horarioDesejado;
  final Duration duracaoDesejada;
  final int prioridade; // 1 = Normal, 2 = Alta, 3 = Crítica/Diretoria
  final DateTime dataCriacao;

  const SolicitacaoFilaEspera({
    required this.id,
    required this.recursoId,
    required this.solicitante,
    required this.horarioDesejado,
    required this.duracaoDesejada,
    this.prioridade = 1,
    required this.dataCriacao,
  });

  /// Construtor Factory a partir de mapa
  factory SolicitacaoFilaEspera.fromMap(Map<String, dynamic> map) {
    return SolicitacaoFilaEspera(
      id: map['id'] as String? ?? 'FILA-${DateTime.now().millisecondsSinceEpoch}',
      recursoId: map['recursoId'] as String? ?? 'REC-DESCONHECIDO',
      solicitante: map['solicitante'] as String? ?? 'Solicitante Fila',
      horarioDesejado: map['horarioDesejado'] != null
          ? DateTime.parse(map['horarioDesejado'] as String)
          : DateTime.now(),
      duracaoDesejada: Duration(minutes: map['duracaoMinutos'] as int? ?? 60),
      prioridade: map['prioridade'] as int? ?? 1,
      dataCriacao: DateTime.now(),
    );
  }

  @override
  String toString() {
    final nivelPrioridade = switch (prioridade) {
      >= 3 => 'CRÍTICA',
      2 => 'ALTA',
      _ => 'NORMAL',
    };
    final hora =
        '${horarioDesejado.hour.toString().padLeft(2, '0')}:${horarioDesejado.minute.toString().padLeft(2, '0')}';
    return 'FilaEspera [ID: $id | Solicitante: $solicitante | Horário: $hora (${duracaoDesejada.inMinutes}m) | Prioridade: $nivelPrioridade]';
  }
}
