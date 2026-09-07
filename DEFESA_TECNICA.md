# 🎓 Guia de Preparação para a Arguição Técnica Oral (Requisito 5 — 1,00 Ponto)

> **Disciplina:** Computação Móvel (2026/2) — Faculdade Multivix  
> **Professor:** Edgard da Cunha Pontes  
> **Projeto:** Cici — Automação Residencial Inteligente (Tema 09)  

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
- **Boa prática aplicada no Cici:**
  - Uso de checagens lógicas prévias (`if (variavel != null)`).
  - Operador coalescente de nulo (`??`) para fornecer valor padrão de fallback.
  - Operador de acesso seguro (`?.`).
  - Atribuição nula condicional (`??=`).
  - Spread operator com verificação nula (`...?`).

---

## 📌 Tópico 3: Polimorfismo, Herança e Mixins em Dart

### Como o polimorfismo é aplicado no Cici?
- A classe abstrata `DispositivoInteligente` define o contrato obrigatório:
  - `void ligar();`
  - `void desligar();`
  - `void processarCargaTrabalho(double intensidade);`
  - `@override String toString();`
- Todas as subclasses concretas (`Lampada`, `Termostato`, `Sensor`) implementam esses métodos de maneiras distintas de acordo com a regra de negócio.
- O `GerenciadorCasaInteligente` opera sobre `List<DispositivoInteligente>`, sem precisar saber a classe exata em tempo de compilação, permitindo que uma única chamada como `dispositivo.processarCargaTrabalho(2.0)` ative a regra de negócio correta de cada tipo.

### Por que usar Mixins (`with`) em vez de herança múltipla?
- O Dart possui herança simples (`extends`), evitando o clássico problema do diamante da herança múltipla em C++.
- Para reaproveitar comportamentos utilitários transversais entre classes de hierarquias distintas, o Dart utiliza **Mixins** (`with`):
  - `LogAuditoriaMixin`: Adiciona histórico de auditoria cronológica a qualquer entidade sem acoplar sua árvore de herança.
  - `MonitoramentoEnergiaMixin`: Provê medição e acumulação de consumo elétrico em kWh para lâmpadas e termostatos, enquanto sensores sem fio não necessitam dessa medição direta da rede.

---

## 📌 Tópico 4: Encapsulamento ao Nível de Biblioteca no Dart

### Como funciona o encapsulamento no Dart em comparação ao Java/C#?
- O Dart **não possui** as palavras-chave `private`, `protected` ou `public`.
- O encapsulamento é definido exclusivamente ao nível de **biblioteca** (arquivo): qualquer identificador que se inicie com `_` (sublinhado) é privado para aquele arquivo.
- No Cici, atributos sensíveis como `_nivelBateria`, `_brilho`, `_temperaturaAlvo` e a lista `_dispositivos` são estritamente privados (`_`), garantindo que alterações de estado passem exclusivamente por **Getters e Setters customizados** com regras de validação semântica.

---

## 📌 Tópico 5: Restrições de Hardware e Recursos Móveis

### Quais restrições móveis o projeto Cici simula e trata?
1. **Consumo de Bateria e Recursos Críticos:**
   - Sensores IoT e periféricos móveis operam sob restrições severas de carga.
   - Quando o nível de bateria cai abaixo de 5%, o sistema suspende o ciclo de telemetria e dispara `RecursoCriticoException`.
2. **Conectividade Intermitente:**
   - Ambientes móveis sofrem quedas constantes de sinal (Wi-Fi, Bluetooth BLE, rede celular).
   - O projeto simula a desconexão de rede (`desconectarRede()`), protegendo as operações com `FalhaConectividadeException`.
3. **Resiliência com `try-on-catch-finally` e `rethrow`:**
   - O gerenciador intercepta falhas críticas, registra no log do mixin para telemetria forense e utiliza **`rethrow`** para permitir que a camada cliente (ou futura UI) apresente o feedback adequado ao usuário.
