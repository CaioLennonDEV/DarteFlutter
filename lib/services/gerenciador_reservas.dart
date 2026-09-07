/// Serviço Central de Domínio: Gestão de Reservas, Horários e Filas de Espera.
///
/// Atende integralmente aos requisitos da avaliação:
/// - **Requisito 2**: Encapsulamento, tipagem estática e reuso via mixins.
/// - **Requisito 3**:
///   1. Sound Null Safety (sem `!`, uso de `T?`, `??`, `?.`, `??=`).
///   2. Programação Funcional (.where, .map, .fold, .any, .every).
///   3. Spread Operators (`...` e `...?`), Collection-If e Collection-For.
///   4. Tratamento de Exceções com try-on-catch-finally e `rethrow`.
///   5. Simulação de Restrições Móveis (falhas de conectividade).
library;

import '../exceptions/reserva_exceptions.dart';
import '../models/agendamento.dart';
import '../models/recurso_agendavel.dart';

/// Gerenciador central de salas, equipamentos, postos de trabalho e filas de espera.
class GerenciadorReservas with LogAuditoriaMixin, NotificacaoMovelMixin {
  final String organizacao;
  final List<RecursoAgendavel> _recursos = [];
  final List<Agendamento> _historicoReservas = [];
  final Map<String, List<SolicitacaoFilaEspera>> _filasEspera = {};
  final Map<String, dynamic> _configuracoes = {};

  GerenciadorReservas({required this.organizacao});

  // --- Operador de Atribuição Nula (??=) ---

  /// Registra uma preferência padrão caso a chave ainda não esteja definida.
  void definirConfiguracaoPadrao(String chave, dynamic valorPadrao) {
    _configuracoes[chave] ??= valorPadrao;
  }

  /// Retorna cópia não modificável das configurações do sistema.
  Map<String, dynamic> get configuracoes => Map.unmodifiable(_configuracoes);

  // --- Gerenciamento de Inventário de Recursos ---

  /// Cadastra um recurso agendável no sistema.
  void cadastrarRecurso(RecursoAgendavel recurso) {
    if (_recursos.any((r) => r.id == recurso.id)) {
      throw ArgumentError('Já existe um recurso cadastrado com o ID "${recurso.id}".');
    }
    _recursos.add(recurso);
    _filasEspera[recurso.id] = [];
    registrarLog('Recurso cadastrado com sucesso: ${recurso.nome} (ID: ${recurso.id}).');
  }

  /// Busca um recurso pelo seu ID de forma segura (retorna nulo se não encontrado).
  RecursoAgendavel? buscarRecursoPorId(String id) {
    for (final recurso in _recursos) {
      if (recurso.id == id) return recurso;
    }
    return null;
  }

  // --- Regras de Negócio: Criação e Gestão de Agendamentos ---

  /// Solicita uma nova reserva com validação rigorosa de regras de negócio e conflito de horário.
  Agendamento solicitarReserva({
    required String recursoId,
    required String solicitante,
    required DateTime inicio,
    required Duration duracao,
    int participantes = 1,
    Map<String, dynamic>? metadados,
  }) {
    final recurso = buscarRecursoPorId(recursoId);
    if (recurso == null) {
      throw ArgumentError('Recurso ID "$recursoId" não encontrado no sistema.');
    }

    // 1. Verificação de manutenção (Restrição de disponibilidade)
    if (recurso.emManutencao) {
      throw RecursoIndisponivelException(
        recursoId: recurso.id,
        motivo: 'O recurso está atualmente em manutenção técnica.',
        previsaoRetorno: inicio.add(const Duration(days: 1)),
      );
    }

    // 2. Verificação de capacidade máxima
    if (participantes > recurso.capacidade) {
      throw CapacidadeExcedidaException(
        recursoId: recurso.id,
        capacidadeMaxima: recurso.capacidade,
        participantesSolicitados: participantes,
      );
    }

    // 3. Verificação de conflito temporal de horários
    final fim = inicio.add(duracao);
    for (final agendamentoAtivo in recurso.agendamentos) {
      if (agendamentoAtivo.status == StatusAgendamento.confirmada &&
          agendamentoAtivo.conflitaCom(inicio, fim)) {
        throw ConflitoHorarioException(
          recursoId: recurso.id,
          nomeRecurso: recurso.nome,
          horarioInicio: agendamentoAtivo.inicio,
          horarioFim: agendamentoAtivo.fim,
          solicitanteConflitante: agendamentoAtivo.solicitante,
        );
      }
    }

    // 4. Cálculo polimórfico do custo
    final custo = recurso.calcularCustoReserva(duracao);

    // 5. Criação e persistência do agendamento
    final novoAgendamento = Agendamento(
      id: 'RES-${DateTime.now().millisecondsSinceEpoch}',
      recursoId: recurso.id,
      solicitante: solicitante,
      inicio: inicio,
      duracao: duracao,
      custoEstimado: custo,
      metadadosIniciais: metadados,
    );

    recurso.adicionarAgendamento(novoAgendamento);
    _historicoReservas.add(novoAgendamento);

    emitirNotificacaoPush(
      solicitante,
      'Reserva Confirmada! ✅',
      'Sua reserva para "${recurso.nome}" foi aprovada para ${inicio.day}/${inicio.month} às ${inicio.hour}:${inicio.minute.toString().padLeft(2, '0')}.',
    );

    return novoAgendamento;
  }

