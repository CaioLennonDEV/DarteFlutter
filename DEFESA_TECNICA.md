# 🎓 Guia Completo para a Arguição Técnica Oral e Entrevista (Requisito 5 — 1,00 Ponto)

> **Instituição:** Faculdade Multivix  
> **Curso:** Bacharelado em Sistemas de Informação  
> **Disciplina:** Computação Móvel (2026/2) — 7º/8º Período Noturno  
> **Professor:** Edgard da Cunha Pontes  
> **Projeto:** **ReservaHub — Sistema de Reserva e Agendamento de Serviços**  
> **Tema Escolhido:** **Tema 05 — Gestão de horários, disponibilidade de salas/equipamentos e filas de espera**  
> **Pontuação Máxima:** **1,00 Ponto (Nota Excelente: 100%)**

---

## 🎯 Estratégia de Avaliação: Como Garantir Nota Máxima (1,00 Ponto)

Conforme a **Página 8 do Edital da Avaliação Processual I**, o grupo tem duas modalidades de escolha:

1. **Modalidade A: Com Apresentação Técnica (ALTAMENTE RECOMENDADA)**
   - O grupo realiza uma breve apresentação de **5 a 8 minutos**.
   - **Garante 0,5 ponto automático** na nota da arguição.
   - O professor fará apenas **2 perguntas** técnicas (cada acerto vale **0,25 ponto**).
   - *Total: 0,5 (apresentação) + 0,5 (duas perguntas) = **1,00 ponto**.*

2. **Modalidade B: Sem Apresentação Direta**
   - O grupo vai direto para o questionário do professor, respondendo a **4 perguntas técnicas** (0,25 ponto cada).

---

## 🎤 Roteiro de Apresentação de 5 a 7 Minutos (Para o Grupo)

Se o grupo optar pela **Modalidade A**, basta dividir as falas conforme o roteiro abaixo:

- **Integrante 1 (Abertura e Arquitetura - 1 min):**  
  *"Professor, nosso projeto é o ReservaHub, voltado para o Tema 05: Reserva e Agendamento de Serviços. Ele foi desenvolvido como um pacote Dart 3 Puro em camadas (`models/`, `services/`, `exceptions/`), totalmente desacoplado da interface visual, pronto para receber a camada de UI em Flutter na Unidade 3."*

- **Integrante 2 (Modelagem OO e Construtores - 1.5 min):**  
  *"Definimos o contrato de domínio através da classe abstrata `RecursoAgendavel`, especializada por `SalaReuniao`, `Equipamento` e `EstacaoTrabalho`. Implementamos os três tipos obrigatórios de construtores: Padrão Gerativo com parâmetros `super`, Construtores Nomeados para casos de uso específicos (como `.executiva()` e `.laboratorio()`) e Construtores `factory .fromMap()` com validação semântica prévia."*

- **Integrante 3 (Mixins e Encapsulamento - 1.5 min):**  
  *"Em vez de herança múltipla, utilizamos Mixins (`LogAuditoriaMixin` e `NotificacaoMovelMixin`) para desacoplar comportamentos transversais com timestamps ISO-8601. Para o encapsulamento, utilizamos o modificador `_` ao nível de biblioteca em atributos como `_capacidade`, `_emManutencao` e `_agendamentos`, expondo-os com Getters e Setters que validam regras de negócio."*

- **Integrante 4 (Sound Null Safety e Coleções Funcionais - 1.5 min):**  
  *"Nosso código é 100% Sound Null Safety, sem nenhum operador `!` forçado inseguro. Utilizamos amplamente `T?`, `??`, `?.`, `??=` e `...?`. No serviço central, manipulamos as coleções com métodos funcionais puros: `.where()` para filtros de horários, `.map()` para projeção de relatórios, `.fold()` para calcular faturamento acumulado e `.any()` / `.every()` para checagens globais."*

- **Integrante 5 (Restrições Móveis, Exceções e Conclusão - 1.5 min):**  
  *"Tratamos restrições reais da computação móvel: simulação de perda de rede 4G/5G com `try-on-catch-finally` e `rethrow`, estratégia Offline-First, além de uma Fila de Espera inteligente que promove reservas automaticamente e evita consumo excessivo de bateria por polling contínuo. Nosso CLI Test Runner executa todos os 9 cenários de forma automatizada e com saída 100% limpa."*

