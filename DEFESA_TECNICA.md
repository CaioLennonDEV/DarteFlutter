# 🎓 Guia de Preparação para a Arguição Técnica Oral (Requisito 5 — 1,00 Ponto)

> **Disciplina:** Computação Móvel (2026/2) — Faculdade Multivix  
> **Professor:** Edgard da Cunha Pontes  
> **Projeto:** ReservaHub — Sistema de Reserva e Agendamento de Serviços (Tema 05)  
> **Vertical:** Gestão de horários, disponibilidade de salas/equipamentos e filas de espera  

Este documento reúne os principais conceitos teóricos e práticos exigidos na **Arguição Técnica Oral**, permitindo que os integrantes do grupo defendam com segurança e profundidade as escolhas arquiteturais implementadas no código-fonte.

---

## 📌 Tópico 1: Compilação JIT vs. AOT na Computação Móvel

### Qual a diferença fundamental entre JIT e AOT no Dart?
- **JIT (*Just-In-Time*):**
  - O código-fonte é compilado dinamicamente para código de máquina durante a execução do programa na máquina virtual (Dart VM).
  - **Uso:** Utilizado exclusivamente em tempo de **desenvolvimento**.
  - **Vantagens:** Permite funcionalidades ágeis como **Stateful Hot Reload** e **Hot Restart**, onde alterações no código são injetadas em milissegundos sem reiniciar o aplicativo ou perder o estado da aplicação.
- **AOT (*Ahead-Of-Time*):**
  - O código Dart é pré-compilado diretamente para código de máquina binário nativo (ARM64 para dispositivos móveis iOS/Android ou x86_64 para Desktop) antes de ser empacotado.
  - **Uso:** Utilizado nas compilações de **produção / release**.
  - **Vantagens na Computação Móvel:**
    - **Inicialização ultrarrápida (*Fast Startup Time*):** Não há overhead de compilação ou aquecimento de máquina virtual no momento da abertura do app.
    - **Menor consumo de bateria e CPU:** O processador móvel não gasta ciclos compilando código.
    - **Otimização de memória:** Permite *tree shaking* agressivo, removendo métodos e classes não utilizados do binário final.

---

## 📌 Tópico 2: Sound Null Safety no Dart 3

### O que significa "Sound" (Sólido/Estrito) Null Safety?
- No Dart 3, o sistema de tipos é **100% Sound**. Isso significa que se uma variável tem o tipo `String`, o compilador e a runtime garantem categoricamente que ela **nunca** conterá `null`.
- Não existe compatibilidade retroativa com bibliotecas sem null safety no Dart 3.

### Por que o operador de exclamação (`!`) deve ser evitado?
- O operador `!` (*null assertion*) força uma desreferenciação em tempo de execução, dizendo ao compilador: *"Confie em mim, isto não é nulo"*.
- Se a variável estiver nula, uma exceção em tempo de execução (`Null check operator used on a null value`) é lançada, causando o travamento (*crash*) do app.
- **Boas práticas aplicadas no ReservaHub:**
  - Uso de checagens lógicas prévias (`if (variavel != null)`).
  - Operador coalescente de nulo (`??`) para fornecer valor padrão de fallback.
  - Operador de acesso seguro (`?.`).
  - Atribuição nula condicional (`??=`).
  - Spread operator com verificação nula (`...?`).

---

## 📌 Tópico 3: Polimorfismo, Herança e Mixins em Dart

### Como o polimorfismo é aplicado no ReservaHub?
- A classe abstrata `RecursoAgendavel` define o contrato obrigatório:
  - `bool validarCompatibilidade(Map<String, dynamic> requisitos);`
  - `double calcularCustoReserva(Duration duracao);`
  - `bool estaDisponivel(DateTime inicio, Duration duracao);`
  - `@override String toString();`
- Todas as subclasses concretas (`SalaReuniao`, `Equipamento`, `EstacaoTrabalho`) implementam esses métodos de maneiras distintas de acordo com a regra de negócio:
  - `SalaReuniao`: adiciona taxa extra para videoconferência e checa assentos adicionais.
  - `Equipamento`: calcula consumo em Watts/kWh e monitora desgaste de uso.
  - `EstacaoTrabalho`: precifica por tipo de mesa (standing desk) e monitor duplo.
- O `GerenciadorReservas` opera sobre a lista genérica `List<RecursoAgendavel>`, sem precisar saber a classe exata em tempo de compilação, permitindo que uma única chamada como `recurso.calcularCustoReserva(duracao)` ative a regra polimórfica correta.

### Por que usar Mixins (`with`) em vez de herança múltipla?
- O Dart possui herança simples (`extends`), evitando o clássico problema do diamante da herança múltipla em C++.
- Para reaproveitar comportamentos utilitários transversais entre classes de hierarquias distintas, o Dart utiliza **Mixins** (`with`):
  - `LogAuditoriaMixin`: Adiciona histórico de auditoria cronológica com timestamp ISO-8601 a qualquer entidade sem acoplar sua árvore de herança.
  - `NotificacaoMovelMixin`: Provê capacidade de push notifications móveis tanto para os recursos quanto para o gerenciador.

---

## 📌 Tópico 4: Encapsulamento ao Nível de Biblioteca no Dart

### Como funciona o encapsulamento no Dart em comparação ao Java/C#?
- O Dart **não possui** as palavras-chave `private`, `protected` ou `public`.
- O encapsulamento é definido exclusivamente ao nível de **biblioteca** (arquivo): qualquer identificador que se inicie com `_` (sublinhado) é privado para aquele arquivo.
- No ReservaHub, atributos sensíveis como `_capacidade`, `_emManutencao`, `_agendamentos`, `_historicoReservas` e `_filasEspera` são estritamente privados (`_`), garantindo que alterações de estado passem exclusivamente por **Getters e Setters customizados** com regras de validação semântica (ex.: impedindo capacidade menor ou igual a zero).

---

## 📌 Tópico 5: Restrições de Hardware e Recursos Móveis

### Quais restrições móveis o projeto ReservaHub simula e trata?
1. **Conectividade Intermitente e Instabilidade de Rede Celular:**
   - Em aplicações móveis, o usuário transita frequentemente por áreas de sombra ou sem sinal (garagens, subsolos, elevadores).
   - O projeto simula falhas de rede (`sincronizarComServidorNuvem(simularQuedaRede: true)`), lançando `FalhaSincronizacaoMovelException`.
2. **Resiliência com `try-on-catch-finally` e `rethrow`:**
   - O serviço central intercepta a falha de conectividade, armazena no log de auditoria para persistência local (estratégia Offline-First), libera recursos no bloco `finally` e dispara **`rethrow`** para que a camada cliente saiba exibir feedback visual amigável ao usuário.
3. **Gestão Inteligente de Filas de Espera:**
   - Evita requisições repetitivas de polling que drenariam a bateria do smartphone, utilizando um sistema de fila reativa com promoção automática assim que uma vaga é liberada.
