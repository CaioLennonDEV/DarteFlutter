/// Arquivo executável CLI do sistema **Cici** — Automação Residencial.
///
/// Este script simula o fluxo completo do módulo de domínio:
/// 1. Cadastro de lâmpadas, termostatos e sensores.
/// 2. Mudanças de estado (ligar, desligar, ajustar brilho/temperatura).
/// 3. Filtragem de dispositivos ligados (`.where`, `.map`, `.fold`, `.any`).
/// 4. Cenários de erro forçados para demonstrar exceções customizadas
///    com `try-on-catch-finally`.
/// 5. Relatório final com Collection-If/For e Spread Operators.

import 'package:cici/exceptions/dispositivo_exceptions.dart';
import 'package:cici/models/lampada.dart';
import 'package:cici/models/termostato.dart';
import 'package:cici/models/sensor.dart';
import 'package:cici/services/gerenciador_casa_inteligente.dart';

void main() {
  print('');
  print('╔══════════════════════════════════════════════════════════╗');
  print('║   🏠 CICI — Sistema de Automação Residencial Inteligente   ║');
  print('║          Módulo Central de Domínio (Dart Puro)          ║');
  print('╚══════════════════════════════════════════════════════════╝');
  print('');

  // =========================================================================
  // 1. INSTANCIAÇÃO DO GERENCIADOR
  // =========================================================================
  final gerenciador = GerenciadorCasaInteligente(
    nomeResidencia: 'Casa Cici',
  );

  _imprimirSecao('1. CADASTRO DE DISPOSITIVOS');

  // =========================================================================
  // 2. CRIAÇÃO DE LÂMPADAS
  // =========================================================================

  // Construtor padrão gerativo
  final luzSala = Lampada(
    id: 'lamp-001',
    nome: 'Luz da Sala',
    comodo: 'Sala',
    brilho: 80,
    corHex: '#FFFFFF',
  );

  // Construtor nomeado: modoEconomico
  final luzQuarto = Lampada.modoEconomico(
    id: 'lamp-002',
    nome: 'Luz do Quarto',
    comodo: 'Quarto',
  );

  // Construtor factory: fromMap
  final luzCozinha = Lampada.fromMap({
    'id': 'lamp-003',
    'nome': 'Luz da Cozinha',
    'comodo': 'Cozinha',
    'ligado': false,
    'brilho': 60,
    'corHex': '#FFE4B5',
  });

  print('  💡 Lâmpadas criadas:');
  print('     • ${luzSala.nome} (construtor padrão) — Brilho: ${luzSala.brilho}%');
  print('     • ${luzQuarto.nome} (construtor nomeado .modoEconomico) — Brilho: ${luzQuarto.brilho}%');
  print('     • ${luzCozinha.nome} (constructor factory .fromMap) — Brilho: ${luzCozinha.brilho}%');
  print('');

  // =========================================================================
  // 3. CRIAÇÃO DE TERMOSTATOS
  // =========================================================================

  // Construtor padrão gerativo
  final termoSala = Termostato(
    id: 'term-001',
    nome: 'Termostato da Sala',
    comodo: 'Sala',
    temperaturaAlvo: 24.0,
    modo: ModoTermostato.resfriamento,
  );

  // Construtor nomeado: configuracaoPadrao
  final termoQuarto = Termostato.configuracaoPadrao(
    id: 'term-002',
    nome: 'Termostato do Quarto',
    comodo: 'Quarto',
  );

  // Construtor factory: fromMap
  final termoCozinha = Termostato.fromMap({
    'id': 'term-003',
    'nome': 'Termostato da Cozinha',
    'comodo': 'Cozinha',
    'temperaturaAlvo': 20.0,
    'modo': 'aquecimento',
  });

  print('  🌡️ Termostatos criados:');
  print('     • ${termoSala.nome} (construtor padrão) — Alvo: ${termoSala.temperaturaAlvo}°C');
  print('     • ${termoQuarto.nome} (construtor nomeado .configuracaoPadrao) — Alvo: ${termoQuarto.temperaturaAlvo}°C');
  print('     • ${termoCozinha.nome} (constructor factory .fromMap) — Alvo: ${termoCozinha.temperaturaAlvo}°C');
  print('');

  // =========================================================================
  // 4. CRIAÇÃO DE SENSORES
  // =========================================================================

  // Construtor padrão gerativo
  final sensorUmidade = Sensor(
    id: 'sens-001',
    nome: 'Sensor de Umidade',
    comodo: 'Banheiro',
    tipo: TipoSensor.umidade,
    limiarAlerta: 85.0,
  );

  // Construtor nomeado: temperatura
  final sensorTemp = Sensor.temperatura(
    id: 'sens-002',
    nome: 'Sensor Temp. Cozinha',
    comodo: 'Cozinha',
  );

  // Construtor factory: fromMap
  final sensorFumaca = Sensor.fromMap({
    'id': 'sens-003',
    'nome': 'Detector de Fumaça',
    'comodo': 'Cozinha',
    'tipo': 'fumaca',
    'limiarAlerta': 50.0,
  });

  print('  📡 Sensores criados:');
  print('     • ${sensorUmidade.nome} (construtor padrão) — Tipo: ${sensorUmidade.tipo.rotulo}');
  print('     • ${sensorTemp.nome} (construtor nomeado .temperatura) — Tipo: ${sensorTemp.tipo.rotulo}');
  print('     • ${sensorFumaca.nome} (constructor factory .fromMap) — Tipo: ${sensorFumaca.tipo.rotulo}');
  print('');

  // =========================================================================
  // 5. REGISTRO NO GERENCIADOR
  // =========================================================================

  gerenciador.adicionarDispositivo(luzSala);
  gerenciador.adicionarDispositivo(luzQuarto);
  gerenciador.adicionarDispositivo(luzCozinha);
  gerenciador.adicionarDispositivo(termoSala);
  gerenciador.adicionarDispositivo(termoQuarto);
  gerenciador.adicionarDispositivo(termoCozinha);
  gerenciador.adicionarDispositivo(sensorUmidade);
  gerenciador.adicionarDispositivo(sensorTemp);
  gerenciador.adicionarDispositivo(sensorFumaca);

  print('  ✅ ${gerenciador.totalDispositivos} dispositivos registrados no gerenciador.');
  print('');

  // =========================================================================
  // 6. SIMULAÇÃO DE OPERAÇÕES (LIGAR, AJUSTAR)
  // =========================================================================

  _imprimirSecao('2. SIMULAÇÃO DE OPERAÇÕES');

  // Ligar dispositivos
  luzSala.ligar();
  luzCozinha.ligar();
  termoSala.ligar();
  sensorUmidade.ligar();
  sensorTemp.ligar();
  sensorFumaca.ligar();

  print('  Dispositivos ligados com sucesso:');
  // Uso de .map() para transformar nomes
  final nomesLigados = gerenciador.nomesDispositivosLigados;
  for (final nome in nomesLigados) {
    print('     🟢 $nome');
  }
  print('');

  // Ajustar brilho da lâmpada da sala
  print('  Ajustando brilho da Luz da Sala para 50%...');
  print('  ${gerenciador.ajustarBrilhoSeguro('lamp-001', 50)}');
  print('');

  // Ajustar temperatura do termostato da sala
  print('  Ajustando temperatura do Termostato da Sala para 26°C...');
  print('  ${gerenciador.ajustarTemperaturaSeguro('term-001', 26.0)}');
  print('');

  // Simular leituras de sensores
  sensorUmidade.registrarLeitura(72.5);
  sensorTemp.registrarLeitura(28.3);
  sensorFumaca.registrarLeitura(12.0);
  print('  📡 Leituras de sensores registradas:');
  print('     • ${sensorUmidade.nome}: ${sensorUmidade.leituraFormatada}');
  print('     • ${sensorTemp.nome}: ${sensorTemp.leituraFormatada}');
  print('     • ${sensorFumaca.nome}: ${sensorFumaca.leituraFormatada}');
  print('');

  // Registrar consumo de energia em algumas lâmpadas e termostatos
  luzSala.registrarConsumo(0.15);
  luzQuarto.registrarConsumo(0.05);
  termoSala.registrarConsumo(0.80);

  // =========================================================================
  // 7. FILTRAGENS FUNCIONAIS (.where, .map, .fold, .any)
  // =========================================================================

  _imprimirSecao('3. FILTRAGENS FUNCIONAIS');

  // .where() — dispositivos ligados
  final ligados = gerenciador.dispositivosLigados;
  print('  🔌 Dispositivos LIGADOS (${ligados.length}):');
  // .map() — transformar em string descritiva
  final descricoes = ligados.map((d) => '     • ${d.toString()}').toList();
  for (final desc in descricoes) {
    print(desc);
  }
  print('');

  // .fold() — consumo total
  final consumoTotal = gerenciador.consumoTotalKwh;
  print('  ⚡ Consumo total acumulado: ${consumoTotal.toStringAsFixed(3)} kWh');
  print('');

  // .any() — verificar alertas
  final temAlerta = gerenciador.existeAlerta;
  print('  🚨 Existe algum sensor em alerta? ${temAlerta ? "SIM" : "NÃO"}');
  print('');

  // .where() por cômodo
  final dispositivosCozinha = gerenciador.dispositivosPorComodo('Cozinha');
  print('  🏠 Dispositivos na Cozinha (${dispositivosCozinha.length}):');
  for (final d in dispositivosCozinha) {
    print('     • ${d.nome}');
  }
  print('');

  // =========================================================================
  // 8. CENÁRIOS DE ERRO FORÇADOS (try-on-catch-finally)
  // =========================================================================

  _imprimirSecao('4. CENÁRIOS DE ERRO (Exceções Customizadas)');

  // --- ERRO 1: Temperatura abaixo do mínimo (< 16°C) ---
  print('  📋 Teste 1: Ajustar temperatura para 10°C (abaixo do mínimo 16°C)');
  print('  ${gerenciador.ajustarTemperaturaSeguro('term-001', 10.0)}');
  print('');

  // --- ERRO 2: Temperatura acima do máximo (> 32°C) ---
  print('  📋 Teste 2: Ajustar temperatura para 45°C (acima do máximo 32°C)');
  print('  ${gerenciador.ajustarTemperaturaSeguro('term-001', 45.0)}');
  print('');

  // --- ERRO 3: Brilho em lâmpada desligada ---
  print('  📋 Teste 3: Ajustar brilho da lâmpada da cozinha (desligada = não)');
  luzCozinha.desligar(); // garantir que está desligada
  print('  ${gerenciador.ajustarBrilhoSeguro('lamp-003', 80)}');
  print('');

  // --- ERRO 4: Buscar dispositivo inexistente ---
  print('  📋 Teste 4: Buscar dispositivo com ID inexistente');
  print('  ${gerenciador.ligarDispositivoSeguro('id-inexistente-999')}');
  print('');

  // --- ERRO 5: Leitura em sensor offline ---
  print('  📋 Teste 5: Registrar leitura em sensor desligado');
  sensorFumaca.desligar();
  try {
    sensorFumaca.registrarLeitura(55.0);
  } on DispositivoOfflineException catch (e) {
    print('  ❌ Capturado: $e');
  } catch (e) {
    print('  ❌ Erro inesperado: $e');
  } finally {
    print('  [finally] Tentativa de leitura em sensor offline concluída.');
  }
  print('');

  // --- ERRO 6: Construtor factory com dados inválidos ---
  print('  📋 Teste 6: Criar lâmpada via factory com "id" vazio');
  try {
    Lampada.fromMap({'id': '', 'nome': 'Teste'});
  } on EstadoInvalidoException catch (e) {
    print('  ❌ Capturado: $e');
  } catch (e) {
    print('  ❌ Erro inesperado: $e');
  } finally {
    print('  [finally] Tentativa de factory com dados inválidos concluída.');
  }
  print('');

  // --- ERRO 7: Duplicar ID ---
  print('  📋 Teste 7: Adicionar dispositivo com ID duplicado');
  try {
    gerenciador.adicionarDispositivo(Lampada(
      id: 'lamp-001', // já existe!
      nome: 'Lampada Duplicada',
    ));
  } on EstadoInvalidoException catch (e) {
    print('  ❌ Capturado: $e');
  } catch (e) {
    print('  ❌ Erro inesperado: $e');
  } finally {
    print('  [finally] Tentativa de inserção de ID duplicado concluída.');
  }
  print('');

  // --- ERRO 8: Forçar alerta em sensor e verificar ---
  print('  📋 Teste 8: Forçar leitura acima do limiar de alerta');
  sensorUmidade.registrarLeitura(92.0); // limiar é 85%
  print('  📡 ${sensorUmidade.nome}: ${sensorUmidade.leituraFormatada}');
  print('  🚨 Em alerta? ${sensorUmidade.emAlerta ? "SIM" : "NÃO"}');
  print('  🚨 Existe alerta no sistema? ${gerenciador.existeAlerta ? "SIM" : "NÃO"}');
  print('');

  // =========================================================================
  // 9. @override toString() DE TODOS OS DISPOSITIVOS
  // =========================================================================

  _imprimirSecao('5. toString() DE TODOS OS DISPOSITIVOS');

  for (final dispositivo in gerenciador.dispositivos) {
    print('  $dispositivo');
  }
  print('');

  // =========================================================================
  // 10. LOG DE AUDITORIA (LogAuditoriaMixin)
  // =========================================================================

  _imprimirSecao('6. LOG DE AUDITORIA (Mixin)');

  print('  📝 Últimos 5 logs da Luz da Sala:');
  for (final log in luzSala.ultimosLogs(5)) {
    print('     $log');
  }
  print('');

  print('  📝 Últimos 3 logs do Termostato da Sala:');
  for (final log in termoSala.ultimosLogs(3)) {
    print('     $log');
  }
  print('');

  print('  📝 Últimos 3 logs do Sensor de Umidade:');
  for (final log in sensorUmidade.ultimosLogs(3)) {
    print('     $log');
  }
  print('');

  // =========================================================================
  // 11. RELATÓRIO FINAL (Collection-If/For + Spread Operator)
  // =========================================================================

  _imprimirSecao('7. RELATÓRIO FINAL');

  final relatorio = gerenciador.gerarRelatorio();
  for (final linha in relatorio) {
    print('  $linha');
  }

  print('');
  print('═══════════════════════════════════════════════════════════');
  print('  ✅ Simulação Cici concluída com sucesso!');
  print('  📊 Todos os requisitos técnicos foram demonstrados.');
  print('═══════════════════════════════════════════════════════════');
  print('');
}

/// Imprime um separador de seção formatado.
void _imprimirSecao(String titulo) {
  print('───────────────────────────────────────────────────────────');
  print('  📌 $titulo');
  print('───────────────────────────────────────────────────────────');
}