---

## 📚 Banco de Perguntas e Respostas Fundamentadas (Para a Arguição)

Abaixo estão as perguntas conceituais e práticas mais prováveis de serem feitas pelo professor, com a fundamentação teórica exata e a localização no código:

---

### ❓ Pergunta 1: Qual a diferença fundamental entre JIT e AOT no Dart e como isso impacta a Computação Móvel?
**Resposta Modelo:**
> *"O Dart possui dois modos fundamentais de compilação:*  
> 1. **JIT (*Just-In-Time*):** O código é compilado dinamicamente em tempo de execução na máquina virtual (Dart VM). É utilizado exclusivamente em **tempo de desenvolvimento**, pois viabiliza recursos ágeis como o **Stateful Hot Reload** e **Hot Restart**, permitindo testar alterações de layout e lógica em milissegundos sem perder o estado da aplicação.  
> 2. **AOT (*Ahead-Of-Time*):** O código Dart é compilado diretamente para código de máquina binário nativo (ARM64 para processadores de smartphones Android/iOS) antes da instalação. É o modelo utilizado em **produção / release**.  
> **Impacto na Computação Móvel:** O binário AOT proporciona **Fast Startup Time** (o app abre instantaneamente, sem aquecimento de máquina virtual), **economiza ciclos de CPU e bateria** (o celular não gasta energia compilando em tempo de execução) e possibilita um **tree shaking agressivo**, reduzindo drasticamente o tamanho final do app na memória do dispositivo."*

---

