# 🤖 Master Prompt: Recriação Integral do Projeto ReservaHub (Tema 05)

Este documento contém o **Prompt Mestre de Engenharia de Software** estruturado para permitir que qualquer ferramenta de Inteligência Artificial Generativa (Claude, ChatGPT, Gemini, Antigravity, Cursor, etc.) recrie este projeto do zero com perfeição, atendendo a **100% da Matriz de Correção da Faculdade Multivix (Nota 3,0 / 3,0)**.

---

## 📋 Como Utilizar Este Prompt

1. Crie uma pasta vazia para o projeto: `mkdir reserva-hub && cd reserva-hub`.
2. Abra a pasta na sua IDE (VS Code ou Antigravity).
3. Copie integralmente o conteúdo da seção **"Prompt de Comando"** abaixo.
4. Cole na sua IA de preferência e execute.

---

## 📝 Prompt de Comando (Copie a partir daqui)

```markdown
Você é um Arquiteto de Software Especialista em Dart 3, Engenharia de Software Móvel e Professor Avaliador Acadêmico.

Sua missão é desenvolver, do absoluto zero, o Módulo Central de Domínio e Lógica de Negócios (em Dart 3 Puro, estruturado em camadas, sem acoplamento inicial com interface gráfica de UI) para a Avaliação Processual I (AP1B - Marco 1 do PBL) da disciplina de Computação Móvel (2026/2) do curso de Sistemas de Informação da Faculdade Multivix.

O projeto deve ser projetado para obter NOTA MÁXIMA (3,0 / 3,0 PONTOS) na rubrica de avaliação do Professor Edgard da Cunha Pontes.

==============================================================================
1. VERTICAL ESCOLHIDA: TEMA 05
==============================================================================
Tema 05 — Sistema de Reserva e Agendamento de Serviços: Gestão de horários, 
disponibilidade de salas/equipamentos e filas de espera.

Nome do Sistema: ReservaHub
Nome do Pacote Dart: reserva_hub

==============================================================================
2. CRITÉRIOS DE AVALIAÇÃO DA MATRIZ (NOTA 3,0 / 3,0)
==============================================================================

### Requisito 1: Setup e Diagnóstico do Ambiente (0,25 ponto)
- Criar o arquivo `ENVIRONMENT_REPORT.md` contendo a saída integral, limpa e detalhada do comando `flutter doctor -v` evidenciando o funcionamento do toolchain (Android SDK 34, Dart SDK 3.5+, VS Code/Android Studio e emulador AVD Android 14 conectado).
- Configurar o `.gitignore` oficial para projetos Dart/Flutter (ignorando `.dart_tool/`, `.packages`, `build/`, `.pub/`, `.pub-cache/`, etc.).
- Histórico Git consistente com Conventional Commits (`feat:`, `fix:`, `docs:`, `chore:`).

### Requisito 2: Modelagem Orientada a Objetos Avançada em Dart 3 (1,00 ponto)
- **Abstração e Contratos:** Criar a classe abstrata `RecursoAgendavel` definindo contratos obrigatórios de negócio (`bool validarCompatibilidade(Map<String, dynamic> requisitos)`, `double calcularCustoReserva(Duration duracao)`, `bool estaDisponivel(DateTime inicio, Duration duracao)`).
- **Hierarquia e Reuso com Herança:** Implementar 3 subclasses concretas que herdam com `extends`, inicializam atributos com `super` e sobrescrevem métodos com `@override` (incluindo `@override toString()` obrigatório):
  1. `SalaReuniao`: atributos `possuiProjetor`, `possuiVideoconferencia`, `qtdCadeirasExtras`, cálculo de custo por hora + taxa de videoconferência.
  2. `Equipamento`: atributos `categoria`, `numeroSerie`, `potenciaWatts`, `horasUsoAcumuladas`, cálculo de custo com tarifa de energia elétrica (kWh) e bloqueio preventivo para manutenção ao atingir 1500h de uso.
  3. `EstacaoTrabalho`: atributos `possuiMonitorDuplo`, `cabeamentoRedeGiga`, `tipoMesa`, precificação por standing desk e cadeira ergonômica.
- **Composição e Mixins:** Implementar pelo menos 2 mixins aplicados via palavra-chave `with`:
  - `LogAuditoriaMixin`: provê rastreabilidade com registros cronológicos no formato `[AUDITORIA RESERVA - $timestamp]: $mensagem`.
  - `NotificacaoMovelMixin`: provê simulação de push notifications móveis com timestamp.
- **Variedade Obrigatória de Construtores:** Para cada classe concreta, implementar:
  1. Construtor Padrão Gerativo com açúcar sintático (`this.atributo`, `super.id`).
  2. Construtor Nomeado (ex.: `SalaReuniao.executiva()`, `Equipamento.laboratorio()`, `EstacaoTrabalho.hotDeskDev()`).
  3. Construtor Factory (`factory Classe.fromMap(Map<String, dynamic> map)`) com validação semântica prévia e lançamento de exceção para dados inválidos (ex.: capacidade <= 0, horas de uso negativas).
- **Encapsulamento e Imutabilidade:** Atributos e coleções sensíveis privados ao nível de biblioteca (`_`), expostos exclusivamente por Getters e Setters customizados com validação. Campos fixos protegidos com `final`.

### Requisito 3: Manipulação de Coleções, Fluxo e Sound Null Safety (0,50 ponto)
- **Sound Null Safety Rigoroso:** Ausência total de operadores inseguros forçados (`!`). Uso consciente e demonstrado de tipos anuláveis (`T?`), operador de coalescência (`??`), acesso seguro (`?.`), atribuição nula condicional (`??=`) e null-aware spread (`...?`).
- **Coleções e Programação Funcional:** Manipulação de `List`, `Map` e `Set` utilizando:
  - `.where()`: filtros de disponibilidade por horário e capacidade mínima.
  - `.map()`: projeção de resumos e relatórios de catálogo.
  - `.fold()`: agregação matemática de faturamento total em reais e soma de capacidade instalada.
  - `.any()`: verificação em tempo constante de recursos em manutenção.
  - `.every()`: garantia de que 100% dos recursos atendem aos critérios de integridade.
  - Spread Operators (`...` e `...?`): mesclagem segura de recursos internos com recursos parceiros externos.
  - Collection-If e Collection-For: estruturação condicional do relatório gerencial executivo.
- **Tratamento de Exceções Customizadas:**
  - `ConflitoHorarioException`: detecção de reservas sobrepostas no mesmo espaço e horário.
  - `RecursoIndisponivelException`: quando o recurso está em manutenção técnica.
  - `CapacidadeExcedidaException`: quando o número de pessoas supera a lotação permitida.
  - `FilaEsperaCheiaException`: quando a fila de espera atinge o limite máximo de 5 solicitações.
  - `FalhaSincronizacaoMovelException`: simulação de queda de conectividade 4G/5G móvel.
  - Tratamento completo com blocos `try-on-catch-finally` e relançamento obrigatório com **`rethrow`**.
- **Gestão Inteligente de Fila de Espera com Promoção Automática:**
  - Inserção na fila com prioridades (`1 = Normal`, `2 = Alta`, `3 = Crítica/Diretoria`).
  - Ao cancelar um agendamento conflitante, o sistema remove automaticamente o primeiro da fila de espera, aloca a nova reserva e emite notificação push em tempo real (evitando polling contínuo que drenaria bateria).

### Requisito 4: CLI Test Runner / Executável de Demonstração (0,25 ponto)
- O arquivo `bin/main.dart` deve conter uma rotina automatizada em console que roda de ponta a ponta sem pausas manuais e exibe relatórios formatados em caixas ASCII demonstrando:
  1. Setup & Operador `??=`.
  2. Cadastro polimórfico de 9 recursos com os 3 tipos de construtores.
  3. Criação de reservas com cálculo polimórfico de custo e push notification.
  4. Disparo e captura das exceções de domínio (conflito de horário, capacidade excedida, manutenção).
  5. Fila de espera com ordenação por prioridade e promoção automática após cancelamento.
  6. Pipeline funcional com `.where()`, `.map()`, `.fold()`, `.any()` e `.every()`.
  7. Mesclagem dinâmica com Spread Operators (`...` e `...?`).
  8. Simulação de falha móvel (4G/5G) com `try-on-catch-finally` e captura do `rethrow`.
  9. Relatório gerencial executivo com Collection-If e Collection-For.

### Requisito 5: Arguição Oral e Entrevista Técnica (1,00 ponto)
- Criar o arquivo `DEFESA_TECNICA.md` estruturado para preparar o grupo para a arguição oral:
  - Roteiro pronto de apresentação de 5 a 7 minutos dividido para 5 integrantes.
  - Banco de perguntas e respostas fundamentadas abordando:
    1. Diferença entre JIT e AOT no Dart e impacto em Fast Startup, consumo de CPU e bateria.
    2. O que é Sound Null Safety e por que o operador `!` não deve ser usado.
    3. Polimorfismo e vantagens de Mixins sobre Herança Múltipla.
    4. Encapsulamento ao nível de biblioteca (`_`) vs modificadores Java/C#.
    5. Restrições da Computação Móvel tratadas (queda de rede, `rethrow`, Offline-First, economia de bateria contra polling contínuo).
    6. Construtores Padrão, Nomeados e Factory.
    7. Coleções funcionais (`.where`, `.map`, `.fold`, etc.).
  - Tabela de referências cruzadas indicando em qual arquivo do código cada conceito está implementado.

==============================================================================
3. ESTRUTURA DE ARQUIVOS ESPERADA
==============================================================================
reserva-hub/
├── .github/
│   └── workflows/
│       └── ci.yml                            # Pipeline GitHub Actions (pub get, analyze e run)
├── bin/
│   └── main.dart                             # CLI Test Runner automatizado (Requisito 4)
├── lib/
│   ├── exceptions/
│   │   └── reserva_exceptions.dart           # Exceções de domínio e restrições móveis
│   ├── models/
│   │   ├── agendamento.dart                  # Entidades Agendamento e SolicitacaoFilaEspera
│   │   ├── equipamento.dart                  # Especialização: Equipamento Audiovisual / Lab
│   │   ├── estacao_trabalho.dart             # Especialização: Estação de Trabalho / Coworking
│   │   ├── recurso_agendavel.dart            # Classe abstrata + Mixins transversais
│   │   └── sala_reuniao.dart                 # Especialização: Sala de Reunião / Conferência
│   └── services/
│       └── gerenciador_reservas.dart         # Serviço central com coleções funcionais
├── .gitignore                                # Padrão oficial Dart/Flutter
├── DEFESA_TECNICA.md                         # Guia de preparação para a Arguição Oral (Requisito 5)
├── Dockerfile                                # Container oficial Dart CLI
├── docker-compose.yml                        # Execução com comando único
├── ENVIRONMENT_REPORT.md                     # Diagnóstico do flutter doctor -v (Requisito 1)
├── pubspec.yaml                              # Configuração do pacote Dart 3 Puro
└── README.md                                 # Documentação com tema, rubrica, IA e modelo de entrega

==============================================================================
4. DOCUMENTAÇÃO ACADÊMICA E REQUISITOS INSTITUCIONAIS
==============================================================================
No arquivo `README.md`, garanta a inclusão de:
- Identificação do curso (Sistemas de Informação), disciplina (Computação Móvel 2026/2), professor (Edgard da Cunha Pontes) e integrantes.
- Tabela de mapeamento completa para os 3,0 pontos da matriz de correção.
- Instruções de execução local (`dart pub get` + `dart run bin/main.dart`) e via Docker (`docker compose up --build`).
- Declaração Obrigatória de Uso de Inteligência Artificial conforme o Item 6 da Avaliação Processual I (detalhando ferramentas, finalidade assistiva e autoria intelectual).
- Referências bibliográficas acadêmicas formais (Dart Dev, Clean Architecture de Robert C. Martin, Design Patterns GoF, etc.).
- Modelo de e-mail de entrega para `edgardpontes@professor.multivix.edu.br` com o assunto: `[AP1B - Computação Móvel] - Tema 05 - [Nome do Grupo]`.

Gere o código completo de cada arquivo sem placeholders ou comentários incompletos. O código deve compilar e rodar perfeitamente no Dart 3.x com zero warnings na análise estática (`dart analyze`).
```
