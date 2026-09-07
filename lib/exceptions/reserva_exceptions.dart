/// Biblioteca de Exceções Customizadas de Domínio do sistema **ReservaHub**.
///
/// Atende rigorosamente ao **Requisito 3** (Tratamento de Exceções com
/// Sound Null Safety, blocos try-on-catch-finally e rethrow) e modela
/// restrições reais de hardware e conectividade do ecossistema móvel.
library;

/// Exceção lançada quando ocorre sobreposição de horários entre reservas
/// solicitadas para o mesmo recurso agendável.
class ConflitoHorarioException implements Exception {
  final String recursoId;
  final String nomeRecurso;
  final DateTime horarioInicio;
  final DateTime horarioFim;
  final String solicitanteConflitante;

  const ConflitoHorarioException({
    required this.recursoId,
    required this.nomeRecurso,
    required this.horarioInicio,
    required this.horarioFim,
    required this.solicitanteConflitante,
  });

  @override
  String toString() =>
      'ConflitoHorarioException: O recurso "$nomeRecurso" (ID: $recursoId) '
      'já possui reserva ativa entre ${_formatarData(horarioInicio)} e '
      '${_formatarData(horarioFim)} solicitada por "$solicitanteConflitante".';
}

/// Exceção disparada quando um recurso agendável está temporariamente fora de
/// operação (em manutenção preventiva, corretiva ou desativado).
class RecursoIndisponivelException implements Exception {
  final String recursoId;
  final String motivo;
  final DateTime? previsaoRetorno;

  const RecursoIndisponivelException({
    required this.recursoId,
    required this.motivo,
    this.previsaoRetorno,
  });

  @override
  String toString() {
    final previsaoStr = previsaoRetorno != null
        ? ' (Previsão de retorno: ${_formatarData(previsaoRetorno!)})'
        : '';
    return 'RecursoIndisponivelException: O recurso ID "$recursoId" está indisponível. '
        'Motivo: $motivo$previsaoStr';
  }
}

/// Exceção lançada ao tentar alocar um número de participantes superior à
/// capacidade máxima homologada do espaço ou sala.
class CapacidadeExcedidaException implements Exception {
  final String recursoId;
  final int capacidadeMaxima;
  final int participantesSolicitados;

  const CapacidadeExcedidaException({
    required this.recursoId,
    required this.capacidadeMaxima,
    required this.participantesSolicitados,
  });

  @override
  String toString() =>
      'CapacidadeExcedidaException: O recurso ID "$recursoId" suporta no máximo '
      '$capacidadeMaxima pessoas, mas foram solicitadas $participantesSolicitados vagas.';
}

/// Exceção lançada quando a fila de espera para um determinado recurso atinge
/// sua cota máxima de solicitações pendentes.
class FilaEsperaCheiaException implements Exception {
  final String recursoId;
  final int limiteFila;

  const FilaEsperaCheiaException({
    required this.recursoId,
    required this.limiteFila,
  });

  @override
  String toString() =>
      'FilaEsperaCheiaException: A fila de espera do recurso "$recursoId" atingiu '
      'o limite máximo configurado ($limiteFila solicitações). Tente outro horário.';
}

/// Exceção representativa de restrições de conectividade em dispositivos móveis
/// (queda de conexão 4G/5G, ausência de sinal de rede ou timeout de sincronização).
class FalhaSincronizacaoMovelException implements Exception {
  final String operacao;
  final int tentativasRealizadas;
  final String detalheErro;

  const FalhaSincronizacaoMovelException({
    required this.operacao,
    required this.tentativasRealizadas,
    required this.detalheErro,
  });

  @override
  String toString() =>
      'FalhaSincronizacaoMovelException: Falha de rede ao executar "$operacao" '
      'após $tentativasRealizadas tentativa(s). Detalhes de conectividade: $detalheErro';
}

/// Função utilitária privada de formatação simples de data/hora (sem acoplamento externo).
String _formatarData(DateTime data) {
  final dia = data.day.toString().padLeft(2, '0');
  final mes = data.month.toString().padLeft(2, '0');
  final ano = data.year;
  final hora = data.hour.toString().padLeft(2, '0');
  final minuto = data.minute.toString().padLeft(2, '0');
  return '$dia/$mes/$ano $hora:$minuto';
}
