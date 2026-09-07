/// Especialização de Domínio: Estação de Trabalho e Coworking (Hot-desking).
///
/// Atende ao **Requisito 2**:
/// - Herança com `extends`, inicializadores com `super` e sobrescrita de métodos com `@override`.
/// - Variedade de Construtores: Padrão Gerativo, Nomeado e Factory com validação.
/// - Encapsulamento de biblioteca (`_`) e `@override toString()`.
library;

import 'recurso_agendavel.dart';

/// Classe concreta especializada para Estações de Trabalho / Mesas de Coworking.
class EstacaoTrabalho extends RecursoAgendavel {
  final bool possuiMonitorDuplo;
  final bool cabeamentoRedeGiga;
  final String tipoMesa; // Ex.: "Ergonômica com Ajuste de Altura", "Padrão"
  bool _possuiCadeiraErgonomica;

  /// 1. Construtor Padrão Gerativo com parâmetros super e açúcar sintático.
  EstacaoTrabalho({
    required super.id,
    required super.nome,
    required super.localizacao,
    required this.possuiMonitorDuplo,
    required this.cabeamentoRedeGiga,
    required this.tipoMesa,
    super.capacidadeInicial = 1,
    super.emManutencaoInicial,
    bool possuiCadeiraErgonomica = true,
  }) : _possuiCadeiraErgonomica = possuiCadeiraErgonomica;

  /// 2. Construtor Nomeado: Hot Desk Executivo para Desenvolvedores.
  EstacaoTrabalho.hotDeskDev({
    required String id,
    required String nome,
    required String localizacao,
  })  : possuiMonitorDuplo = true,
        cabeamentoRedeGiga = true,
        tipoMesa = 'Ergonômica Standing Desk',
        _possuiCadeiraErgonomica = true,
        super(
          id: id,
          nome: nome,
          localizacao: localizacao,
          capacidadeInicial: 1,
          emManutencaoInicial: false,
        );

  /// 2. Construtor Nomeado: Estação Simples para Visitantes.
  EstacaoTrabalho.visitante({
    required String id,
    required String nome,
  })  : possuiMonitorDuplo = false,
        cabeamentoRedeGiga = false,
        tipoMesa = 'Mesa Básica Compartilhada',
        _possuiCadeiraErgonomica = false,
        super(
          id: id,
          nome: nome,
          localizacao: 'Área Aberta de Coworking',
          capacidadeInicial: 1,
          emManutencaoInicial: false,
        );

  /// 3. Construtor Factory com parsing e validação semântica de Map.
  factory EstacaoTrabalho.fromMap(Map<String, dynamic> map) {
    return EstacaoTrabalho(
      id: map['id'] as String? ?? 'EST-000',
      nome: map['nome'] as String? ?? 'Estação de Trabalho Padrão',
      localizacao: map['localizacao'] as String? ?? 'Coworking Central',
      possuiMonitorDuplo: map['monitorDuplo'] as bool? ?? false,
      cabeamentoRedeGiga: map['redeGiga'] as bool? ?? true,
      tipoMesa: map['tipoMesa'] as String? ?? 'Padrão Escritório',
      capacidadeInicial: 1,
      emManutencaoInicial: map['emManutencao'] as bool? ?? false,
      possuiCadeiraErgonomica: map['cadeiraErgonomica'] as bool? ?? true,
    );
  }

  // --- Encapsulamento de Atributo Específico ---
  bool get possuiCadeiraErgonomica => _possuiCadeiraErgonomica;

  set possuiCadeiraErgonomica(bool valor) {
    _possuiCadeiraErgonomica = valor;
    registrarLog('Configuração de cadeira ergonômica da estação "$nome" alterada para: $valor.');
  }

  @override
  bool validarCompatibilidade(Map<String, dynamic> requisitos) {
    final precisaMonitorDuplo = requisitos['monitorDuplo'] as bool? ?? false;
    final precisaRedeGiga = requisitos['redeGiga'] as bool? ?? false;

    if (precisaMonitorDuplo && !possuiMonitorDuplo) return false;
    if (precisaRedeGiga && !cabeamentoRedeGiga) return false;

    return true;
  }

  @override
  double calcularCustoReserva(Duration duracao) {
    // Tarifa: R$ 15,00 por hora + adicional se tiver mesa standing desk ou monitor duplo
    final horas = duracao.inMinutes / 60.0;
    var taxaBase = 15.0;
    if (possuiMonitorDuplo) taxaBase += 5.0;
    if (tipoMesa.contains('Standing')) taxaBase += 5.0;
    return taxaBase * horas;
  }

  @override
  String toString() =>
      '${super.toString()} | EstacaoTrabalho [Mesa: $tipoMesa | Monitores: ${possuiMonitorDuplo ? "Duplo" : "Único"} | Rede: ${cabeamentoRedeGiga ? "1Gbps" : "Wi-Fi"} | Cadeira Erg.: $_possuiCadeiraErgonomica]';
}
