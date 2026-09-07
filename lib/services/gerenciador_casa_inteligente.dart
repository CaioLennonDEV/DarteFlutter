/// Serviço de gerenciamento centralizado da casa inteligente Cici.
///
/// Responsável por manter a coleção de dispositivos e expor operações
/// usando **obrigatoriamente** manipulação funcional de coleções:
/// `.map()`, `.where()`, `.fold()`, `.any()`, `.every()`, Spread Operators (`...` e `...?`),
/// Collection-If/For, e atribuição nula (`??=`).
///
/// Também demonstra tratamento de exceções com `try-on-catch-finally` e `rethrow`.
library;

import '../exceptions/dispositivo_exceptions.dart';
import '../models/dispositivo_inteligente.dart';
import '../models/lampada.dart';
import '../models/termostato.dart';
import '../models/sensor.dart';

/// Gerenciador central de todos os dispositivos da residência.
class GerenciadorCasaInteligente {
  // ---- Atributo privado: lista de dispositivos e preferências ----

  /// Lista interna de dispositivos registrados.
  final List<DispositivoInteligente> _dispositivos = [];

  /// Dicionário de preferências e metadados de telemetria do sistema.
  final Map<String, String> _preferenciasSistema = {};

  /// Nome da residência.
  final String nomeResidencia;

  /// Construtor com nome da residência.
  GerenciadorCasaInteligente({this.nomeResidencia = 'Minha Casa'});

  // ==========================================================================
  // ATRIBUIÇÃO NULA (??=) E CONFIGURAÇÕES
  // ==========================================================================

  /// Registra ou inicializa uma configuração do sistema se ela ainda não existir.
  ///
  /// Aplica rigorosamente o operador de atribuição nula (**??=**) exigido pelo Requisito 3.
  void registrarConfiguracaoPadrao(String chave, String? valorSugerido) {
    _preferenciasSistema[chave] ??= valorSugerido ?? 'PADRÃO';
  }

  /// Retorna as preferências registradas no sistema.
  Map<String, String> get preferenciasSistema =>
      Map.unmodifiable(_preferenciasSistema);

  // ==========================================================================
  // CRUD DE DISPOSITIVOS
  // ==========================================================================

  /// Retorna uma cópia imutável da lista de dispositivos.
  List<DispositivoInteligente> get dispositivos =>
      List.unmodifiable(_dispositivos);

  /// Total de dispositivos cadastrados.
  int get totalDispositivos => _dispositivos.length;

  /// Adiciona um dispositivo ao sistema.
  ///
  /// Lança [EstadoInvalidoException] se já existir um dispositivo com o mesmo ID.
  void adicionarDispositivo(DispositivoInteligente dispositivo) {
    final jaExiste = _dispositivos.any((d) => d.id == dispositivo.id);
    if (jaExiste) {
      throw EstadoInvalidoException(
        campo: 'id',
        valorRecebido: dispositivo.id,
        mensagem:
            'Já existe um dispositivo cadastrado com o ID "${dispositivo.id}".',
      );
    }
    _dispositivos.add(dispositivo);
  }

  /// Adiciona múltiplos dispositivos de uma vez usando **Spread Operator**.
  void adicionarVarios(List<DispositivoInteligente> novos) {
    for (final d in novos) {
      final jaExiste = _dispositivos.any((e) => e.id == d.id);
      if (jaExiste) {
        throw EstadoInvalidoException(
          campo: 'id',
          valorRecebido: d.id,
          mensagem:
              'Já existe um dispositivo cadastrado com o ID "${d.id}".',
        );
      }
    }
    // Uso do Spread Operator (...) para combinar listas
    _dispositivos.addAll([..._dispositivos, ...novos]
        .where((d) => !_dispositivos.contains(d))
        .toList());
  }

  /// Remove um dispositivo pelo ID.
  void removerDispositivo(String id) {
    final index = _dispositivos.indexWhere((d) => d.id == id);
    if (index == -1) {
      throw DispositivoNaoEncontradoException(idProcurado: id);
    }
    _dispositivos.removeAt(index);
  }

  /// Busca um dispositivo pelo ID.
  DispositivoInteligente buscarPorId(String id) {
    final dispositivo = _dispositivos
        .where((d) => d.id == id)
        .toList();
    if (dispositivo.isEmpty) {
      throw DispositivoNaoEncontradoException(idProcurado: id);
    }
    return dispositivo.first;
  }

  // ==========================================================================
  // FILTRAGENS COM .where()
  // ==========================================================================

  /// Retorna todos os dispositivos que estão **ligados**.
  List<DispositivoInteligente> get dispositivosLigados =>
      _dispositivos.where((d) => d.ligado).toList();

