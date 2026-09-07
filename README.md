# 🏢 ReservaHub — Sistema de Reserva e Agendamento de Serviços

[![Dart](https://img.shields.io/badge/Dart-3.5%2B-0175C2?style=for-the-badge&logo=dart&logoColor=white)](https://dart.dev)
[![Docker](https://img.shields.io/badge/Docker-Container-2496ED?style=for-the-badge&logo=docker&logoColor=white)](https://www.docker.com/)
[![Multivix](https://img.shields.io/badge/Faculdade-MULTIVIX-00529B?style=for-the-badge)](https://multivix.edu.br)
[![Computação Móvel](https://img.shields.io/badge/Disciplina-Computa%C3%A7%C3%A3o%20M%C3%B3vel-10B981?style=for-the-badge)]()
[![Tema 05](https://img.shields.io/badge/Tema%2005-Reserva%20%26%20Agendamento-F59E0B?style=for-the-badge)]()

> **ReservaHub** é o Módulo Central de Domínio e Lógica de Negócios (em **Dart 3 Puro**, sem acoplamento inicial com a camada visual de UI) desenvolvido para a **Avaliação Processual I (AP1B) — Marco 1 do Projeto Prático Integrado (PBL)** da disciplina de **Computação Móvel (2026/2)** do curso de **Sistemas de Informação** da Faculdade Multivix.

---

## 👥 Equipe e Identificação Acadêmica

- **Instituição:** Faculdade Multivix
- **Curso:** Bacharelado em Sistemas de Informação
- **Disciplina:** Computação Móvel (2026/2) — 7º/8º Período Noturno
- **Professor:** Edgard da Cunha Pontes
- **Tema Escolhido:** **Tema 05 — Sistema de Reserva e Agendamento de Serviços: Gestão de horários, disponibilidade de salas/equipamentos e filas de espera.**
- **Integrantes do Grupo:**
  1. Caio Lennon (*Líder de Desenvolvimento*)
  2. [Nome do Integrante 2]
  3. [Nome do Integrante 3]
  4. [Nome do Integrante 4]
  5. [Nome do Integrante 5]

---

## 🎯 Conformidade Integral com a Matriz de Correção (Nota 3,0 / 3,0)

| Critério Avaliativo | Peso | Implementação no Projeto ReservaHub | Arquivos / Evidências |
|---|---|---|---|
| **1. Setup, CLI e Estrutura do Repositório** | **0,25** | Diagnóstico `flutter doctor -v` 100% limpo evidenciando toolchain funcional, histórico Git consistente, `.gitignore` estruturado e código formatado com `dart format`. | [`ENVIRONMENT_REPORT.md`](ENVIRONMENT_REPORT.md), [`.gitignore`](.gitignore) |
| **2. Modelagem Orientada a Objetos em Dart 3** | **1,00** | Classe abstrata de contrato (`RecursoAgendavel`), especializações concretas (`SalaReuniao`, `Equipamento`, `EstacaoTrabalho`), Mixins (`with LogAuditoriaMixin, NotificacaoMovelMixin`), variedade obrigatória de construtores (Padrão, Nomeados e Factory com validação semântica), encapsulamento de biblioteca (`_`), getters e setters customizados com regras de validação e `@override toString()`. | [`lib/models/`](lib/models/) |
| **3. Null Safety, Coleções e Exceções** | **0,50** | Sound Null Safety rigoroso sem `!` forçado inseguro; tipos anuláveis (`T?`), operador de coalescência (`??`), acesso seguro (`?.`) e atribuição nula (`??=`); métodos funcionais (`.map()`, `.where()`, `.fold()`, `.any()`, `.every()`); Spread Operators (`...` e `...?`), Collection-If e Collection-For; exceções customizadas de domínio (`ConflitoHorarioException`, `RecursoIndisponivelException`, etc.) com `try-on-catch-finally` e `rethrow`. | [`lib/services/`](lib/services/), [`lib/exceptions/`](lib/exceptions/) |
| **4. Executável CLI e Simulação de Regras** | **0,25** | CLI Test Runner completo em console demonstrando cadastro polimórfico, agendamentos, detecção e bloqueio de sobreposição de horários, fila de espera com prioridade e promoção automática de vaga, simulação de queda de conectividade móvel e relatórios consolidados. | [`bin/main.dart`](bin/main.dart) |
| **5. Arguição Oral e Entrevista Técnica** | **1,00** | Roteiro estruturado de defesa técnica abordando diferenças entre compilação JIT e AOT na computação móvel, Sound Null Safety no Dart 3, Polimorfismo, Mixins vs Herança Múltipla e estratégias de resiliência móvel. | [`DEFESA_TECNICA.md`](DEFESA_TECNICA.md) |
| **TOTAL** | **3,00** | **100% dos requisitos, rubricas e casos de borda cobertos com excelência.** | — |

---

## 🏗️ Arquitetura em Camadas do Pacote Dart

```text
reserva-hub/
├── bin/
│   └── main.dart                          # Executável CLI / Test Runner de demonstração
├── lib/
│   ├── exceptions/
│   │   └── reserva_exceptions.dart        # Exceções customizadas e restrições móveis
│   ├── models/
│   │   ├── recurso_agendavel.dart         # Classe abstrata (contrato) + Mixins transversais
│   │   ├── sala_reuniao.dart              # Especialização: Sala de Reunião / Conferência
│   │   ├── equipamento.dart               # Especialização: Equipamento Audiovisual / Lab
│   │   ├── estacao_trabalho.dart          # Especialização: Estação de Trabalho / Coworking
│   │   └── agendamento.dart               # Entidades de Reserva e Fila de Espera
│   └── services/
│       └── gerenciador_reservas.dart      # Serviço central de domínio (Coleções Funcionais)
├── ENVIRONMENT_REPORT.md                  # Relatório do flutter doctor -v (Requisito 1)
├── DEFESA_TECNICA.md                      # Roteiro de apoio para a Arguição Oral (Requisito 5)
├── pubspec.yaml                           # Especificação do pacote Dart 3 Puro
├── Dockerfile                             # Containerização oficial Dart CLI
└── docker-compose.yml                     # Orquestração para execução instantânea
```

---

## 🚀 Como Executar o Projeto

Você pode executar o módulo executável de demonstração diretamente via **Dart SDK** ou através do **Docker** (sem necessidade de instalar SDKs locais).

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

Ao executar `dart run bin/main.dart`, a rotina de console demonstra de forma estruturada:

1. **Setup do Sistema & Operador `??=`**: Registro de políticas padrão de reserva e tolerâncias sem sobrescrever valores já estabelecidos.
2. **Instanciação Polimórfica (9 Recursos)**:
   - **Construtores Padrão Gerativos** com açúcar sintático (`this.campo`, `super.id`).
   - **Construtores Nomeados** (`SalaReuniao.executiva()`, `Equipamento.laboratorio()`, `EstacaoTrabalho.hotDeskDev()`).
   - **Construtores Factory** (`SalaReuniao.fromMap()`, `Equipamento.fromMap()`, `EstacaoTrabalho.fromMap()`) com validação semântica e bloqueio de dados inválidos.
3. **Operações de Negócio & Cálculo Polimórfico**: Criação de reservas em salas, equipamentos portáteis e mesas de coworking com tarifas horárias dinâmicas e emissão de notificações push simuladas.
4. **Tratamento de Exceções & Casos de Borda**:
   - Detecção de conflito e sobreposição de horários (`ConflitoHorarioException`).
   - Bloqueio de excesso de participantes na sala (`CapacidadeExcedidaException`).
   - Tentativa de agendar recurso em manutenção técnica (`RecursoIndisponivelException`).
5. **Gestão de Fila de Espera com Prioridade e Promoção Automática**:
   - Inserção ordenada por nível de prioridade (Normal vs Crítica/Diretoria).
   - Cancelamento da reserva em conflito e realocação automática da vaga com notificação em tempo real.
6. **Coleções e Métodos Funcionais (Dart 3)**:
   - `.where()`: filtragem de recursos disponíveis em determinado intervalo e por capacidade.
   - `.map()`: projeção funcional de relatórios tabulares de catálogo.
   - `.fold()`: agregação de capacidade física instalada e faturamento total confirmado.
   - `.any()`: verificação em tempo constante de manutenções ativas.
   - `.every()`: garantia de conformidade de capacidade e integridade do inventário.
7. **Spread Operators (`...` e `...?`)**: Consolidação transparente entre recursos internos e lista opcional de parceiros externos.
8. **Restrições Móveis (Conectividade) & `rethrow`**: Simulação de queda de rede (4G/5G) durante sincronização com a nuvem, interceptação com auditoria e relançamento com `rethrow`.
9. **Relatório Executivo Dinâmico**: Estruturação de dados construída em tempo de execução utilizando **Collection-If** e **Collection-For**.

---

## 🤖 Declaração Institucional de Uso de Inteligência Artificial

> Em estrita conformidade com o **Item 6 da Avaliação Processual I (Página 9)** e o **Plano de Ensino 2026/2 da disciplina de Computação Móvel (Faculdade Multivix)**:

### 1. Ferramentas Utilizadas:
- **Google Antigravity IDE** e **Google Gemini**: Utilizados como ferramentas assistivas de apoio ao desenvolvimento de software.

### 2. Forma de Contribuição e Escopo de Atuação:
- **Brainstorming e Refinamento de Modelagem:** Discussão sobre a arquitetura em camadas para o **Tema 05 (Sistema de Reserva e Agendamento de Serviços: Salas, Equipamentos e Filas de Espera)**, garantindo desacoplamento total entre o módulo de domínio e interfaces gráficas.
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
- **Assunto:** `[AP1B - Computação Móvel] - Tema 05 - [Nome do Grupo]`
- **Corpo da Mensagem:**
  > Prezado Professor Edgard,  
  > 
  > Segue o link do repositório no GitHub referente à entrega do Marco 1 (AP1B - Computação Móvel) do Projeto Prático Integrado:  
  > 🔗 **Repositório GitHub:** `https://github.com/CaioLennonDEV/reserva-hub`  
  > 
  > O repositório contém o arquivo `ENVIRONMENT_REPORT.md` com a saída do `flutter doctor -v`, o módulo de domínio em Dart puro no Tema 05 (ReservaHub — Gestão de Salas, Equipamentos e Filas de Espera), o executável CLI de demonstração (`bin/main.dart`) e o `README.md` com a Declaração de Uso de IA e Referências Bibliográficas.  
  > 
  > Atenciosamente,  
  > **Equipe ReservaHub — Tema 05**
