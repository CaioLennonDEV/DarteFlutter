# ReservaHub
> Core Engine em Dart 3 puro para gestão, alocação e agendamento concorrente de recursos corporativos.

[![Dart SDK](https://img.shields.io/badge/Dart-3.5+-0175C2.svg?style=flat-square&logo=dart&logoColor=white)](https://dart.dev)
[![Docker Support](https://img.shields.io/badge/Docker-Ready-2496ED.svg?style=flat-square&logo=docker&logoColor=white)](https://www.docker.com/)
[![Sound Null Safety](https://img.shields.io/badge/Null%20Safety-Strict%20Enforced-059669.svg?style=flat-square)](https://dart.dev/null-safety)
[![Architecture](https://img.shields.io/badge/Architecture-Clean%20Domain-181717.svg?style=flat-square)]()

---

O **ReservaHub** é um motor corporativo de regras de negócio voltado para a alocação de salas, equipamentos e postos de trabalho. Ele implementa validação semântica de concorrência, filas com desempate por criticidade e resiliência a restrições de conectividade móvel.

> **Conceito de Engenharia:**  
> Desenvolvido estritamente sob os princípios de **Clean Architecture**, operando de forma isolada na camada de domínio puro. Toda a lógica de ciclo de vida de alocação, despacho de eventos e fallback offline independe de frameworks de UI ou SDKs visuais.

---

### Recursos e Capacidades Técnicas

* **Modelagem Polimórfica:** Hierarquia fundamentada na classe abstrata `RecursoAgendavel`, especializando `SalaReuniao`, `Equipamento` e `EstacaoTrabalho` com precificação e regras de uso individualizadas.
* **Composição Transversal via Mixins:** Aplicação de `LogAuditoriaMixin` para rastreabilidade e `NotificacaoMovelMixin` para despacho simulado de push events.
* **Garantia de Sound Null Safety:** Zero uso de coerção forçada (`!`), priorizando coalescência (`??`), acesso condicional (`?.`) e atribuição tardia (`??=`).
* **Validação Semântica em Construtores:** Inicialização protegida por construtores gerativos, nomeados de conveniência e construtores `factory` com validação de payload.
* **Fila de Espera com Promoção Automática:** Interceptação de `ConflitoHorarioException`, alocação ordenada por prioridade e promoção instantânea em caso de cancelamento.
* **Processamento Funcional de Dados:** Uso de `.where()`, `.map()`, `.fold()`, `.any()` e `.every()` para filtros de inventário, projeção de custos e auditoria.
* **Resiliência a Falhas Móveis:** Tratamento de quedas de rede (4G/5G) com registro em log de contingência e relançamento rastreado (`rethrow`).

---

### Arquitetura de Pastas

```text
reserva-hub/
├── bin/
│   └── main.dart                     # CLI Test Runner e suíte de validação
├── lib/
│   ├── exceptions/
│   │   └── reserva_exceptions.dart   # Exceções tipadas de domínio e rede
│   ├── models/
│   │   ├── agendamento.dart          # Entidades de reserva, janelas e fila
│   │   ├── equipamento.dart          # Recursos audiovisuais e laboratórios
│   │   ├── estacao_trabalho.dart     # Postos de trabalho e coworking
│   │   ├── recurso_agendavel.dart    # Contrato base e Mixins transversais
│   │   └── sala_reuniao.dart         # Salas executivas e auditórios
│   └── services/
│       └── gerenciador_reservas.dart # Motor de regras e operações funcionais
├── Dockerfile                        # Containerização de execução agnóstica
├── docker-compose.yml                # Orquestração local para build
├── DEFESA_TECNICA.md                 # Documento de aprofundamento de arquitetura
├── ENVIRONMENT_REPORT.md             # Validação estática de ambiente
└── pubspec.yaml                      # Configuração do pacote Dart 3 Puro
```

---

### Execução e Validação do CLI

**Opção 1: Dart SDK Local**
```bash
# Obter dependências
dart pub get

# Executar validação do linter
dart analyze

# Executar a suíte de testes de domínio
dart run bin/main.dart
```

**Opção 2: Container Docker**
```bash
docker compose up --build
```

<details>
<summary><b>Visualizar saída esperada do console (bin/main.dart)</b></summary>

```text
-------------------------------------------------------------------------------------------------
ETAPA 01 | Setup Global de Parâmetros       -> Políticas padrão aplicadas com operador ??=
ETAPA 02 | Instanciação Polimórfica          -> Carga de recursos via Padrão, Nomeados e Factory
ETAPA 03 | Operações de Reserva             -> Cálculo de tarifas dinâmicas por categoria
ETAPA 04 | Bloqueio de Conflito de Agenda   -> Interceptação ativa via ConflitoHorarioException
ETAPA 05 | Fila de Espera Inteligente       -> Ordenação por criticidade e auto-promoção de vaga
ETAPA 06 | Processamento Funcional de Dados -> Agregações (.fold), projeções (.map) e filtros (.where)
ETAPA 07 | Composição Dinâmica de Dados      -> Consolidação de catálogos com Spread Operators (... / ...?)
ETAPA 08 | Resiliência Offline/Conexão      -> Simulação de queda de rede com rethrow e auditoria
ETAPA 09 | Emissão de Relatório Dinâmico    -> Montagem estruturada com Collection-If e Collection-For
-------------------------------------------------------------------------------------------------
RESULTADO: Suíte executada com 100% de conformidade com as regras de negócio.
```
</details>

---

### Informações do Projeto
**Equipe:**
* Caio Lennon — [caiolennon09@gmail.com](mailto:caiolennon09@gmail.com)
* Júlia Vionette Guimarães — [jujuvionette@gmail.com](mailto:jujuvionette@gmail.com)
* Livia Côco Louzada — [Liviacocolouzada@gmail.com](mailto:Liviacocolouzada@gmail.com)

---

### Declaração de Uso de IA

> Em conformidade com o Item 6 da Avaliação Processual I e o Plano de Ensino da disciplina:
* **Ferramentas:** Google Antigravity IDE e Google Gemini.
* **Finalidade:** Apoio consultivo no refinamento do diagrama de classes, verificação estática para prevenção do operador `!` em conformidade com Sound Null Safety e padronização visual da documentação técnica.
* **Autoria:** O design de software, escrita das classes de domínio, regras de negócio e o desenvolvimento do CLI são de autoria e domínio técnico integral dos integrantes da equipe.

---

### Referências

* DART DEV. **Dart Programming Language Specification and Core Libraries (Dart 3.x)**. Disponível em: <https://dart.dev/guides>. Acesso em: 07 set. 2026.
* FLUTTER DEV. **Understanding Sound Null Safety in Dart**. Disponível em: <https://dart.dev/null-safety/understanding-null-safety>. Acesso em: 07 set. 2026.
* GAMMA, Erich et al. **Design Patterns: Elements of Reusable Object-Oriented Software**. Addison-Wesley, 1994.
* MARTIN, Robert C. **Clean Architecture: A Craftsman's Guide to Software Structure and Design**. Prentice Hall, 2017.
