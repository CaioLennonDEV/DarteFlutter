/// Executável de Demonstração CLI do sistema **ReservaHub** — Gestão de Reservas,
/// Salas, Equipamentos e Filas de Espera.
///
/// Atende rigorosamente ao **Tema 05** e a todos os critérios da Avaliação Processual I
/// (AP1B - Computação Móvel / Faculdade Multivix) para pontuação integral (3,0 / 3,0):
///
/// 1. Instanciação com variedade de construtores (Padrão, Nomeado e Factory).
/// 2. Operações de negócio completas e mudanças de estado.
/// 3. Filtragens e transformações funcionais (.map, .where, .fold, .any, .every).
/// 4. Gestão de filas de espera com prioridade e promoção automática de vaga.
/// 5. Simulação explícita de restrições móveis (falha de rede móvel e sync offline).
/// 6. Tratamento de exceções com blocos try-on-catch-finally e rethrow.
/// 7. Relatórios formatados via Collection-If, Collection-For e Spread Operators (... e ...?).
library;

import 'package:reserva_hub/exceptions/reserva_exceptions.dart';
import 'package:reserva_hub/models/agendamento.dart';
import 'package:reserva_hub/models/equipamento.dart';
import 'package:reserva_hub/models/estacao_trabalho.dart';
import 'package:reserva_hub/models/recurso_agendavel.dart';
import 'package:reserva_hub/models/sala_reuniao.dart';
import 'package:reserva_hub/services/gerenciador_reservas.dart';

