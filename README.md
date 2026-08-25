# 🏠 Cici — Automação e Monitoramento Residencial Inteligente

[![Dart](https://img.shields.io/badge/Dart-3.x-0175C2?style=for-the-badge&logo=dart&logoColor=white)](https://dart.dev)
[![Docker](https://img.shields.io/badge/Docker-CLI-2496ED?style=for-the-badge&logo=docker&logoColor=white)](https://www.docker.com/)
[![Arquitetura](https://img.shields.io/badge/Arquitetura-Camadas-FF9800?style=for-the-badge)]()
[![POO](https://img.shields.io/badge/POO-Avançada-10B981?style=for-the-badge)]()

> **Cici** é um Módulo Central de Domínio (Dart Puro, sem UI/Flutter) para controle de estados de **sensores**, **termostatos** e **luzes inteligentes** em ambientes residenciais. Projeto acadêmico de Computação Móvel — Tema 09.

---

## 📸 Recursos Principais

- 💡 **Controle de Lâmpadas**: Ligar/desligar, ajustar brilho (0–100%) e cor (hexadecimal), modo econômico pré-configurado.
- 🌡️ **Gerenciamento de Termostatos**: Controle de temperatura-alvo (16°C–32°C), modos de operação (aquecimento, resfriamento, automático).
- 📡 **Monitoramento de Sensores**: Sensores de temperatura, umidade, movimento, fumaça e luminosidade com sistema de alerta por limiar.
- 📋 **Log de Auditoria (Mixin)**: Registro automático de todas as ações com timestamp via `LogAuditoriaMixin`.
- ⚡ **Monitoramento de Energia (Mixin)**: Rastreamento de consumo acumulado em kWh via `MonitoramentoEnergiaMixin`.
- 🚨 **Exceções Customizadas**: Tratamento semântico de erros com `DispositivoOfflineException`, `EstadoInvalidoException` e `DispositivoNaoEncontradoException`.
- 📊 **Relatórios Inteligentes**: Geração dinâmica de relatórios com Collection-If/For e Spread Operators.

---

## 🏗️ Arquitetura em Camadas

```
DarteFlutter/
├── bin/
│   └── main.dart                          # CLI executável (ponto de entrada)
├── lib/
│   ├── models/                            # ✅ MANTIDO (domínio)
│   │   ├── dispositivo_inteligente.dart   # Classe abstrata + Mixins
│   │   ├── lampada.dart                   # Herança: Lâmpada Inteligente
│   │   ├── termostato.dart                # Herança: Termostato Inteligente
│   │   └── sensor.dart                    # Herança: Sensor Inteligente
│   ├── exceptions/
│   │   └── dispositivo_exceptions.dart    # Exceções customizadas
│   └── services/
│       └── gerenciador_casa_inteligente.dart  # Serviço central (coleções funcionais)
├── pubspec.yaml                           # Dart puro (sem Flutter)
├── Dockerfile                             # Container Dart CLI
└── docker-compose.yml                     # Orquestração Docker
```

---

## 🎯 Checklist Técnico Implementado

| # | Requisito | Status | Localização |
|---|-----------|--------|-------------|
| 1a | Classe abstrata com contratos | ✅ | `DispositivoInteligente` |
| 1b | Herança (`extends`, `super`, `@override toString()`) | ✅ | `Lampada`, `Termostato`, `Sensor` |
| 1c | Mixin (`with`) | ✅ | `LogAuditoriaMixin`, `MonitoramentoEnergiaMixin` |
| 1d | Encapsulamento estrito (`_`, getters/setters, validação, `final`) | ✅ | Todos os modelos |
| 2a | Construtor padrão gerativo (`this.atributo`) | ✅ | Todos os modelos |
| 2b | Construtor nomeado | ✅ | `.modoEconomico()`, `.configuracaoPadrao()`, `.temperatura()` |
| 2c | Construtor `factory` com validação | ✅ | `.fromMap()` em todos os modelos |
| 3a | Null Safety sem operador `!` | ✅ | Projeto inteiro (`?`, `??`, `?.`, `??=`) |
| 3b | Coleções funcionais (`.map`, `.where`, `.fold`, `.any`, spread, collection-if/for) | ✅ | `GerenciadorCasaInteligente` |
| 4a | Exceções customizadas (`extends Exception`) | ✅ | `dispositivo_exceptions.dart` |
| 4b | `try-on-catch-finally` | ✅ | `bin/main.dart` + serviço |
| 5 | Arquivo executável CLI (`bin/main.dart`) | ✅ | 8 cenários de teste demonstrados |

---

## 🚀 Como Executar

### Via Docker (Recomendado)

```bash
docker compose up --build
```

### Via Dart SDK (Local)

```bash
dart pub get
dart run bin/main.dart
```

---

## 📝 Cenários de Teste no CLI

O `bin/main.dart` simula automaticamente:

1. **Cadastro** de lâmpadas, termostatos e sensores (3 de cada, usando os 3 tipos de construtores).
2. **Operações** de ligar/desligar, ajustar brilho e temperatura, registrar leituras.
3. **Filtragens funcionais** com `.where()`, `.map()`, `.fold()`, `.any()`.
4. **8 cenários de erro forçados**:
   - Temperatura abaixo de 16°C
   - Temperatura acima de 32°C
   - Brilho em lâmpada desligada
   - Dispositivo com ID inexistente
   - Leitura em sensor offline
   - Factory com dados inválidos
   - Inserção de ID duplicado
   - Leitura acima do limiar de alerta
5. **Log de auditoria** (mixin) com histórico de ações.
6. **Relatório final** com Collection-If/For e Spread Operators.

---

## 🛠️ Tecnologias

| Tecnologia | Versão | Uso |
|------------|--------|-----|
| Dart | ≥ 3.0.0 | Linguagem principal (Dart Puro) |
| Docker | Latest | Containerização e execução |

---

## 👤 Autor

Projeto acadêmico de **Computação Móvel** — Tema 09: Automação e Monitoramento de Dispositivos Residenciais.
