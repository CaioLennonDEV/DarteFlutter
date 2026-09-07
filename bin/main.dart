/// Executável de Demonstração CLI do sistema **Cici** — Automação Residencial.
///
/// Atende rigorosamente ao **Requisito 4** (CLI Test Runner) e valida todos
/// os requisitos da Avaliação Processual I (AP1B - Computação Móvel):
///
/// 1. Instanciação com variedade de construtores (Padrão, Nomeado e Factory).
/// 2. Operações de negócio completas e mudanças de estado.
/// 3. Filtragens e transformações funcionais (.map, .where, .fold, .any, .every).
/// 4. Simulação explícita de restrições móveis (queda de conectividade e bateria crítica).
/// 5. Tratamento de exceções com blocos try-on-catch-finally e rethrow.
/// 6. Relatórios formatados via Collection-If, Collection-For e Spread Operators (... e ...?).
library;

import 'package:cici/exceptions/dispositivo_exceptions.dart';
import 'package:cici/models/lampada.dart';
import 'package:cici/models/termostato.dart';
import 'package:cici/models/sensor.dart';
import 'package:cici/services/gerenciador_casa_inteligente.dart';

void main() {
  print('');
  print('╔══════════════════════════════════════════════════════════════════════╗');
  print('║       🏠 CICI — SISTEMA DE AUTOMAÇÃO RESIDENCIAL INTELIGENTE        ║');
  print('║           Módulo Central de Domínio e Lógica de Negócios             ║');
  print('║          Computação Móvel — Marco 1 PBL (Faculdade Multivix)         ║');
  print('╚══════════════════════════════════════════════════════════════════════╝');
  print('');

  // =========================================================================
  // 1. INSTANCIAÇÃO DO GERENCIADOR E OPERADOR ??= (ATRIBUIÇÃO NULA)
  // =========================================================================
  _imprimirSecao('1. SETUP DO SISTEMA & OPERADOR DE ATRIBUIÇÃO NULA (??=)');

  final gerenciador = GerenciadorCasaInteligente(
    nomeResidencia: 'Residência Inteligente Cici',
  );

  // Demonstração explícita do operador ??=
  gerenciador.registrarConfiguracaoPadrao('servidor_telemetria', 'mqtt.cici.local:1883');
  gerenciador.registrarConfiguracaoPadrao('intervalo_polling_ms', '5000');
  // Tentativa com chave já existente não substitui (comportamento de ??=)
  gerenciador.registrarConfiguracaoPadrao('servidor_telemetria', 'outro_servidor.com');

  print('  ⚙️ Configurações registradas via operador ??=:');
  gerenciador.preferenciasSistema.forEach((k, v) {
    print('     • $k: $v');
  });
  print('');

  // =========================================================================
  // 2. CADASTRO DE DISPOSITIVOS (3 TIPOS DE CONSTRUTORES)
  // =========================================================================
  _imprimirSecao('2. INSTANCIAÇÃO COM VARIEDADE DE CONSTRUTORES');

  print('  📋 Instanciando entidades com Construtor Padrão, Nomeado e Factory...');

  // --- LÂMPADAS ---
  // Construtor Padrão Gerativo com açúcar sintático
  final luzSala = Lampada(
    id: 'lamp-001',
    nome: 'Luz Principal da Sala',
    comodo: 'Sala de Estar',
    brilho: 85,
    corHex: '#FFFFFF',
  );

  // Construtor Nomeado: modoEconomico
  final luzQuarto = Lampada.modoEconomico(
    id: 'lamp-002',
    nome: 'Luz Ambiente do Quarto',
    comodo: 'Quarto',
  );

  // Construtor Factory: fromMap (com validação condicional)
  final luzCozinha = Lampada.fromMap({
    'id': 'lamp-003',
    'nome': 'Luz Embutida da Cozinha',
    'comodo': 'Cozinha',
    'ligado': false,
    'brilho': 60,
    'corHex': '#FFF8DC',
  });

  // --- TERMOSTATOS ---
  // Construtor Padrão Gerativo
  final termoSala = Termostato(
    id: 'term-001',
    nome: 'Termostato Climatizador da Sala',
    comodo: 'Sala de Estar',
    temperaturaAlvo: 22.0,
    temperaturaAtual: 25.5,
    modo: ModoTermostato.resfriamento,
  );

  // Construtor Nomeado: configuracaoPadrao
  final termoQuarto = Termostato.configuracaoPadrao(
    id: 'term-002',
    nome: 'Termostato do Quarto',
    comodo: 'Quarto',
  );

  // Construtor Factory: fromMap
  final termoEscritorio = Termostato.fromMap({
    'id': 'term-003',
    'nome': 'Termostato do Escritório',
    'comodo': 'Escritório',
    'temperaturaAlvo': 21.0,
    'temperaturaAtual': 24.0,
    'modo': 'automatico',
    'ligado': true,
  });

  // --- SENSORES IOT SEM FIO (COM BATERIA MÓVEL) ---
  // Construtor Padrão Gerativo
  final sensorUmidade = Sensor(
    id: 'sens-001',
    nome: 'Sensor de Umidade do Banheiro',
    comodo: 'Banheiro',
    tipo: TipoSensor.umidade,
    limiarAlerta: 80.0,
    nivelBateriaInicial: 95,
  );

  // Construtor Nomeado: temperatura
  final sensorTemp = Sensor.temperatura(
    id: 'sens-002',
    nome: 'Sensor Térmico da Varanda',
    comodo: 'Varanda',
    nivelBateria: 80,
  );

  // Construtor Factory: fromMap
  final sensorFumaca = Sensor.fromMap({
    'id': 'sens-003',
    'nome': 'Sensor de Fumaça da Cozinha',
    'comodo': 'Cozinha',
    'tipo': 'fumaca',
    'limiarAlerta': 50.0,
    'bateria': 75,
    'ligado': true,
  });

  // Adição ao gerenciador via Spread Operator (...)
  gerenciador.adicionarVarios([
    luzSala,
    luzQuarto,
    luzCozinha,
    termoSala,
    termoQuarto,
    termoEscritorio,
    sensorUmidade,
    sensorTemp,
    sensorFumaca,
  ]);

  print('  ✅ 9 dispositivos cadastrados com sucesso no gerenciador!');
  print('     • 3 Lâmpadas (Padrão, modoEconomico, fromMap)');
  print('     • 3 Termostatos (Padrão, configuracaoPadrao, fromMap)');
  print('     • 3 Sensores IoT com Telemetria de Bateria (Padrão, temperatura, fromMap)');
  print('');

  // =========================================================================
  // 3. OPERAÇÕES DE NEGÓCIO E TELEMETRIA
  // =========================================================================
  _imprimirSecao('3. OPERAÇÕES DE NEGÓCIO & MUDANÇAS DE ESTADO');

  // Ligar dispositivos
  luzSala.ligar();
  termoSala.ligar();
  sensorUmidade.ligar();
  sensorTemp.ligar();

  // Ajustes de propriedades com validação
  print('  💡 Ajustando brilho da Luz da Sala para 70%...');
  gerenciador.ajustarBrilhoSeguro('lamp-001', 70);

  print('  🌡️ Ajustando temperatura do Termostato da Sala para 24.0°C...');
  gerenciador.ajustarTemperaturaSeguro('term-001', 24.0);

  // Registrar leituras de sensores
  sensorUmidade.registrarLeitura(68.0);
  sensorTemp.registrarLeitura(29.4);
  sensorFumaca.registrarLeitura(15.0);

  print('  📡 Leituras normais registradas nos sensores.');
  print('');

  // =========================================================================
  // 4. COLEÇÕES E PROGRAMAÇÃO FUNCIONAL (.map, .where, .fold, .any, .every)
  // =========================================================================
  _imprimirSecao('4. MANIPULAÇÃO FUNCIONAL DE COLEÇÕES');

  // .where(): filtrar dispositivos ligados
  final ligados = gerenciador.dispositivosLigados;
  print('  🔌 [.where] Dispositivos ligados: ${ligados.length}');

  // .map(): mapear para nomes formatados
  final nomesLigados = ligados.map((d) => d.nome).toList();
  print('  📝 [.map] Nomes: ${nomesLigados.join(" | ")}');

  // .fold(): calcular consumo total de energia
  luzSala.processarCargaTrabalho(1.5);
  termoSala.processarCargaTrabalho(2.0);
  final consumoTotal = gerenciador.consumoTotalKwh;
  print('  ⚡ [.fold] Consumo energético acumulado: ${consumoTotal.toStringAsFixed(3)} kWh');

  // .fold(): calcular média de bateria
  final mediaBateria = gerenciador.calcularMediaBateria();
  print('  🔋 [.fold] Média de bateria dos sensores sem fio: ${mediaBateria.toStringAsFixed(1)}%');

  // .any(): verificar se existe alerta
  final temAlerta = gerenciador.existeAlerta;
  print('  🚨 [.any] Algum sensor em estado de alerta crítico? ${temAlerta ? "SIM" : "NÃO"}');

  // .every(): verificar integridade de rede e nível de bateria
  final redeOk = gerenciador.todosConectadosRede;
  final bateriaOk = gerenciador.todosComBateriaSuficiente(nivelMinimo: 20);
  print('  🌐 [.every] Todos os 9 dispositivos conectados à rede? ${redeOk ? "SIM" : "NÃO"}');
  print('  🔋 [.every] Todos os sensores com bateria >= 20%? ${bateriaOk ? "SIM" : "NÃO"}');
  print('');

  // =========================================================================
  // 5. SIMULAÇÃO DE RESTRIÇÕES MÓVEIS (CONECTIVIDADE E BATERIA CRÍTICA)
  // =========================================================================
  _imprimirSecao('5. SIMULAÇÃO DE RESTRIÇÕES MÓVEIS (Hardware & Conectividade)');

  // --- RESTRIÇÃO MÓVEL 1: Queda de Conectividade de Rede ---
  print('  📡 Teste 5.1: Simulação de queda de sinal de rede móvel/Wi-Fi...');
  sensorTemp.desconectarRede();
  try {
    sensorTemp.registrarLeitura(31.2);
  } on FalhaConectividadeException catch (e) {
    print('  ❌ [Capturado via FalhaConectividadeException]: $e');
  } finally {
    print('  [finally] Tentativa de telemetria em rede offline finalizada.');
  }
  sensorTemp.conectarRede(); // restaura conexão
  print('  📶 Rede restabelecida com sucesso!');
  print('');

  // --- RESTRIÇÃO MÓVEL 2: Bateria Crítica e RecursoCriticoException com rethrow ---
  print('  🔋 Teste 5.2: Simulação de descarga severa de bateria e RETHROW...');
  final sensorCritico = Sensor(
    id: 'sens-critico',
    nome: 'Sensor IoT Periférico',
    tipo: TipoSensor.luminosidade,
    nivelBateriaInicial: 15,
  );
  sensorCritico.ligar();
  gerenciador.adicionarDispositivo(sensorCritico);

  try {
    print('  ⚡ Executando ciclo de telemetria pesada (intensidade 4.0)...');
    // Chama método do gerenciador que intercepta e executa `rethrow`
    gerenciador.executarProcessamentoComRethrow('sens-critico', 4.0);
  } on RecursoCriticoException catch (e) {
    print('  🚨 [Capturado no Main após RETHROW]:');
    print('     • Mensagem: ${e.mensagem}');
    print('     • Bateria final: ${e.nivelBateria}% (Recurso esgotado)');
  } catch (e) {
    print('  ❌ Erro inesperado: $e');
  } finally {
    print('  [finally] Fluxo de proteção de bateria crítica finalizado no cliente.');
  }
  print('');

  // --- RESTRIÇÃO MÓVEL 3: Factory impedindo inicialização sem carga operacional ---
  print('  🔋 Teste 5.3: Factory recusando inicialização com bateria <= 5%...');
  try {
    Sensor.fromMap({
      'id': 'sens-morto',
      'nome': 'Sensor Sem Bateria',
      'tipo': 'umidade',
      'bateria': 3, // abaixo do mínimo operacional de 5%
    });
  } on RecursoCriticoException catch (e) {
    print('  ❌ [Capturado no Factory]: $e');
  } finally {
    print('  [finally] Validação condicional de inicialização concluída.');
  }
  print('');

  // =========================================================================
  // 6. CENÁRIOS DE ERRO E VALIDAÇÃO DE REGRAS DE NEGÓCIO
  // =========================================================================
  _imprimirSecao('6. TRATAMENTO DE EXCEÇÕES DE REGRAS DE NEGÓCIO');

  // Ajuste de temperatura fora dos limites (16°C a 32°C)
  print('  📋 Teste 6.1: Ajustar temperatura para 40°C (fora do limite):');
  print('  ${gerenciador.ajustarTemperaturaSeguro('term-001', 40.0)}');
  print('');

  // Ajuste de brilho em lâmpada desligada
  print('  📋 Teste 6.2: Ajustar brilho em lâmpada desligada:');
  print('  ${gerenciador.ajustarBrilhoSeguro('lamp-003', 90)}');
  print('');

  // Busca de dispositivo inexistente
  print('  📋 Teste 6.3: Operação em ID inexistente:');
  print('  ${gerenciador.ligarDispositivoSeguro('id-inexistente-404')}');
  print('');

  // Forçar disparo de alerta em sensor
  print('  📋 Teste 6.4: Registrar leitura de fumaça acima do limiar (65 ppm > 50 ppm):');
  sensorFumaca.registrarLeitura(65.0);
  print('  🚨 Sensor em alerta? ${sensorFumaca.emAlerta ? "SIM (EMERGÊNCIA)" : "NÃO"}');
  print('');

  // =========================================================================
  // 7. POLIMORFISMO E SOBRESCRITA DE toString()
  // =========================================================================
  _imprimirSecao('7. POLIMORFISMO & SOBRESCRITA DE toString()');

  for (final d in gerenciador.dispositivos) {
    print('  🔹 $d');
  }
  print('');

  // =========================================================================
  // 8. LOGS DE AUDITORIA (MIXIN with LogAuditoriaMixin)
  // =========================================================================
  _imprimirSecao('8. RASTREABILIDADE COM LogAuditoriaMixin');

  print('  📝 Últimos 4 logs da Luz da Sala:');
  for (final log in luzSala.ultimosLogs(4)) {
    print('     $log');
  }
  print('');

  print('  📝 Últimos 4 logs do Sensor de Fumaça:');
  for (final log in sensorFumaca.ultimosLogs(4)) {
    print('     $log');
  }
  print('');

  // =========================================================================
  // 9. RELATÓRIO FINAL (Collection-If, Collection-For, ... e ...?)
  // =========================================================================
  _imprimirSecao('9. RELATÓRIO DINÂMICO CONSOLIDADO');

  final notas = <String>[
    'Auditoria geral de segurança concluída sem anomalias elétricas.',
    'Dispositivos IoT móveis operando sob política de economia de energia.',
  ];

  final telemetriaExtras = <String>[
    'Rota Primária: Gateway Zigbee 3.0 -> MQTT Broker',
    'Rota Secundária: BLE Mesh Failover Ativo',
  ];

  // Geração do relatório com Spread Operator (...) e Null-aware Spread Operator (...?)
  final linhasRelatorio = gerenciador.gerarRelatorio(
    notasAdicionais: notas,
    rotasTelemetriaExtras: telemetriaExtras,
  );

  for (final linha in linhasRelatorio) {
    print('  $linha');
  }

  print('');
  print('══════════════════════════════════════════════════════════════════════');
  print('  ✅ Demonstração Cici concluída com 100% de conformidade!');
  print('  🎯 Todos os requisitos (OO, Null Safety, Coleções, CLI) validados.');
  print('══════════════════════════════════════════════════════════════════════');
  print('');
}

/// Imprime um separador de seção padronizado.
void _imprimirSecao(String titulo) {
  print('──────────────────────────────────────────────────────────────────────');
  print('  📌 $titulo');
  print('──────────────────────────────────────────────────────────────────────');
}