  /// Retorna todos os dispositivos que estão **desligados**.
  List<DispositivoInteligente> get dispositivosDesligados =>
      _dispositivos.where((d) => !d.ligado).toList();

  /// Retorna todos os dispositivos online (conectados à rede móvel/IoT).
  List<DispositivoInteligente> get dispositivosConectados =>
      _dispositivos.where((d) => d.conectadoRede).toList();

  /// Retorna todas as lâmpadas cadastradas.
  List<Lampada> get lampadas =>
      _dispositivos.whereType<Lampada>().toList();

  /// Retorna todos os termostatos cadastrados.
  List<Termostato> get termostatos =>
      _dispositivos.whereType<Termostato>().toList();

  /// Retorna todos os sensores cadastrados.
  List<Sensor> get sensores =>
      _dispositivos.whereType<Sensor>().toList();

  /// Filtra dispositivos por cômodo com acesso seguro (`?.`).
  List<DispositivoInteligente> dispositivosPorComodo(String comodo) =>
      _dispositivos
          .where((d) => d.comodo?.toLowerCase() == comodo.toLowerCase())
          .toList();

  /// Retorna sensores que estão em estado de alerta.
  List<Sensor> get sensoresEmAlerta =>
      sensores.where((s) => s.emAlerta).toList();

  /// Retorna dispositivos aptos para operação com base no nível mínimo de bateria.
  /// (Conforme exemplo de referência de telemetria do edital).
  List<DispositivoInteligente> obterDispositivosAptos({int nivelMinimoBateria = 20}) {
    return _dispositivos
        .where((d) => (d.nivelBateria ?? 100) >= nivelMinimoBateria)
        .toList();
  }

  // ==========================================================================
  // TRANSFORMAÇÕES COM .map()
  // ==========================================================================

  /// Retorna uma lista de descrições textuais de todos os dispositivos.
  List<String> get descricoesTodosDispositivos =>
      _dispositivos.map((d) => d.toString()).toList();

  /// Retorna os nomes de todos os dispositivos ligados.
  List<String> get nomesDispositivosLigados =>
      dispositivosLigados.map((d) => d.nome).toList();

  // ==========================================================================
  // AGREGAÇÃO COM .fold()
  // ==========================================================================

  /// Calcula o consumo total de energia de todos os dispositivos que
  /// possuem o mixin [MonitoramentoEnergiaMixin].
  double get consumoTotalKwh {
    return _dispositivos
        .where((d) => d is MonitoramentoEnergiaMixin)
        .fold<double>(
          0.0,
          (total, d) =>
              total + (d as MonitoramentoEnergiaMixin).consumoAcumuladoKwh,
        );
  }

  /// Conta o número total de dispositivos ligados usando `.fold()`.
  int get totalLigados => _dispositivos.fold<int>(
        0,
        (count, d) => count + (d.ligado ? 1 : 0),
      );

  /// Calcula a média aritmética de bateria de todos os dispositivos sem fio.
  double calcularMediaBateria() {
    final dispositivosComBateria =
        _dispositivos.where((d) => d.nivelBateria != null).toList();
    if (dispositivosComBateria.isEmpty) return 0.0;
    final total = dispositivosComBateria.fold<int>(
      0,
      (soma, d) => soma + (d.nivelBateria ?? 0),
    );
    return total / dispositivosComBateria.length;
  }

  // ==========================================================================
  // VERIFICAÇÃO COM .any() E .every()
  // ==========================================================================

  /// Verifica se existe algum sensor em estado de alerta via `.any()`.
  bool get existeAlerta =>
      _dispositivos.any((d) => d is Sensor && (d).emAlerta);

  /// Verifica se existe algum dispositivo ligado via `.any()`.
  bool get existeDispositivoLigado => _dispositivos.any((d) => d.ligado);

  /// Verifica se todos os dispositivos cadastrados estão conectados à rede via `.every()`.
  bool get todosConectadosRede =>
      _dispositivos.every((d) => d.conectadoRede);

  /// Verifica se todos os dispositivos sem fio possuem bateria acima do limiar mínimo via `.every()`.
  bool todosComBateriaSuficiente({int nivelMinimo = 15}) {
    final dispositivosComBateria =
        _dispositivos.where((d) => d.nivelBateria != null).toList();
    if (dispositivosComBateria.isEmpty) return true;
    return dispositivosComBateria.every((d) => (d.nivelBateria ?? 0) >= nivelMinimo);
  }

  // ==========================================================================
  // RELATÓRIOS COM Collection-If, Collection-For E Spread Operators (... e ...?)
  // ==========================================================================

