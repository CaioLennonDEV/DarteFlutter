/// Serviço de gerenciamento centralizado da casa inteligente Cici.
///
/// Responsável por manter a coleção de dispositivos e expor operações
/// usando **obrigatoriamente** manipulação funcional de coleções:
/// `.map()`, `.where()`, `.fold()`, `.any()`, Spread Operators (`...`),
/// e Collection-If/For.
///
/// Também demonstra tratamento de exceções com `try-on-catch-finally`.
library;

import '../exceptions/dispositivo_exceptions.dart';
import '../models/dispositivo_inteligente.dart';
import '../models/lampada.dart';
import '../models/termostato.dart';
import '../models/sensor.dart';

/// Gerenciador central de todos os dispositivos da residência.
class GerenciadorCasaInteligente {
  // ---- Atributo privado: lista de dispositivos ----

  /// Lista interna de dispositivos registrados.
  final List<DispositivoInteligente> _dispositivos = [];

  /// Nome da residência.
  final String nomeResidencia;

  /// Construtor com nome da residência.
  GerenciadorCasaInteligente({this.nomeResidencia = 'Minha Casa'});

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
  /// Lança [EstadoInvalidoException] se já existir um dispositivo com o
  /// mesmo ID.
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
    // Validação: nenhum ID duplicado
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
    // Uso do Spread Operator para combinar listas
    _dispositivos.addAll([..._dispositivos, ...novos]
        .where((d) => !_dispositivos.contains(d))
        .toList());
  }

  /// Remove um dispositivo pelo ID.
  ///
  /// Lança [DispositivoNaoEncontradoException] se não encontrar.
  void removerDispositivo(String id) {
    final index = _dispositivos.indexWhere((d) => d.id == id);
    if (index == -1) {
      throw DispositivoNaoEncontradoException(idProcurado: id);
    }
    _dispositivos.removeAt(index);
  }

  /// Busca um dispositivo pelo ID.
  ///
  /// Lança [DispositivoNaoEncontradoException] se não encontrar.
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
  ///
  /// Usa `.where()` para filtragem funcional.
  List<DispositivoInteligente> get dispositivosLigados =>
      _dispositivos.where((d) => d.ligado).toList();

  /// Retorna todos os dispositivos que estão **desligados**.
  List<DispositivoInteligente> get dispositivosDesligados =>
      _dispositivos.where((d) => !d.ligado).toList();

  /// Retorna todas as lâmpadas cadastradas.
  List<Lampada> get lampadas =>
      _dispositivos.whereType<Lampada>().toList();

  /// Retorna todos os termostatos cadastrados.
  List<Termostato> get termostatos =>
      _dispositivos.whereType<Termostato>().toList();

  /// Retorna todos os sensores cadastrados.
  List<Sensor> get sensores =>
      _dispositivos.whereType<Sensor>().toList();

  /// Filtra dispositivos por cômodo.
  ///
  /// Usa `?.` para tratar cômodos nulos com segurança.
  List<DispositivoInteligente> dispositivosPorComodo(String comodo) =>
      _dispositivos
          .where((d) => d.comodo?.toLowerCase() == comodo.toLowerCase())
          .toList();

  /// Retorna sensores que estão em estado de alerta.
  List<Sensor> get sensoresEmAlerta =>
      sensores.where((s) => s.emAlerta).toList();

  // ==========================================================================
  // TRANSFORMAÇÕES COM .map()
  // ==========================================================================

  /// Retorna uma lista de descrições textuais de todos os dispositivos.
  ///
  /// Usa `.map()` para transformar cada dispositivo em sua representação
  /// string via `toString()`.
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
  ///
  /// Usa `.where()` + `.fold()` para agregação funcional.
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

  // ==========================================================================
  // VERIFICAÇÃO COM .any()
  // ==========================================================================

  /// Verifica se existe algum sensor em estado de alerta.
  ///
  /// Usa `.any()` para verificação booleana eficiente.
  bool get existeAlerta =>
      _dispositivos.any((d) => d is Sensor && (d).emAlerta);

  /// Verifica se existe algum dispositivo ligado.
  bool get existeDispositivoLigado => _dispositivos.any((d) => d.ligado);

  /// Verifica se existe algum dispositivo num dado cômodo.
  bool existeDispositivoNoComodo(String comodo) =>
      _dispositivos.any(
          (d) => d.comodo?.toLowerCase() == comodo.toLowerCase());

  // ==========================================================================
  // RELATÓRIOS COM Collection-If, Collection-For E Spread Operator
  // ==========================================================================

  /// Gera um relatório completo do estado da residência.
  ///
  /// Demonstra **Collection-If**, **Collection-For** e **Spread Operator**.
  List<String> gerarRelatorio() {
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
      '   Consumo total: ${consumoTotalKwh.toStringAsFixed(3)} kWh',
      '',

      // Collection-If: só mostra seção de alertas se existirem
      if (alertas.isNotEmpty) ...[
        '🚨 ALERTAS ATIVOS (${alertas.length}):',
        // Collection-For: itera sobre alertas gerando linhas
        for (final sensor in alertas)
          '   ⚠️ ${sensor.nome} (${sensor.tipo.rotulo}): '
              '${sensor.leituraFormatada}',
        '',
      ],

      // Collection-If: mensagem de "tudo ok" se não houver alertas
      if (alertas.isEmpty) '✅ Nenhum alerta ativo — tudo operando normalmente.',
      '',

      '💡 Lâmpadas (${lampadas.length}):',
      // Collection-For sobre lâmpadas
      for (final l in lampadas)
        '   ${l.ligado ? "💡" : "⚫"} ${l.nome} — '
            'Brilho: ${l.brilho}% | '
            'Consumo: ${l.consumoAcumuladoKwh.toStringAsFixed(3)} kWh',
      '',

      '🌡️ Termostatos (${termostatos.length}):',
      // Collection-For sobre termostatos
      for (final t in termostatos)
        '   ${t.ligado ? "🔥" : "⚫"} ${t.nome} — '
            'Alvo: ${t.temperaturaAlvo}°C | '
            'Atual: ${t.temperaturaAtual}°C | '
            'Modo: ${t.modo.rotulo}',
      '',

      '📡 Sensores (${sensores.length}):',
      // Collection-For sobre sensores
      for (final s in sensores)
        '   ${s.emAlerta ? "🚨" : "📡"} ${s.nome} (${s.tipo.rotulo}) — '
            '${s.leituraFormatada}',
      '',

      // Spread Operator: adiciona nomes dos dispositivos ligados
      if (nomesDispositivosLigados.isNotEmpty) ...[
        '🔌 Dispositivos atualmente ligados:',
        ...nomesDispositivosLigados.map((n) => '   • $n'),
      ],
    ];
  }

  // ==========================================================================
  // OPERAÇÕES COM TRATAMENTO DE EXCEÇÕES (try-on-catch-finally)
  // ==========================================================================

  /// Liga um dispositivo pelo ID com tratamento robusto de exceções.
  ///
  /// Demonstra o uso de `try-on-catch-finally` com exceções customizadas.
  ///
  /// Retorna uma mensagem descritiva do resultado da operação.
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
      // Log de auditoria da tentativa (sempre executa)
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
  ///
  /// Retorna mensagem descritiva. Demonstra `try-on-catch-finally`.
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
