# 🏠 Cici — Automação e Monitoramento Residencial Inteligente

[![Flutter](https://img.shields.io/badge/Flutter-3.x-02569B?style=for-the-badge&logo=flutter&logoColor=white)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.x-0175C2?style=for-the-badge&logo=dart&logoColor=white)](https://dart.dev)
[![Docker](https://img.shields.io/badge/Docker-Multi--stage-2496ED?style=for-the-badge&logo=docker&logoColor=white)](https://www.docker.com/)
[![Arquitetura](https://img.shields.io/badge/Arquitetura-Camadas-FF9800?style=for-the-badge)]()
[![POO](https://img.shields.io/badge/POO-Avançada-10B981?style=for-the-badge)]()

> **Cici** é um app de Automação e Monitoramento de Dispositivos Residenciais Inteligentes desenvolvido em **Flutter** com visual dark premium estilo **Alexa/Google Home**. Controle lâmpadas, termostatos e sensores com interface interativa. Projeto acadêmico de Computação Móvel — Tema 09.

---

## 📸 Recursos Principais

- 💡 **Controle de Lâmpadas**: Ligar/desligar, slider de brilho (0–100%), cor hexadecimal, modo econômico pré-configurado.
- 🌡️ **Gerenciamento de Termostatos**: Slider de temperatura-alvo (16°C–32°C), modos de operação (aquecimento, resfriamento, automático).
- 📡 **Monitoramento de Sensores**: Sensores de temperatura, umidade, movimento, fumaça e luminosidade com sistema de alerta por limiar.
- 🏠 **Dashboard Inteligente**: Grid de dispositivos com filtro por cômodo, stat cards de resumo, e navegação fluida.
- 📋 **Log de Auditoria (Mixin)**: Registro automático de todas as ações com timestamp.
- ⚡ **Monitoramento de Energia (Mixin)**: Rastreamento de consumo acumulado em kWh.
- 🚨 **Alertas em Tempo Real**: Painel de alertas com notificação visual animada.
- 🎨 **Visual Dark Premium**: Glassmorphism, micro-animações, Google Fonts (Inter + Outfit).

---

## 🏗️ Arquitetura em Camadas

```
DarteFlutter/
├── bin/
│   └── main.dart                          # CLI executável (Dart puro)
├── lib/
│   ├── main.dart                          # Entry point Flutter
│   ├── models/
│   │   ├── dispositivo_inteligente.dart   # Classe abstrata + Mixins
│   │   ├── lampada.dart                   # Herança: Lâmpada
│   │   ├── termostato.dart                # Herança: Termostato
│   │   └── sensor.dart                    # Herança: Sensor
│   ├── exceptions/
│   │   └── dispositivo_exceptions.dart    # Exceções customizadas
│   ├── services/
│   │   └── gerenciador_casa_inteligente.dart  # Serviço central
│   └── presentation/
│       ├── theme/
│       │   └── cici_theme.dart            # Design system dark premium
│       ├── controllers/
│       │   └── casa_controller.dart       # ChangeNotifier (Provider)
│       ├── screens/
│       │   ├── home_screen.dart           # Dashboard principal
│       │   ├── device_detail_screen.dart  # Detalhe/controle do dispositivo
│       │   └── alerts_screen.dart         # Painel de alertas e logs
│       └── widgets/
│           ├── device_card.dart           # Card de dispositivo
│           ├── room_chip.dart             # Chip de cômodo
│           ├── stat_card.dart             # Card de estatística
│           └── status_indicator.dart      # Indicador de status
├── pubspec.yaml
├── Dockerfile                             # Multi-stage (Flutter Web + Nginx)
└── docker-compose.yml
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
| 3a | Null Safety sem operador `!` | ✅ | Projeto inteiro (`?`, `??`, `?.`) |
| 3b | Coleções funcionais (`.map`, `.where`, `.fold`, `.any`, spread, collection-if/for) | ✅ | `GerenciadorCasaInteligente` |
| 4a | Exceções customizadas (`extends Exception`) | ✅ | `dispositivo_exceptions.dart` |
| 4b | `try-on-catch-finally` | ✅ | `bin/main.dart` + serviço |
| 5 | Arquivo executável CLI (`bin/main.dart`) | ✅ | 8 cenários de teste |

---

## 🚀 Como Executar

### Flutter Web via Docker (Recomendado)

```bash
docker compose up --build
# Acesse http://localhost:8080
```

### Flutter Local

```bash
flutter pub get
flutter run -d chrome
```

### CLI Dart Puro

```bash
dart run bin/main.dart
```

---

## 🛠️ Tecnologias

| Tecnologia | Uso |
|------------|-----|
| Flutter 3.x | Framework UI |
| Dart 3.x | Linguagem principal |
| Provider | Gerenciamento de estado |
| Google Fonts | Tipografia (Inter, Outfit) |
| Flutter Animate | Micro-animações |
| Docker + Nginx | Deploy Web containerizado |

---

## 👤 Autor

Projeto acadêmico de **Computação Móvel** — Tema 09: Automação e Monitoramento de Dispositivos Residenciais.