  // --- Regras de Negócio: Gestão de Fila de Espera ---

  /// Insere uma solicitação na fila de espera do recurso caso haja conflito de horário.
  SolicitacaoFilaEspera entrarNaFilaEspera({
    required String recursoId,
    required String solicitante,
    required DateTime horarioDesejado,
    required Duration duracao,
    int prioridade = 1,
  }) {
    final recurso = buscarRecursoPorId(recursoId);
    if (recurso == null) {
      throw ArgumentError('Recurso ID "$recursoId" não encontrado.');
    }

    final fila = _filasEspera[recursoId] ?? [];
    const limiteFila = 5;
    if (fila.length >= limiteFila) {
      throw FilaEsperaCheiaException(
        recursoId: recursoId,
        limiteFila: limiteFila,
      );
    }

    final solicitacao = SolicitacaoFilaEspera(
      id: 'FILA-${DateTime.now().millisecondsSinceEpoch}',
      recursoId: recursoId,
      solicitante: solicitante,
      horarioDesejado: horarioDesejado,
      duracaoDesejada: duracao,
      prioridade: prioridade,
      dataCriacao: DateTime.now(),
    );

    fila.add(solicitacao);
    // Ordenação funcional por prioridade decrescente e por antiguidade de solicitação
    fila.sort((a, b) {
      final compPrioridade = b.prioridade.compareTo(a.prioridade);
      if (compPrioridade != 0) return compPrioridade;
      return a.dataCriacao.compareTo(b.dataCriacao);
    });

    _filasEspera[recursoId] = fila;

    registrarLog(
      'Solicitante "$solicitante" adicionado à Fila de Espera do recurso "${recurso.nome}" (Posição: ${fila.length}, Prioridade: $prioridade).',
    );

    emitirNotificacaoPush(
      solicitante,
      'Entrada na Fila de Espera ⏳',
      'Você é o ${fila.length}º da fila para "${recurso.nome}". Você será notificado se o horário for liberado.',
    );

    return solicitacao;
  }

  /// Cancela uma reserva existente e promove automaticamente o próximo da fila de espera.
  Agendamento? cancelarReservaEPromoverFila(String recursoId, String agendamentoId) {
    final recurso = buscarRecursoPorId(recursoId);
    if (recurso == null) return null;

    final cancelado = recurso.cancelarAgendamento(agendamentoId);
    if (!cancelado) return null;

    registrarLog('Reserva "$agendamentoId" cancelada no recurso "${recurso.nome}". Verificando fila de espera...');

    final fila = _filasEspera[recursoId];
    if (fila != null && fila.isNotEmpty) {
      // Pega o primeiro elegível da fila
      final proximoFila = fila.removeAt(0);

      // Promove para reserva confirmada
      final custo = recurso.calcularCustoReserva(proximoFila.duracaoDesejada);
      final novaReserva = Agendamento(
        id: 'RES-PROMOVIDA-${DateTime.now().millisecondsSinceEpoch}',
        recursoId: recurso.id,
        solicitante: proximoFila.solicitante,
        inicio: proximoFila.horarioDesejado,
        duracao: proximoFila.duracaoDesejada,
        custoEstimado: custo,
        metadadosIniciais: {'promovidoDaFila': true, 'prioridadeOriginal': proximoFila.prioridade},
      );

      recurso.adicionarAgendamento(novaReserva);
      _historicoReservas.add(novaReserva);

      registrarLog(
        'VAGA LIBERADA! Solicitante "${proximoFila.solicitante}" promovido da fila de espera para reserva confirmada.',
      );

      emitirNotificacaoPush(
        proximoFila.solicitante,
        'Você conseguiu a vaga! 🎉',
        'O horário para "${recurso.nome}" foi liberado e sua reserva foi confirmada automaticamente!',
      );

      return novaReserva;
    }

    return null;
  }

  // --- Manipulação Funcional de Coleções (Requisito 3) ---

  /// Filtra recursos disponíveis em um dado intervalo utilizando método funcional `.where()`.
  List<RecursoAgendavel> obterRecursosDisponiveis(DateTime inicio, Duration duracao) {
    return _recursos.where((r) => r.estaDisponivel(inicio, duracao)).toList();
  }

  /// Filtra recursos por capacidade mínima requerida com `.where()`.
  List<RecursoAgendavel> obterRecursosPorCapacidade(int capacidadeMinima) {
    return _recursos.where((r) => r.capacidade >= capacidadeMinima).toList();
  }