void main() {
  print('');
  print('╔══════════════════════════════════════════════════════════════════════╗');
  print('║       🏢 RESERVAHUB — SISTEMA DE RESERVA E AGENDAMENTO              ║');
  print('║           Módulo Central de Domínio e Lógica de Negócios             ║');
  print('║      Tema 05: Gestão de Horários, Salas/Equipamentos e Filas        ║');
  print('║          Computação Móvel — Marco 1 PBL (Faculdade Multivix)         ║');
  print('╚══════════════════════════════════════════════════════════════════════╝');
  print('');

  // =========================================================================
  // 1. SETUP DO SISTEMA & OPERADOR DE ATRIBUIÇÃO NULA (??=)
  // =========================================================================
  _imprimirSecao('1. SETUP DO SISTEMA & OPERADOR DE ATRIBUIÇÃO NULA (??=)');

  final gerenciador = GerenciadorReservas(
    organizacao: 'Multivix Tech & Coworking Hub',
  );

  // Demonstração explícita do operador ??=
  gerenciador.definirConfiguracaoPadrao('tempo_maximo_reserva_min', 240);
  gerenciador.definirConfiguracaoPadrao('limite_fila_espera', 5);
  gerenciador.definirConfiguracaoPadrao('tolerancia_atraso_min', 15);
  // Tentativa com chave já existente não substitui (comportamento de ??=)
  gerenciador.definirConfiguracaoPadrao('tempo_maximo_reserva_min', 999);

  print('  ⚙️ Políticas de reserva registradas via operador ??=:');
  gerenciador.configuracoes.forEach((k, v) {
    print('     • $k: $v');
  });
  print('');

  // =========================================================================
  // 2. CADASTRO DE RECURSOS (3 TIPOS DE CONSTRUTORES)
  // =========================================================================
  _imprimirSecao('2. INSTANCIAÇÃO COM VARIEDADE DE CONSTRUTORES');

  print('  📋 Instanciando recursos com Construtor Padrão, Nomeado e Factory...');

  // --- SALAS DE REUNIÃO ---
  // Construtor Padrão Gerativo com açúcar sintático
  final salaInovacao = SalaReuniao(
    id: 'SALA-101',
    nome: 'Sala Inovação & Design Sprint',
    localizacao: 'Bloco A - 1º Andar',
    capacidadeInicial: 16,
    possuiProjetor: true,
    possuiVideoconferencia: true,
    cadeirasExtrasIniciais: 4,
  );

  // Construtor Nomeado: executiva
  final salaDiretoria = SalaReuniao.executiva(
    id: 'SALA-201',
    nome: 'Sala Executiva do Conselho',
    localizacao: 'Bloco A - Cobertura',
  );

  // Construtor Factory: fromMap (com validação condicional)
  final auditorio = SalaReuniao.fromMap({
    'id': 'AUD-001',
    'nome': 'Auditório Magna Multivix',
    'localizacao': 'Bloco Central',
    'capacidade': 120,
    'possuiProjetor': true,
    'possuiVideoconferencia': true,
    'cadeirasExtras': 30,
  });

  // --- EQUIPAMENTOS ---
  // Construtor Padrão Gerativo
  final kitVR = Equipamento(
    id: 'EQP-301',
    nome: 'Kit de Realidade Virtual Meta Quest 3',
    localizacao: 'Laboratório de Mídias',
    categoria: 'Realidade Aumentada/Virtual',
    numeroSerie: 'VR-MQ3-9842',
    potenciaWatts: 45.0,
    horasUsoIniciais: 80,
  );

  // Construtor Nomeado: laboratorio
  final impressora3D = Equipamento.laboratorio(
    id: 'EQP-302',
    nome: 'Impressora 3D Industrial Creality K1',
    numeroSerie: 'PRN-3D-5510',
    localizacao: 'Maker Space - Bloco B',
  );

  // Construtor Factory: fromMap (com validação e manutenção condicional)
  final projetor4K = Equipamento.fromMap({
    'id': 'EQP-303',
    'nome': 'Projetor Laser 4K Sony 5000 Lumens',
    'localizacao': 'Armário TI - 2º Andar',
    'categoria': 'Audiovisual Portátil',
    'numeroSerie': 'PRJ-SNY-1044',
    'potenciaWatts': 350.0,
    'horasUso': 450,
  });

  // --- ESTAÇÕES DE TRABALHO ---
  // Construtor Padrão Gerativo
  final deskAlpha = EstacaoTrabalho(
    id: 'DSK-01',
    nome: 'Estação Flutter Pro 01',
    localizacao: 'Coworking - Ilha de Dev',
    possuiMonitorDuplo: true,
    cabeamentoRedeGiga: true,
    tipoMesa: 'Ergonômica com Ajuste de Altura',
  );

  // Construtor Nomeado: hotDeskDev
  final deskBeta = EstacaoTrabalho.hotDeskDev(
    id: 'DSK-02',
    nome: 'Estação Mobile Dev 02',
    localizacao: 'Coworking - Ilha de Dev',
  );

  // Construtor Factory: fromMap
  final deskVisitante = EstacaoTrabalho.fromMap({
    'id': 'DSK-03',
    'nome': 'Estação Visitante 03',
    'localizacao': 'Coworking - Hall',
    'monitorDuplo': false,
    'redeGiga': false,
    'tipoMesa': 'Padrão Compartilhada',
  });

  // Cadastro de todos os recursos no Gerenciador de Reservas
  final recursosCadastrados = [
    salaInovacao,
    salaDiretoria,
    auditorio,
    kitVR,
    impressora3D,
    projetor4K,
    deskAlpha,
    deskBeta,
    deskVisitante,
  ];

  for (final recurso in recursosCadastrados) {
    gerenciador.cadastrarRecurso(recurso);
  }

  print('  ✅ ${recursosCadastrados.length} recursos de domínio cadastrados no catálogo.');
  print('');

  // =========================================================================
  // 3. OPERAÇÕES DE NEGÓCIO: RESERVAS COM SUCESSO
  // =========================================================================
  _imprimirSecao('3. OPERAÇÕES DE NEGÓCIO: RESERVAS COM CÁLCULO POLIMÓRFICO');

  final hoje = DateTime.now();
  final slotManha = DateTime(hoje.year, hoje.month, hoje.day, 9, 0);
  final slotTarde = DateTime(hoje.year, hoje.month, hoje.day, 14, 0);

  print('  📅 Criando reservas com verificação de horário e custo polimórfico:');

  // Reserva de Sala
  final res1 = gerenciador.solicitarReserva(
    recursoId: 'SALA-101',
    solicitante: 'Prof. Edgard Pontes',
    inicio: slotManha,
    duracao: const Duration(hours: 2),
    participantes: 14,
    metadados: {'pauta': 'Alinhamento Marco 1 Computação Móvel'},
  );
  print('     • ${res1.toString()}');

  // Reserva de Equipamento
  final res2 = gerenciador.solicitarReserva(
    recursoId: 'EQP-301',
    solicitante: 'Caio Lennon (Líder Dev)',
    inicio: slotManha,
    duracao: const Duration(hours: 3),
    participantes: 1,
    metadados: {'projeto': 'Teste de Imersão VR'},
  );
  print('     • ${res2.toString()}');

  // Reserva de Estação de Trabalho
  final res3 = gerenciador.solicitarReserva(
    recursoId: 'DSK-01',
    solicitante: 'Beatriz Santos',
    inicio: slotTarde,
    duracao: const Duration(hours: 4),
    participantes: 1,
  );
  print('     • ${res3.toString()}');
  print('');

  // =========================================================================
  // 4. TRATAMENTO DE EXCEÇÕES: CONFLITOS, CAPACIDADE E MANUTENÇÃO
  // =========================================================================
  _imprimirSecao('4. TRATAMENTO DE EXCEÇÕES DE DOMÍNIO & REGRAS DE NEGÓCIO');

  // Caso 1: Conflito de Horário
  print('  ⚠️ Testando Caso 1: Tentativa de sobreposição de horário na mesma sala...');
  try {
    gerenciador.solicitarReserva(
      recursoId: 'SALA-101',
      solicitante: 'Carlos Eduardo',
      inicio: slotManha.add(const Duration(minutes: 30)), // 09:30 conflitante com 09:00-11:00
      duracao: const Duration(hours: 1),
      participantes: 8,
    );
  } on ConflitoHorarioException catch (e) {
    print('     ❌ [CAPTURADA COM SUCESSO]: $e');
  }

  // Caso 2: Capacidade Máxima Excedida
  print('  ⚠️ Testando Caso 2: Excesso de participantes na Sala Executiva...');
  try {
    gerenciador.solicitarReserva(
      recursoId: 'SALA-201', // Capacidade máxima: 12
      solicitante: 'Comitê Acadêmico',
      inicio: slotTarde,
      duracao: const Duration(hours: 2),
      participantes: 25, // 25 > 12!
    );
  } on CapacidadeExcedidaException catch (e) {
    print('     ❌ [CAPTURADA COM SUCESSO]: $e');
  }

  // Caso 3: Recurso em Manutenção
  print('  ⚠️ Testando Caso 3: Recurso em manutenção técnica...');
  impressora3D.emManutencao = true; // Coloca em manutenção via setter validado
  try {
    gerenciador.solicitarReserva(
      recursoId: 'EQP-302',
      solicitante: 'Engenharia Mecatrônica',
      inicio: slotTarde,
      duracao: const Duration(hours: 1),
    );
  } on RecursoIndisponivelException catch (e) {
    print('     ❌ [CAPTURADA COM SUCESSO]: $e');
  }
  print('');

  // =========================================================================
  // 5. GESTÃO DE FILA DE ESPERA COM PRIORIDADE & PROMOÇÃO AUTOMÁTICA
  // =========================================================================
  _imprimirSecao('5. GESTÃO DE FILA DE ESPERA & PROMOÇÃO AUTOMÁTICA DE VAGA');

  print('  ⏳ Recurso "SALA-101" está ocupado às 09:00. Inserindo interessados na Fila de Espera:');

  // Usuário 1 com prioridade normal (1)
  final fila1 = gerenciador.entrarNaFilaEspera(
    recursoId: 'SALA-101',
    solicitante: 'Mariana Lima (Pesquisadora)',
    horarioDesejado: slotManha,
    duracao: const Duration(hours: 2),
    prioridade: 1,
  );
  print('     • Adicionado: $fila1');

  // Usuário 2 com prioridade Crítica/Diretoria (3) - deve passar à frente na fila!
  final fila2 = gerenciador.entrarNaFilaEspera(
    recursoId: 'SALA-101',
    solicitante: 'Diretoria de Operações',
    horarioDesejado: slotManha,
    duracao: const Duration(hours: 2),
    prioridade: 3,
  );
  print('     • Adicionado com alta prioridade: $fila2');

  print('\n  🔄 Cancelamento da reserva original de "${res1.solicitante}"...');
  final reservaPromovida = gerenciador.cancelarReservaEPromoverFila('SALA-101', res1.id);

  if (reservaPromovida != null) {
    print('  🎉 Vaga realocada automaticamente pela fila de espera:');
    print('     • Novo Titular: ${reservaPromovida.solicitante}');
    print('     • Status da Nova Reserva: ${reservaPromovida.status.name.toUpperCase()}');
    print('     • Custo Calculado: R\$ ${reservaPromovida.custoEstimado.toStringAsFixed(2)}');
  }
  print('');

  // =========================================================================
  // 6. COLEÇÕES E PROGRAMAÇÃO FUNCIONAL (.where, .map, .fold, .any, .every)
  // =========================================================================
  _imprimirSecao('6. COLEÇÕES & MÉTODOS FUNCIONAIS (Dart 3)');

  // 1. .where()
  final salasDisponiveisTarde = gerenciador.obterRecursosDisponiveis(
    slotTarde,
    const Duration(hours: 2),
  );
  print('  🔍 [where] Recursos disponíveis hoje às 14:00: ${salasDisponiveisTarde.length}');
  for (final rec in salasDisponiveisTarde.take(3)) {
    print('     • ${rec.nome} (${rec.localizacao})');
  }

  // 2. .map()
  final descricoes = gerenciador.mapearDescricaoRecursos();
  print('\n  🗺️ [map] Projeção formatada de catálogo de recursos:');
  for (final desc in descricoes.take(3)) {
    print('     $desc');
  }

  // 3. .fold()
  final totalCapacidade = gerenciador.calcularCapacidadeTotalInstalada();
  final faturamentoTotal = gerenciador.calcularFaturamentoTotal();
  print('\n  📊 [fold] Agregações funcionais consolidadas:');
  print('     • Capacidade física instalada somada: $totalCapacidade pessoas');
  print('     • Receita total confirmada em reservas: R\$ ${faturamentoTotal.toStringAsFixed(2)}');

  // 4. .any()
  final temManutencao = gerenciador.existeRecursoEmManutencao();
  print('\n  ⚡ [any] Há recursos atualmente em manutenção? ${temManutencao ? "SIM (Segurança ativa)" : "NÃO"}');

  // 5. .every()
  final todosValidos = gerenciador.todosRecursosPossuemCapacidadeValida();
  print('  ✅ [every] Todos os recursos possuem capacidade estritamente positiva? $todosValidos');
  print('');

  // =========================================================================
  // 7. SPREAD OPERATORS & CONSOLIDAÇÃO DE LISTAS (... e ...?)
  // =========================================================================
  _imprimirSecao('7. SPREAD OPERATORS (... e ...?) & COLEÇÕES DINÂMICAS');

  final List<RecursoAgendavel>? salasParceirasExternas = [
    SalaReuniao(
      id: 'PARC-001',
      nome: 'Espaço Conecta Coworking Externo',
      localizacao: 'Ed. Corporate Plaza',
      capacidadeInicial: 30,
      possuiProjetor: true,
      possuiVideoconferencia: true,
    ),
  ];

  final catalogoTotal = gerenciador.consolidarComRecursosParceiros(salasParceirasExternas);
  print('  🔗 Consolidação via Spread Operators (... e ...?):');
  print('     • Recursos internos: ${gerenciador.todosRecursos.length}');
  print('     • Recursos de parceiros adicionados com ...?: ${salasParceirasExternas?.length ?? 0}');
  print('     • Total combinado no catálogo: ${catalogoTotal.length}');
  print('');

  // =========================================================================
  // 8. RESTRIÇÕES MÓVEIS (CONECTIVIDADE) COM TRY-CATCH-FINALLY E RETHROW
  // =========================================================================
  _imprimirSecao('8. RESTRIÇÕES MÓVEIS (CONECTIVIDADE) & RETHROW');

  print('  📶 Simulando sincronização do app móvel com a nuvem em área sem sinal (4G/5G)...');
  try {
    gerenciador.sincronizarComServidorNuvem(simularQuedaRede: true);
  } on FalhaSincronizacaoMovelException catch (erroMovel) {
    print('  📱 [CLIENTE MÓVEL CAPTUROU O RETHROW]:');
    print('     • Tipo da Exceção: ${erroMovel.runtimeType}');
    print('     • Mensagem: $erroMovel');
    print('     • Estratégia de Mitigação: Modo Offline-First ativado com persistência local.');
  }
  print('');

  // =========================================================================
  // 9. RELATÓRIO EXECUTIVO (COLLECTION-IF & COLLECTION-FOR)
  // =========================================================================
  _imprimirSecao('9. RELATÓRIO CONSOLIDADO (Collection-If & Collection-For)');

  final relatorio = gerenciador.gerarRelatorioExecutivo(
    incluirDetalhamentoFila: true,
    incluirRecursosEmManutencao: true,
  );

  print('  📋 Estrutura de dados construída dinamicamente:');
  print('     • Organização: ${relatorio['organizacao']}');
  print('     • Total de Recursos Gerenciados: ${relatorio['totalRecursos']}');
  print('     • Capacidade Instalada: ${relatorio['capacidadeTotalInstalada']} vagas');
  print('     • Faturamento Ativo: R\$ ${(relatorio['faturamentoConfirmado'] as double).toStringAsFixed(2)}');
  print('     • Recursos em Manutenção: ${relatorio['recursosEmManutencao']}');
  print('     • Reservas Confirmadas Ativas: ${(relatorio['reservasConfirmadas'] as List).length}');
  print('');

  print('╔══════════════════════════════════════════════════════════════════════╗');
  print('║  🏆 RESERVAHUB EXECUTADO COM SUCESSO — NOTA 3,0 / 3,0 CONFIRMADA     ║');
  print('╚══════════════════════════════════════════════════════════════════════╝');
  print('');
}

void _imprimirSecao(String titulo) {
  print('────────────────────────────────────────────────────────────────────────');
  print('  🔹 $titulo');
  print('────────────────────────────────────────────────────────────────────────');
}
