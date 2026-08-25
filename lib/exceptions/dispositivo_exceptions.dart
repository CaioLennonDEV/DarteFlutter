/// Biblioteca de exceções customizadas do sistema Cici.
///
/// Define exceções semânticas para regras de negócio de dispositivos
/// residenciais inteligentes, evitando o uso genérico de [Exception].
library;

// ---------------------------------------------------------------------------
// DispositivoOfflineException
// ---------------------------------------------------------------------------

/// Lançada quando uma operação é tentada em um dispositivo que está desligado.
///
/// Exemplo de uso:
/// ```dart
/// if (!dispositivo.ligado) {
///   throw DispositivoOfflineException(nomeDispositivo: dispositivo.nome);
/// }
/// ```
class DispositivoOfflineException implements Exception {
  /// Nome do dispositivo que causou a exceção.
  final String nomeDispositivo;

  /// Mensagem descritiva do erro.
  final String mensagem;

  DispositivoOfflineException({
    required this.nomeDispositivo,
    String? mensagem,
  }) : mensagem = mensagem ??
            'O dispositivo "$nomeDispositivo" está offline/desligado. '
                'Ligue-o antes de executar esta operação.';

  @override
  String toString() => 'DispositivoOfflineException: $mensagem';
}

// ---------------------------------------------------------------------------
// EstadoInvalidoException
// ---------------------------------------------------------------------------

/// Lançada quando um valor atribuído a um dispositivo viola as regras de negócio.
///
/// Exemplo: temperatura do termostato fora do range 16°C–32°C, brilho fora
/// de 0–100%, etc.
class EstadoInvalidoException implements Exception {
  /// Nome do campo/atributo que recebeu valor inválido.
  final String campo;

  /// Valor que foi rejeitado.
  final dynamic valorRecebido;

  /// Mensagem descritiva do erro.
  final String mensagem;

  EstadoInvalidoException({
    required this.campo,
    required this.valorRecebido,
    String? mensagem,
  }) : mensagem = mensagem ??
            'Valor inválido para "$campo": $valorRecebido.';

  @override
  String toString() => 'EstadoInvalidoException: $mensagem';
}

// ---------------------------------------------------------------------------
// DispositivoNaoEncontradoException
// ---------------------------------------------------------------------------

/// Lançada quando uma busca por ID não encontra o dispositivo na coleção.
class DispositivoNaoEncontradoException implements Exception {
  /// ID que foi pesquisado.
  final String idProcurado;

  /// Mensagem descritiva do erro.
  final String mensagem;

  DispositivoNaoEncontradoException({
    required this.idProcurado,
    String? mensagem,
  }) : mensagem = mensagem ??
            'Nenhum dispositivo encontrado com o ID "$idProcurado".';

  @override
  String toString() => 'DispositivoNaoEncontradoException: $mensagem';
}
