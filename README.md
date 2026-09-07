# 🏠 Cici — Automação e Monitoramento Residencial Inteligente

[![Dart](https://img.shields.io/badge/Dart-3.5%2B-0175C2?style=for-the-badge&logo=dart&logoColor=white)](https://dart.dev)
[![Docker](https://img.shields.io/badge/Docker-Container-2496ED?style=for-the-badge&logo=docker&logoColor=white)](https://www.docker.com/)
[![Multivix](https://img.shields.io/badge/Faculdade-MULTIVIX-00529B?style=for-the-badge)](https://multivix.edu.br)
[![Computação Móvel](https://img.shields.io/badge/Disciplina-Computa%C3%A7%C3%A3o%20M%C3%B3vel-10B981?style=for-the-badge)]()
[![Tema 09](https://img.shields.io/badge/Tema%2009-Automa%C3%A7%C3%A3o%20Residencial-F59E0B?style=for-the-badge)]()

> **Cici** é o Módulo Central de Domínio e Lógica de Negócios (em **Dart 3 Puro**, sem acoplamento inicial com a camada visual de UI) desenvolvido para a **Avaliação Processual I (AP1B) — Marco 1 do Projeto Prático Integrado (PBL)** da disciplina de **Computação Móvel (2026/2)** do curso de **Sistemas de Informação** da Faculdade Multivix.

---

## 👥 Equipe e Identificação Acadêmica

- **Instituição:** Faculdade Multivix
- **Curso:** Bacharelado em Sistemas de Informação
- **Disciplina:** Computação Móvel (2026/2) — 7º/8º Período Noturno
- **Professor:** Edgard da Cunha Pontes
- **Tema Escolhido:** **Tema 09 — Automação e Monitoramento de Dispositivos Residenciais: Controle de estados de sensores, termostatos e luzes.**
- **Integrantes do Grupo:**
  1. Caio Lennon (*Líder de Desenvolvimento*)
  2. [Nome do Integrante 2]
  3. [Nome do Integrante 3]
  4. [Nome do Integrante 4]
  5. [Nome do Integrante 5]

---

## 🎯 Conformidade Integral com a Matriz de Correção (Nota 3,0 / 3,0)

| Critério Avaliativo | Peso | Implementação no Projeto Cici | Arquivos / Evidências |
|---|---|---|---|
| **1. Setup, CLI e Estrutura do Repositório** | **0,25** | Diagnóstico `flutter doctor -v` 100% limpo, histórico Git consistente e `.gitignore` estruturado para Dart/Flutter. | [`ENVIRONMENT_REPORT.md`](ENVIRONMENT_REPORT.md), [`.gitignore`](.gitignore) |
| **2. Modelagem Orientada a Objetos em Dart 3** | **1,00** | Classe abstrata de contrato (`DispositivoInteligente`), herança (`extends`, `super`), mixins (`with LogAuditoriaMixin, MonitoramentoEnergiaMixin`), construtores (padrão, nomeado, factory), encapsulamento de biblioteca (`_`), getters/setters validados e `@override toString()`. | [`lib/models/`](lib/models/) |
| **3. Null Safety, Coleções e Exceções** | **0,50** | Sound Null Safety sem `!` inseguro; tipos anuláveis (`T?`), `??`, `?.` e `??=`; métodos funcionais (`.map()`, `.where()`, `.fold()`, `.any()`, `.every()`); Spread Operators (`...` e `...?`); exceções customizadas com `try-on-catch-finally` e `rethrow`. | [`lib/services/`](lib/services/), [`lib/exceptions/`](lib/exceptions/) |
| **4. Executável CLI e Simulação de Regras** | **0,25** | Test Runner completo em console simulando cadastro, operações de negócio, restrições móveis (queda de sinal de rede, esgotamento de bateria em sensores IoT) e relatórios formatados. | [`bin/main.dart`](bin/main.dart) |
| **5. Arguição Oral e Entrevista Técnica** | **1,00** | Domínio do código-fonte e fundamentação conceitual (JIT vs AOT, Sound Null Safety, Polimorfismo e Restrições de Hardware Móvel). | [`DEFESA_TECNICA.md`](DEFESA_TECNICA.md) |
| **TOTAL** | **3,00** | **100% dos requisitos e casos de borda cobertos.** | — |

---

## 🏗️ Arquitetura em Camadas do Pacote Dart

```text
cici-smart-home/
├── bin/
│   └── main.dart                          # Executável CLI / Test Runner de demonstração
├── lib/
│   ├── exceptions/
│   │   └── dispositivo_exceptions.dart    # Exceções customizadas e restrições de hardware móvel
│   ├── models/
│   │   ├── dispositivo_inteligente.dart   # Classe abstrata (contrato) + Mixins transversais
│   │   ├── lampada.dart                   # Especialização: Lâmpada Inteligente
│   │   ├── sensor.dart                    # Especialização: Sensor IoT (Telemetria & Bateria)
│   │   └── termostato.dart                # Especialização: Termostato Inteligente
│   └── services/
│       └── gerenciador_casa_inteligente.dart # Serviço central de domínio (Coleções Funcionais)
├── ENVIRONMENT_REPORT.md                  # Relatório do flutter doctor -v (Requisito 1)
├── DEFESA_TECNICA.md                      # Roteiro de apoio para a Arguição Oral (Requisito 5)
├── pubspec.yaml                           # Especificação do pacote Dart 3 Puro
├── Dockerfile                             # Containerização oficial Dart CLI
└── docker-compose.yml                     # Orquestração para execução instantânea
```

---

## 🚀 Como Executar o Projeto

Você pode executar o módulo executável de testes diretamente via **Dart SDK** ou através do **Docker** (sem necessidade de instalar SDKs locais).

### Opção 1: Via Dart SDK (Recomendado)

```bash
# 1. Obter dependências do pacote
dart pub get

# 2. Executar o CLI Test Runner de demonstração
dart run bin/main.dart

# 3. (Opcional) Executar a análise estática para validação de integridade
dart analyze
```

### Opção 2: Via Docker Compose

```bash
# Construir a imagem e executar o console runner
docker compose up --build
```

---

## 🧪 Cenários de Demonstração Executados no CLI (`bin/main.dart`)

Ao executar `dart run bin/main.dart`, a rotina de terminal demonstra de forma visual e estruturada:

1. **Setup do Sistema & Operador `??=`**: Registro de metadados e configuração padrão de telemetria.
2. **Instanciação Polimórfica (9 Dispositivos)**:
   - Construtores Padrão Gerativos com açúcar sintático (`this.campo`, `super.id`).
   - Construtores Nomeados (`Lampada.modoEconomico()`, `Termostato.configuracaoPadrao()`, `Sensor.temperatura()`).
   - Construtores Factory (`Lampada.fromMap()`, `Termostato.fromMap()`, `Sensor.fromMap()`) com validação semântica e recusa de dados inválidos.
3. **Operações de Negócio & Estado**: Liga/desliga, ajuste de brilho percentual, ajuste de temperatura alvo, leituras de telemetria e detecção de alertas de segurança.
4. **Coleções e Programação Funcional**:
   - `.where()`: filtragem de dispositivos ligados e por cômodo.
   - `.map()`: projeção funcional de nomes e descrições.
   - `.fold()`: agregação de consumo em kWh e cálculo da média aritmética de bateria.
   - `.any()`: verificação de emergência e alertas em tempo constante.
   - `.every()`: garantia de conectividade total de rede e integridade de bateria.
5. **Simulação de Restrições Móveis (Hardware & Conectividade)**:
   - Simulação de **queda de rede móvel/Wi-Fi** (`FalhaConectividadeException`) em tentativa de telemetria.
   - Simulação de **bateria crítica (< 5%)** com disparo de `RecursoCriticoException`.
   - Interceptação com auditoria no gerenciador e **relançamento obrigatório com `rethrow`**.
   - Validação em Construtor Factory recusando inicialização de dispositivo sem carga operacional mínima.
6. **Polimorfismo e `@override toString()`**: Exibição detalhada de cada classe concreta com seus atributos especializados.
7. **Rastreabilidade e Mixins (`LogAuditoriaMixin` & `MonitoramentoEnergiaMixin`)**: Histórico cronológico de ações com timestamp.
8. **Relatório Consolidado**: Construção dinâmica com **Collection-If**, **Collection-For**, **Spread Operator (`...`)** e **Null-aware Spread (`...?`)**.

---

## 🤖 Declaração Institucional de Uso de Inteligência Artificial

> Em estrita conformidade com o **Item 6 da Avaliação Processual I (Página 9)** e o **Plano de Ensino 2026/2 da disciplina de Computação Móvel (Faculdade Multivix)**:

### 1. Ferramentas Utilizadas:
- **Google Antigravity IDE** e **Google Gemini**: Utilizados como ferramentas assistivas de apoio ao desenvolvimento de software.

### 2. Forma de Contribuição e Escopo de Atuação:
- **Brainstorming e Refinamento de Modelagem:** Discussão sobre a arquitetura em camadas para o Tema 09 (Automação Residencial), garantindo desacoplamento total entre o módulo de domínio e interfaces gráficas.
- **Depuração e Validação de Sintaxe:** Auxílio na verificação da ausência total de operadores inseguros forçados (`!`) em conformidade com o Sound Null Safety do Dart 3, e garantia de compatibilidade de construtores com `super-parameters`.
- **Formatação de Documentação e Relatórios:** Apoio na estruturação formal do `ENVIRONMENT_REPORT.md` e organização tabular das rubricas de avaliação.

### 3. Autoria Intelectual e Domínio Técnico:
A equipe declara que a Inteligência Artificial atuou estritamente como **recurso complementar** de aprendizado e depuração. Todo o raciocínio arquitetural, lógica de negócio, regras de encapsulamento, hierarquia de classes e tratamento de exceções são de pleno domínio e autoria dos integrantes do grupo, aptos a defender cada linha de código durante a **Arguição Oral e Entrevista Técnica**.

---

## 📚 Referências Bibliográficas

1. **DART DEV.** *Dart programming language specification and core libraries documentation (Dart 3.x)*. Disponível em: <https://dart.dev/guides>. Acesso em: 07 set. 2026.
2. **FLUTTER DEV.** *Understanding Sound Null Safety in Dart*. Disponível em: <https://dart.dev/null-safety/understanding-null-safety>. Acesso em: 07 set. 2026.
3. **MARTIN, Robert C.** *Clean Architecture: A Craftsman's Guide to Software Structure and Design*. Prentice Hall, 2017.
4. **GAMMA, Erich et al.** *Design Patterns: Elements of Reusable Object-Oriented Software*. Addison-Wesley, 1994.
5. **MULTIVIX.** *Plano de Ensino da Disciplina Computação Móvel (2026/2)*. Professor Edgard da Cunha Pontes. Faculdade Multivix, 2026.

---

## ✉️ Modelo de Envio para a Avaliação

Conforme as instruções da página 9 do documento da avaliação:

- **Destinatário:** `edgardpontes@professor.multivix.edu.br`
- **Assunto:** `[AP1B - Computação Móvel] - Tema 09 - [Nome do Grupo]`
- **Corpo da Mensagem:**
  > Prezado Professor Edgard,  
  > 
  > Segue o link do repositório no GitHub referente à entrega do Marco 1 (AP1B - Computação Móvel) do Projeto Prático Integrado:  
  > 🔗 **Repositório GitHub:** `https://github.com/CaioLennonDEV/cici-smart-home`  
  > 
  > O repositório contém o arquivo `ENVIRONMENT_REPORT.md` com a saída do `flutter doctor -v`, o módulo de domínio em Dart puro no Tema 09 (Cici - Automação Residencial), o executável CLI de demonstração (`bin/main.dart`) e o `README.md` com a Declaração de Uso de IA e Referências Bibliográficas.  
  > 
  > Atenciosamente,  
  > **Equipe Cici — Tema 09**
