Aqui está o README.md final, sem a seção do modelo de envio:
<div align="center">

# ReservaHub
### Core Engine para Gestão, Alocação e Agendamento Concorrente de Recursos
**Módulo de Domínio em Dart 3 Puro | Arquitetura Desacoplada | Fila com Prioridade**

[![Dart SDK](https://img.shields.io/badge/Dart-3.5+-0175C2.svg?style=flat-square&logo=dart&logoColor=white)](https://dart.dev)
[![Docker Support](https://img.shields.io/badge/Docker-Ready-2496ED.svg?style=flat-square&logo=docker&logoColor=white)](https://www.docker.com/)
[![Sound Null Safety](https://img.shields.io/badge/Null%20Safety-Strict%20Enforced-059669.svg?style=flat-square)](https://dart.dev/null-safety)
[![Architecture](https://img.shields.io/badge/Architecture-Clean%20Domain-black.svg?style=flat-square)]()

<br/>

*Motor corporativo de regras de negócio para alocação de salas, equipamentos e estações de trabalho, provendo validação semântica de concorrência, filas ordenadas por criticidade e resiliência a restrições de conectividade.*

</div>

---

> [!NOTE]
> **Conceito de Engenharia:**  
> O **ReservaHub** foi desenhado seguindo princípios de **Clean Architecture**, atuando exclusivamente na camada de domínio puro. Toda a lógica de regras de negócio, ciclo de vida de alocação, despacho de eventos e fallback offline funciona de forma 100% isolada e desacoplada de frameworks de UI ou dependências externas de SDKs visuais.

---

## Recursos e Capacidades Técnicas

* **Modelagem Polimórfica:** Hierarquia fundamentada na classe abstrata `RecursoAgendavel`, especializando `SalaReuniao`, `Equipamento` e `EstacaoTrabalho` com precificação e regras de uso individualizadas.
* **Composição Transversal via Mixins:** Aplicação de `LogAuditoriaMixin` para trilha de auditoria e `NotificacaoMovelMixin` para despacho simulado de push events.
* **Garantia de Null Safety Rigorosa:** Arquitetura estruturada sob Sound Null Safety do Dart 3 sem o uso forçado de operadores inseguros (`!`), priorizando coalescência (`??`), acesso condicional (`?.`) e atribuição nula tardia (`??=`).
* **Validação Semântica em Construtores:** Inicialização protegida por construtores gerativos, nomeados de conveniência e construtores `factory` com validação de payload.
* **Gestão de Filas de Espera com Promoção Automática:** Algoritmo que intercepta conflitos de horário (`ConflitoHorarioException`), insere solicitações em fila priorizada por criticidade e aloca a vaga instantaneamente mediante cancelamentos.
* **Processamento Funcional de Dados:** Uso extensivo das APIs funcionais do Dart (`.where()`, `.map()`, `.fold()`, `.any()`, `.every()`) para filtros de inventário, relatórios de faturamento e auditoria de integridade.
* **Resiliência e Tolerância a Falhas Móveis:** Interceptação simulada de indisponibilidade de rede (queda 4G/5G) com persistência de log de falha e relançamento rastreado (`rethrow`).

---

## Arquitetura de Módulos

```text
reserva-hub/
├── bin/
│   └── main.dart                     # CLI Test Runner e suíte de validação de cenários
├── lib/
│   ├── exceptions/
│   │   └── reserva_exceptions.dart   # Domínio de exceções tipadas e falhas de rede
│   ├── models/
│   │   ├── agendamento.dart          # Entidades de reserva, janelas de horário e fila
│   │   ├── equipamento.dart          # Modelagem de recursos audiovisuais e laboratório
│   │   ├── estacao_trabalho.dart     # Modelagem de postos de trabalho / coworking
│   │   ├── recurso_agendavel.dart    # Contrato base e Mixins transversais
│   │   └── sala_reuniao.dart         # Modelagem de salas executivas e auditórios
│   └── services/
│       └── gerenciador_reservas.dart # Motor central de regras e coleções funcionais
├── Dockerfile                        # Containerização para execução agnóstica
├── docker-compose.yml                # Orquestração para build instantâneo
├── DEFESA_TECNICA.md                 # Documento de aprofundamento arquitetural
├── ENVIRONMENT_REPORT.md             # Validação estática de ambiente
└── pubspec.yaml                      # Configuração do pacote Dart 3 Puro
```
Execução e Validação do CLI
Opção 1: Dart SDK Local
# Baixar dependências
dart pub get

# Executar a suíte de validação do domínio
dart run bin/main.dart

# Executar o linter estático
dart analyze

Opção 2: Container Docker
docker compose up --build

Cenários de Teste Cobertos no Console (bin/main.dart)
[EXECUÇÃO DOS CENÁRIOS DO DOMÍNIO]
```-------------------------------------------------------------------------------------------------
ETAPA 01 | Setup Global de Parâmetros       -> Políticas padrão aplicadas com operador ??=
ETAPA 02 | Instanciação Polimórfica          -> Carga de recursos via Padrão, Nomeados e Factory
ETAPA 03 | Operações de Reserva             -> Cálculo de tarifas dinâmicas por categoria
ETAPA 04 | Bloqueio de Conflito de Agenda   -> Interceptação ativa via ConflitoHorarioException
ETAPA 05 | Fila de Espera Inteligente       -> Ordenação por criticidade e auto-promoção de vaga
ETAPA 06 | Processamento Funcional de Dados -> Agregações (.fold), projeções (.map) e filtros (.where)
ETAPA 07 | Composição Dinâmica de Dados      -> Consolidação de catálogos com Spread Operators (... / ...?)
ETAPA 08 | Resiliência Offline/Conexão      -> Simulação de queda de rede com rethrow e auditoria
ETAPA 09 | Emissão de Relatório Dinâmico    -> Montagem estruturada com Collection-If e Collection-For
-------------------------------------------------------------------------------------------------```
RESULTADO: Suíte executada com 100% de conformidade com as regras de negócio.

Integrantes
| Nome | E-mail |
|---|---|
| Caio Lennon | caiolennon09@gmail.com |
| Júlia Vionette Guimarães | jujuvionette@gmail.com |
| Livia Côco Louzada | Liviacocolouzada@gmail.com |
Contexto Acadêmico
 * Instituição: Faculdade Multivix
 * Curso: Bacharelado em Sistemas de Informação
 * Disciplina: Computação Móvel (2026/2)
 * Docente: Prof. Edgard da Cunha Pontes
 * Avaliação: AP1B — Marco 1 do Projeto Prático Integrado (Tema 05: Reserva e Agendamento de Serviços)
Declaração de Uso de Inteligência Artificial
> Declaração em conformidade com o Item 6 da Avaliação Processual I e o Plano de Ensino da disciplina:
> 
 * Ferramentas: Google Antigravity IDE e Google Gemini.
 * Finalidade: Apoio consultivo no refinamento do diagrama de classes, verificação estática para prevenção do uso forçado do operador ! em conformidade com o Sound Null Safety e padronização visual da documentação técnica.
 * Autoria: O design de software, a escrita das classes de domínio, a validação de fluxos de negócio e o desenvolvimento do CLI são de autoria e domínio técnico integral dos integrantes da equipe.
Referências
 * DART DEV. Dart Programming Language Specification and Core Libraries (Dart 3.x). Disponível em: https://dart.dev/guides. Acesso em: 07 set. 2026.
 * FLUTTER DEV. Understanding Sound Null Safety in Dart. Disponível em: https://dart.dev/null-safety/understanding-null-safety. Acesso em: 07 set. 2026.
 * MARTIN, Robert C. Clean Architecture: A Craftsman's Guide to Software Structure and Design. Prentice Hall, 2017.
 * GAMMA, Erich et al. Design Patterns: Elements of Reusable Object-Oriented Software. Addison-Wesley, 1994.