  /// Projeção funcional com `.map()` para obter relação resumida de nomes e capacidades.
  List<String> mapearDescricaoRecursos() {
    return _recursos.map((r) => '• [${r.id}] ${r.nome} - Local: ${r.localizacao} (Cap: ${r.capacidade})').toList();
  }

  /// Agregação funcional com `.fold()` para calcular o custo total acumulado de reservas confirmadas.
  double calcularFaturamentoTotal() {
    return _historicoReservas
        .where((a) => a.status == StatusAgendamento.confirmada)
        .fold<double>(0.0, (acumulador, reserva) => acumulador + reserva.custoEstimado);
  }

  /// Agregação funcional com `.fold()` para somar a capacidade física instalada de todos os recursos.
  int calcularCapacidadeTotalInstalada() {
    return _recursos.fold<int>(0, (total, recurso) => total + recurso.capacidade);
  }

  /// Verificação booleana funcional com `.any()` para detectar se existe algum recurso em manutenção.
  bool existeRecursoEmManutencao() {
    return _recursos.any((r) => r.emManutencao);
  }

  /// Verificação booleana funcional com `.every()` para garantir que todos os recursos possuem capacidade válida.
  bool todosRecursosPossuemCapacidadeValida() {
    return _recursos.every((r) => r.capacidade > 0);
  }

  /// Demonstração de Spread Operators (`...` e `...?`) para consolidação de listas.
  List<RecursoAgendavel> consolidarComRecursosParceiros(List<RecursoAgendavel>? parceirosExternos) {
    // Mesclagem segura usando Spread Operator (...) e Null-aware Spread Operator (...?)
    return [
      ..._recursos,
      ...?parceirosExternos,
    ];
  }

  /// Geração de Relatório Executivo utilizando Collection-If e Collection-For.
  Map<String, dynamic> gerarRelatorioExecutivo({
    bool incluirDetalhamentoFila = true,
    bool incluirRecursosEmManutencao = false,
  }) {
    return {
      'organizacao': organizacao,
      'totalRecursos': _recursos.length,
      'capacidadeTotalInstalada': calcularCapacidadeTotalInstalada(),
      'faturamentoConfirmado': calcularFaturamentoTotal(),
      // Collection-For na transformação de dados de agendamentos
      'reservasConfirmadas': [
        for (final r in _historicoReservas)
          if (r.status == StatusAgendamento.confirmada)
            {
              'id': r.id,
              'recursoId': r.recursoId,
              'solicitante': r.solicitante,
              'duracaoMinutos': r.duracao.inMinutes,
              'custo': r.custoEstimado,
            }
      ],
      // Collection-If condicional para detalhamento de filas de espera
      if (incluirDetalhamentoFila)
        'filasEsperaAtivas': {
          for (final entry in _filasEspera.entries)
            if (entry.value.isNotEmpty)
              entry.key: [
                for (final item in entry.value)
                  {
                    'solicitante': item.solicitante,
                    'prioridade': item.prioridade,
                  }
              ]
        },
      // Collection-If condicional para listar recursos com alerta de manutenção
      if (incluirRecursosEmManutencao)
        'recursosEmManutencao': [
          for (final r in _recursos)
            if (r.emManutencao) r.nome
        ],
    };
  }

  // --- Simulação de Restrições de Hardware Móvel & Conectividade (Requisito 3) ---

  /// Simula sincronização em nuvem pelo aplicativo móvel, demonstrando
  /// blocos `try-on-catch-finally` com `rethrow`.
  void sincronizarComServidorNuvem({required bool simularQuedaRede}) {
    registrarLog('Iniciando sincronização de reservas com servidor de nuvem...');

    try {
      if (simularQuedaRede) {
        throw const FalhaSincronizacaoMovelException(
          operacao: 'Sincronização Bidirecional de Agenda e Filas',
          tentativasRealizadas: 3,
          detalheErro: 'Timeout de handshake SSL (Sem sinal 4G/5G no subsolo).',
        );
      }
      registrarLog('Sincronização com a nuvem finalizada com 100% de sucesso.');
    } on FalhaSincronizacaoMovelException catch (ex) {
      registrarLog('FALHA DE REDE MÓVEL CAPTURADA: $ex');
      registrarLog('Registrando pendência em cache local para envio posterior (Offline-First).');
      // Requisito do Edital: Relançamento obrigatório com rethrow
      rethrow;
    } finally {
      registrarLog('Finalizando rotina de sincronização e liberando recursos de socket de rede.');
    }
  }

  // --- Getters de Leitura Segura ---
  List<RecursoAgendavel> get todosRecursos => List.unmodifiable(_recursos);
  List<Agendamento> get todasReservas => List.unmodifiable(_historicoReservas);
  Map<String, List<SolicitacaoFilaEspera>> get filasEspera => Map.unmodifiable(_filasEspera);
}
