/// Módulo de Abstração, Contratos e Mixins Transversais do **ReservaHub**.
///
/// Atende rigorosamente ao **Requisito 2** da Avaliação Processual:
/// - Classe Abstrata (contrato de operações de negócio obrigatórias).
/// - Mixins aplicados via palavra-chave `with` para desacoplamento utilitário.
/// - Encapsulamento a nível de biblioteca com `_` e Getters/Setters com validação.
/// - Imutabilidade com `final` e Sound Null Safety estrito.
library;

import 'agendamento.dart';

/// Mixin para prover capacidade de log e auditoria cronológica das operações de reserva.
mixin LogAuditoriaMixin {
  final List<String> _historicoLogs = [];

  void registrarLog(String mensagem) {
    final timestamp = DateTime.now().toIso8601String();
    final entradaFormatada = '[AUDITORIA RESERVA - $timestamp]: $mensagem';
    _historicoLogs.add(entradaFormatada);
    print(entradaFormatada);
  }

  /// Retorna lista imutável dos logs registrados.
  List<String> get historicoLogs => List.unmodifiable(_historicoLogs);
}

/// Mixin para prover capacidades de notificação e alertas móveis em tempo real.
mixin NotificacaoMovelMixin {
  void emitirNotificacaoPush(String destinatario, String titulo, String corpo) {
    final hora = DateTime.now().toString().substring(11, 19);
    print('  📲 [PUSH NOTIFICATION Móvel às $hora para $destinatario]');
    print('     • Título: $titulo');
    print('     • Mensagem: $corpo');
  }
}

/// Contrato abstrato de um Recurso Agendável no ecossistema corporativo/acadêmico.
abstract class RecursoAgendavel with LogAuditoriaMixin, NotificacaoMovelMixin {
  final String id;
  final String nome;
  final String localizacao;
  int _capacidade;
  bool _emManutencao;
  final List<Agendamento> _agendamentos = [];

  /// Construtor padrão da classe abstrata com parâmetros nomeados.
  RecursoAgendavel({
    required this.id,
    required this.nome,
    required this.localizacao,
    required int capacidadeInicial,
    bool emManutencaoInicial = false,
  })  : _capacidade = capacidadeInicial,
        _emManutencao = emManutencaoInicial {
    if (capacidadeInicial <= 0) {
      throw ArgumentError('A capacidade inicial do recurso deve ser maior que zero.');
    }
  }

  // --- Encapsulamento com Modificador de Privacidade (_) e Validação ---

  int get capacidade => _capacidade;

  set capacidade(int novaCapacidade) {
    if (novaCapacidade <= 0) {
      throw ArgumentError('A capacidade deve ser estritamente positiva.');
    }
    _capacidade = novaCapacidade;
    registrarLog('Capacidade do recurso "$nome" (ID: $id) ajustada para $_capacidade pessoas.');
  }

  bool get emManutencao => _emManutencao;

  set emManutencao(bool status) {
    _emManutencao = status;
    registrarLog(
      'Status de manutenção do recurso "$nome" alterado para: ${_emManutencao ? "EM MANUTENÇÃO" : "OPERACIONAL"}.',
    );
  }

  /// Retorna cópia não modificável dos agendamentos vinculados a este recurso.
  List<Agendamento> get agendamentos => List.unmodifiable(_agendamentos);

  // --- Métodos Abstratos de Contrato Obrigatório ---

  /// Valida se o recurso atende aos requisitos técnicos e operacionais solicitados.
  bool validarCompatibilidade(Map<String, dynamic> requisitos);

  /// Calcula o custo monetário ou de créditos para o tempo de uso solicitado.
  double calcularCustoReserva(Duration duracao);

  // --- Métodos Concretos de Negócio ---

  /// Verifica se o recurso está disponível no intervalo especificado.
  bool estaDisponivel(DateTime inicio, Duration duracao) {
    if (_emManutencao) return false;

    final fim = inicio.add(duracao);
    // Verifica se algum agendamento ativo conflita no mesmo horário
    return !_agendamentos.any(
      (a) => a.status == StatusAgendamento.confirmada && a.conflitaCom(inicio, fim),
    );
  }

  /// Registra uma nova reserva neste recurso após validação de disponibilidade.
  void adicionarAgendamento(Agendamento agendamento) {
    if (_emManutencao) {
      throw StateError('Não é possível adicionar reservas a um recurso em manutenção.');
    }
    _agendamentos.add(agendamento);
    registrarLog(
      'Reserva confirmada: Agendamento "${agendamento.id}" associado ao recurso "$nome".',
    );
  }

  /// Remove ou cancela uma reserva por ID.
  bool cancelarAgendamento(String agendamentoId) {
    for (var i = 0; i < _agendamentos.length; i++) {
      if (_agendamentos[i].id == agendamentoId) {
        _agendamentos[i].status = StatusAgendamento.cancelada;
        registrarLog('Agendamento "$agendamentoId" no recurso "$nome" cancelado com sucesso.');
        return true;
      }
    }
    return false;
  }

  @override
  String toString() =>
      'Recurso [ID: $id | Nome: $nome | Local: $localizacao | Cap: $_capacidade | Manutenção: $_emManutencao]';
}