  /// Gera um relatório completo do estado da residência.
  ///
  /// Demonstra **Collection-If**, **Collection-For**, **Spread Operator (`...`)**
  /// e **Null-aware Spread Operator (`...?`)**.
  List<String> gerarRelatorio({
    List<String>? notasAdicionais,
    List<String>? rotasTelemetriaExtras,
  }) {
    final alertas = sensoresEmAlerta;

    return [
      // Cabeçalho
      '╔══════════════════════════════════════════════════╗',
      '║        🏠 RELATÓRIO CICI — $nomeResidencia',
      '╚══════════════════════════════════════════════════╝',
      '',
      '📊 Resumo Geral:',
      '   Total de dispositivos: $totalDispositivos',
      '   Ligados: $totalLigados | Desligados: ${totalDispositivos - totalLigados}',
      '   Rede 100% Conectada? ${todosConectadosRede ? "SIM" : "NÃO (Dispositivos Offline)"}',
      '   Média de Bateria dos Sensores: ${calcularMediaBateria().toStringAsFixed(1)}%',
      '   Consumo acumulado: ${consumoTotalKwh.toStringAsFixed(3)} kWh',
      '',

      // Collection-If: seção de alertas condicionais
      if (alertas.isNotEmpty) ...[
        '🚨 ALERTAS ATIVOS (${alertas.length}):',
        // Collection-For: itera sobre alertas gerando linhas
        for (final sensor in alertas)
          '   ⚠️ ${sensor.nome} (${sensor.tipo.rotulo}): '
              '${sensor.leituraFormatada} (Bateria: ${sensor.nivelBateria ?? 100}%)',
        '',
      ],

      // Collection-If com alternativa
      if (alertas.isEmpty) '✅ Nenhum alerta ativo — ambiente seguro.',
      '',

      '💡 Lâmpadas (${lampadas.length}):',
      for (final l in lampadas)
        '   ${l.ligado ? "💡" : "⚫"} ${l.nome} — '
            'Brilho: ${l.brilho}% | '
            'Consumo: ${l.consumoAcumuladoKwh.toStringAsFixed(3)} kWh',
      '',

      '🌡️ Termostatos (${termostatos.length}):',
      for (final t in termostatos)
        '   ${t.ligado ? "🔥" : "⚫"} ${t.nome} — '
            'Alvo: ${t.temperaturaAlvo}°C | '
            'Atual: ${t.temperaturaAtual}°C | '
            'Modo: ${t.modo.rotulo}',
      '',

      '📡 Sensores (${sensores.length}):',
      for (final s in sensores)
        '   ${s.emAlerta ? "🚨" : "📡"} ${s.nome} (${s.tipo.rotulo}) — '
            '${s.leituraFormatada} | Bateria: ${s.nivelBateria ?? 100}% | '
            'Rede: ${s.conectadoRede ? "Conectado" : "Queda de Sinal"}',
      '',

      // Spread Operator (...) com lista de dispositivos ligados
      if (nomesDispositivosLigados.isNotEmpty) ...[
        '🔌 Dispositivos atualmente ligados:',
        ...nomesDispositivosLigados.map((n) => '   • $n'),
        '',
      ],

      // Null-aware Spread Operator (...?) para listas opcionais de notas ou telemetria
      if (notasAdicionais != null) '📝 Notas Adicionais:',
      ...?notasAdicionais?.map((nota) => '   📌 $nota'),

      if (rotasTelemetriaExtras != null) '🛰️ Rotas de Telemetria Extras:',
      ...?rotasTelemetriaExtras?.map((rota) => '   📡 $rota'),
    ];
  }

  // ==========================================================================
  // OPERAÇÕES COM TRATAMENTO DE EXCEÇÕES E RETHROW
  // ==========================================================================

  /// Executa processamento de carga de trabalho e telemetria crítica em um dispositivo.
  ///
  /// Intercepta violações de recursos móveis e conectividade, registra em log de auditoria
  /// e utiliza **`rethrow`** para relançar a exceção para que a rotina cliente decida
  /// o tratamento apropriado (atendendo ao Requisito 3).
  void executarProcessamentoComRethrow(String id, double intensidade) {
    final dispositivo = buscarPorId(id);
    try {
      dispositivo.processarCargaTrabalho(intensidade);
    } on RecursoCriticoException catch (e) {
      if (dispositivo is LogAuditoriaMixin) {
        (dispositivo as LogAuditoriaMixin).registrarLog(
          '🚨 [GERENCIADOR] Falha de hardware interceptada: ${e.mensagem}. Relançando com rethrow.',
        );
      }
      // Relançamento obrigatório pelo Requisito 3
      rethrow;
    } on FalhaConectividadeException catch (e) {
      if (dispositivo is LogAuditoriaMixin) {
        (dispositivo as LogAuditoriaMixin).registrarLog(
          '🚨 [GERENCIADOR] Queda de rede interceptada: ${e.mensagem}. Relançando com rethrow.',
        );
      }
      rethrow;
    } finally {
      if (dispositivo is LogAuditoriaMixin) {
        (dispositivo as LogAuditoriaMixin).registrarLog(
          '🏁 [GERENCIADOR] Ciclo de telemetria concluído para o dispositivo "$id".',
        );
      }
    }
  }