### ❓ Pergunta 2: O que é Sound Null Safety no Dart 3 e por que o operador `!` deve ser evitado? Onde isso está no projeto?
**Resposta Modelo:**
> *"No Dart 3, o sistema de tipos é **100% Sound (Sólido/Estrito)**. Isso significa que o sistema de tipos garante categoricamente em tempo de compilação e execução que uma variável não anulável (`String`) jamais conterá `null`. Não há como uma referência nula escapar silenciosamente.  
> O operador `!` (*null assertion*) é uma instrução que força a desreferenciação em tempo de execução, dizendo ao compilador para ignorar a proteção estática. Se a variável for nula, o app sofre um crash por `Null check operator used on a null value`.  
> **No ReservaHub:** Eliminamos completamente o uso do `!`. Em substituição, utilizamos:  
> - Checagem lógica prévia com `if (variavel != null)`  
> - Operador de coalescência de nulos (`??`) para valores padrão de fallback  
> - Operador de navegação segura (`?.`)  
> - Atribuição condicional nula (`??=`) no registro de configurações padrão (`gerenciador.definirConfiguracaoPadrao`)  
> - Null-aware Spread Operator (`...?`) para mesclar catálogos de salas parceiras opcionais no arquivo [`lib/services/gerenciador_reservas.dart`](file:///c:/Users/Kaylan/OneDrive/Desktop/DarteFlutter/lib/services/gerenciador_reservas.dart)."*

---

### ❓ Pergunta 3: Onde vocês aplicaram Polimorfismo e por que usaram Mixins em vez de herança múltipla?
**Resposta Modelo:**
> *"O polimorfismo foi aplicado criando o contrato abstrato [`RecursoAgendavel`](file:///c:/Users/Kaylan/OneDrive/Desktop/DarteFlutter/lib/models/recurso_agendavel.dart), que define os métodos `validarCompatibilidade()`, `calcularCustoReserva()` e `estaDisponivel()`.  
> Cada classe concreta implementa esses métodos de acordo com sua regra de negócio:  
> - `SalaReuniao`: precifica por hora acrescida de taxa de videoconferência e valida assentos extras.  
> - `Equipamento`: calcula o consumo em Watts/kWh somado ao custo de locação e contabiliza horas de uso acumuladas.  
> - `EstacaoTrabalho`: precifica mesas ergonômicas standing desk e monitores duplos.  
> O serviço [`GerenciadorReservas`](file:///c:/Users/Kaylan/OneDrive/Desktop/DarteFlutter/lib/services/gerenciador_reservas.dart) opera polimorficamente sobre uma `List<RecursoAgendavel>`, invocando métodos sem se acoplar às classes concretas.  
> **Sobre os Mixins:** O Dart adota herança simples (`extends`) para evitar o problema do diamante (*diamond problem*). Para prover comportamentos transversais (auditoria cronológica com timestamps ISO-8601 e notificações push simuladas), utilizamos **Mixins** (`LogAuditoriaMixin` e `NotificacaoMovelMixin`) aplicados via palavra-chave **`with`**, promovendo desacoplamento de responsabilidades e alto reuso de código."*

---

### ❓ Pergunta 4: Como funciona o encapsulamento no Dart em comparação a Java ou C#? Como aplicaram no projeto?
**Resposta Modelo:**
> *"Diferente de linguagens como Java ou C#, o Dart **não possui** modificadores explícitos como `private`, `protected` ou `public`.  
> No Dart, o encapsulamento ocorre **ao nível de biblioteca (arquivo)**: qualquer identificador cujo nome comece com o caractere `_` (sublinhado) torna-se estritamente privado para aquele arquivo.  
> **No ReservaHub:** Atributos sensíveis como `_capacidade`, `_emManutencao`, `_agendamentos`, `_historicoReservas` e `_filasEspera` foram definidos com `_`. Eles são acessíveis externamente apenas por **Getters** e **Setters customizados** contendo validações semânticas (por exemplo: impedindo capacidade `<= 0`, horas de uso negativas ou modificação indevida de histórico)."*

---

### ❓ Pergunta 5: Quais restrições da Computação Móvel o projeto contempla e como o `rethrow` foi aplicado?
**Resposta Modelo:**
> *"Dispositivos móveis enfrentam restrições críticas de ambiente:  
> 1. **Conectividade Intermitente e Quedas de Rede Celular:** O usuário transita frequentemente por locais sem cobertura 4G/5G (subsolos, elevadores). No método `sincronizarComServidorNuvem()`, simulamos uma perda de conexão que dispara `FalhaSincronizacaoMovelException`.  
> 2. **Resiliência com `try-on-catch-finally` e `rethrow`:** O serviço captura a exceção de rede, registra o log de auditoria para persistência local (estratégia **Offline-First**), executa o bloco `finally` para fechar recursos de socket de rede e utiliza **`rethrow`** para relançar o erro até a camada cliente móvel, permitindo que a futura interface gráfica notifique o usuário adequadamente.  
> 3. **Gestão Eficiente de Filas de Espera vs. Drenagem de Bateria:** Se o aplicativo fizesse requisições repetidas de consulta (*polling contínuo*) para saber se uma sala liberou, gastaria a bateria do celular e consumiria dados de rede móvel. Em vez disso, implementamos uma **Fila de Espera Reativa**: o usuário entra na fila e o sistema promove e notifica automaticamente o primeiro da fila assim que um cancelamento ocorre."*

---

### ❓ Pergunta 6: Quais construtores foram implementados e como funciona o Construtor Factory?
**Resposta Modelo:**
> *"Implementamos rigorosamente os 3 tipos exigidos pelo edital:  
> 1. **Construtor Padrão Gerativo:** Utiliza açúcar sintático moderno com parâmetros super (`super.id`, `super.nome`) e `this.campo`.  
> 2. **Construtores Nomeados:** Criam configurações pré-definidas para situações específicas, como `SalaReuniao.executiva()`, `Equipamento.laboratorio()` e `EstacaoTrabalho.hotDeskDev()`.  
> 3. **Construtor de Fábrica (`factory`):** Utilizado em `SalaReuniao.fromMap()`, `Equipamento.fromMap()` e `EstacaoTrabalho.fromMap()`. O construtor factory tem a capacidade de validar os dados de entrada antes de instanciar a classe e pode disparar exceções (ex.: rejeitando capacidade menor ou igual a zero) ou alterar a instância retornada (ex.: ativando manutenção automática se as horas de uso de um equipamento ultrapassarem o limite seguro)."*

---

### ❓ Pergunta 7: Como vocês utilizaram Coleções e Métodos Funcionais no Dart 3?
**Resposta Modelo:**
> *"No arquivo [`lib/services/gerenciador_reservas.dart`](file:///c:/Users/Kaylan/OneDrive/Desktop/DarteFlutter/lib/services/gerenciador_reservas.dart), evitamos laços imperativos tradicionais (`for` indexado) em favor de pipelines funcionais declarativos:  
> - **`.where()`**: Para filtrar recursos disponíveis em determinado horário e recursos com capacidade mínima.  
> - **`.map()`**: Para projetar e formatar descrições resumidas de recursos e identificadores.  
> - **`.fold()`**: Para agregação matemática pura — acumulando o faturamento total em reais de todas as reservas ativas e somando a capacidade física total instalada de todos os espaços.  
> - **`.any()`**: Para verificar em tempo constante se há algum recurso em manutenção no catálogo.  
> - **`.every()`**: Para validar se 100% dos recursos cadastrados atendem à regra de capacidade estritamente positiva.  
> - **Collection-If e Collection-For**: Para construir dinamicamente o relatório gerencial executivo em formato Map."*

---

## 🎯 Resumo das Evidências no Código-Fonte

| Conceito Avaliado | Arquivo no Projeto | Trecho / Linha de Referência |
|---|---|---|
| **Classe Abstrata & Contrato** | [`lib/models/recurso_agendavel.dart`](file:///c:/Users/Kaylan/OneDrive/Desktop/DarteFlutter/lib/models/recurso_agendavel.dart) | `abstract class RecursoAgendavel` |
| **Mixins Transversais** | [`lib/models/recurso_agendavel.dart`](file:///c:/Users/Kaylan/OneDrive/Desktop/DarteFlutter/lib/models/recurso_agendavel.dart) | `mixin LogAuditoriaMixin`, `mixin NotificacaoMovelMixin` |
| **Herança & Especialização** | [`lib/models/sala_reuniao.dart`](file:///c:/Users/Kaylan/OneDrive/Desktop/DarteFlutter/lib/models/sala_reuniao.dart) | `class SalaReuniao extends RecursoAgendavel` |
| **Construtores (3 Tipos)** | [`lib/models/equipamento.dart`](file:///c:/Users/Kaylan/OneDrive/Desktop/DarteFlutter/lib/models/equipamento.dart) | Padrão Gerativo, `.laboratorio()` e `factory .fromMap()` |
| **Encapsulamento (`_`)** | [`lib/models/recurso_agendavel.dart`](file:///c:/Users/Kaylan/OneDrive/Desktop/DarteFlutter/lib/models/recurso_agendavel.dart) | `int _capacidade`, `set capacidade(...)` com validação |
| **Sound Null Safety** | [`lib/services/gerenciador_reservas.dart`](file:///c:/Users/Kaylan/OneDrive/Desktop/DarteFlutter/lib/services/gerenciador_reservas.dart) | Uso de `??=`, `T?`, `?.`, `??` e `...?` sem nenhum `!` |
| **Métodos Funcionais** | [`lib/services/gerenciador_reservas.dart`](file:///c:/Users/Kaylan/OneDrive/Desktop/DarteFlutter/lib/services/gerenciador_reservas.dart) | `.where()`, `.map()`, `.fold()`, `.any()`, `.every()` |
| **Spread Operators** | [`lib/services/gerenciador_reservas.dart`](file:///c:/Users/Kaylan/OneDrive/Desktop/DarteFlutter/lib/services/gerenciador_reservas.dart) | `[..._recursos, ...?parceirosExternos]` |
| **Exceções & Rethrow** | [`lib/services/gerenciador_reservas.dart`](file:///c:/Users/Kaylan/OneDrive/Desktop/DarteFlutter/lib/services/gerenciador_reservas.dart) | `try-on FalhaSincronizacaoMovelException-finally-rethrow` |
| **CLI Test Runner** | [`bin/main.dart`](file:///c:/Users/Kaylan/OneDrive/Desktop/DarteFlutter/bin/main.dart) | 9 cenários de demonstração em console |