  /// Liga um dispositivo pelo ID com tratamento robusto de exceções `try-on-catch-finally`.
  String ligarDispositivoSeguro(String id) {
    String resultado = '';
    try {
      final dispositivo = buscarPorId(id);
      dispositivo.ligar();
      resultado = '✅ Dispositivo "${dispositivo.nome}" ligado com sucesso.';
    } on DispositivoNaoEncontradoException catch (e) {
      resultado = '❌ Erro: ${e.mensagem}';
    } on DispositivoOfflineException catch (e) {
      resultado = '❌ Erro inesperado de estado: ${e.mensagem}';
    } on EstadoInvalidoException catch (e) {
      resultado = '❌ Estado inválido: ${e.mensagem}';
    } catch (e) {
      resultado = '❌ Erro inesperado: $e';
    } finally {
      resultado += '\n   [finally] Operação ligar concluída para ID "$id".';
    }
    return resultado;
  }

  /// Desliga um dispositivo pelo ID com tratamento robusto de exceções.
  String desligarDispositivoSeguro(String id) {
    String resultado = '';
    try {
      final dispositivo = buscarPorId(id);
      dispositivo.desligar();
      resultado =
          '✅ Dispositivo "${dispositivo.nome}" desligado com sucesso.';
    } on DispositivoNaoEncontradoException catch (e) {
      resultado = '❌ Erro: ${e.mensagem}';
    } catch (e) {
      resultado = '❌ Erro inesperado: $e';
    } finally {
      resultado +=
          '\n   [finally] Operação desligar concluída para ID "$id".';
    }
    return resultado;
  }

  /// Tenta ajustar a temperatura de um termostato com tratamento completo.
  String ajustarTemperaturaSeguro(String id, double novaTemperatura) {
    String resultado = '';
    try {
      final dispositivo = buscarPorId(id);
      if (dispositivo is! Termostato) {
        throw EstadoInvalidoException(
          campo: 'tipo',
          valorRecebido: dispositivo.runtimeType.toString(),
          mensagem:
              'O dispositivo "${dispositivo.nome}" não é um Termostato.',
        );
      }
      dispositivo.temperaturaAlvo = novaTemperatura;
      resultado = '✅ Temperatura de "${dispositivo.nome}" ajustada '
          'para ${novaTemperatura}°C.';
    } on DispositivoNaoEncontradoException catch (e) {
      resultado = '❌ ${e.mensagem}';
    } on DispositivoOfflineException catch (e) {
      resultado = '❌ ${e.mensagem}';
    } on EstadoInvalidoException catch (e) {
      resultado = '❌ ${e.mensagem}';
    } catch (e) {
      resultado = '❌ Erro inesperado: $e';
    } finally {
      resultado += '\n   [finally] Operação ajustarTemperatura concluída '
          'para ID "$id" (valor: $novaTemperatura°C).';
    }
    return resultado;
  }

  /// Tenta ajustar o brilho de uma lâmpada com tratamento completo.
  String ajustarBrilhoSeguro(String id, int novoBrilho) {
    String resultado = '';
    try {
      final dispositivo = buscarPorId(id);
      if (dispositivo is! Lampada) {
        throw EstadoInvalidoException(
          campo: 'tipo',
          valorRecebido: dispositivo.runtimeType.toString(),
          mensagem: 'O dispositivo "${dispositivo.nome}" não é uma Lâmpada.',
        );
      }
      dispositivo.brilho = novoBrilho;
      resultado = '✅ Brilho de "${dispositivo.nome}" ajustado para $novoBrilho%.';
    } on DispositivoNaoEncontradoException catch (e) {
      resultado = '❌ ${e.mensagem}';
    } on DispositivoOfflineException catch (e) {
      resultado = '❌ ${e.mensagem}';
    } on EstadoInvalidoException catch (e) {
      resultado = '❌ ${e.mensagem}';
    } catch (e) {
      resultado = '❌ Erro inesperado: $e';
    } finally {
      resultado += '\n   [finally] Operação ajustarBrilho concluída '
          'para ID "$id" (valor: $novoBrilho%).';
    }
    return resultado;
  }
}
