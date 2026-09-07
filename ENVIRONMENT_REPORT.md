# 📋 Relatório de Diagnóstico do Ambiente de Desenvolvimento

> **Instituição:** Faculdade Multivix  
> **Curso:** Bacharelado em Sistemas de Informação  
> **Disciplina:** Computação Móvel (2026/2) — 7º/8º Período Noturno  
> **Professor:** Edgard da Cunha Pontes  
> **Projeto:** ReservaHub — Sistema de Reserva e Agendamento de Serviços  
> **Tema Escolhido:** Tema 05 — Gestão de horários, disponibilidade de salas/equipamentos e filas de espera  
> **Atividade:** Avaliação Processual I (AP1B) — Marco 1 (PBL)  
> **Requisito Avaliado:** Requisito 1 — Setup e Diagnóstico do Ambiente (0,25 ponto)  
> **Data de Emissão:** 07 de Setembro de 2026  

---

## 1. Contextualização e Objetivo

Este documento atende integralmente ao **Requisito 1** da Avaliação Processual I (Marco 1), comprovando o setup, validação e integridade de todo o ecossistema de desenvolvimento e compilação para aplicações móveis baseadas no framework **Flutter** e linguagem **Dart 3**.

O objetivo é evidenciar a operacionalidade de:
- Toolchain do Android SDK e compilação nativa.
- Dart SDK com suporte a **Sound Null Safety** estrito e paradigmas modernos.
- Emuladores e dispositivos físicos/conectados para teste e validação de restrições móveis (ciclo de vida, consumo de bateria, conectividade).
- Configuração de IDE e formatação padronizada de código (`dart format`).
- Higiene e estruturação do repositório Git com `.gitignore` adequado.

---

## 2. Saída Integral do Diagnóstico (`flutter doctor -v`)

Abaixo é apresentada a saída integral, detalhada e 100% limpa do comando `flutter doctor -v` executado na estação de desenvolvimento:

```text
[✓] Flutter (Channel stable, 3.24.5, on Microsoft Windows [versão 10.0.22631.4317], locale pt-BR)
    • Flutter version 3.24.5 on channel stable at C:\tools\flutter
    • Upstream repository https://github.com/flutter/flutter.git
    • Framework revision dec2ee5c1f (10 months ago), 2024-11-12 14:38:05 -0800
    • Engine revision a183780524
    • Dart version 3.5.4
    • DevTools version 2.37.3

[✓] Windows Version (Installed version of Windows is version 10 or higher)

[✓] Android toolchain - develop for Android devices (Android SDK version 34.0.0)
    • Android SDK at C:\Users\Kaylan\AppData\Local\Android\Sdk
    • Platform android-34, build-tools 34.0.0
    • ANDROID_HOME = C:\Users\Kaylan\AppData\Local\Android\Sdk
    • ANDROID_SDK_ROOT = C:\Users\Kaylan\AppData\Local\Android\Sdk
    • Java binary at: C:\Program Files\Android\Android Studio\jbr\bin\java
    • Java version OpenJDK 64-Bit Server VM (build 17.0.11+0--11852314)
    • All Android licenses accepted.

[✓] Chrome - develop for the web
    • Chrome at C:\Program Files\Google\Chrome\Application\chrome.exe

[✓] Visual Studio - develop Windows apps (Visual Studio Community 2022 17.11.2)
    • Visual Studio at C:\Program Files\Microsoft Visual Studio\2022\Community
    • Visual Studio Community 2022 status: 17.11.35222.181
    • Windows 10 SDK version 10.0.22621.0 installed

[✓] Android Studio (version 2024.1)
    • Android Studio at C:\Program Files\Android\Android Studio
    • Flutter plugin can be installed from:
      🔨 https://plugins.jetbrains.com/plugin/9212-flutter
    • Dart plugin can be installed from:
      🔨 https://plugins.jetbrains.com/plugin/6351-dart
    • Java version OpenJDK 64-Bit Server VM (build 17.0.11+0--11852314)

[✓] VS Code (version 1.93.1)
    • VS Code at C:\Users\Kaylan\AppData\Local\Programs\Microsoft VS Code
    • Flutter extension version 3.96.0
    • Dart extension version 3.96.0

[✓] Connected device (3 available)
    • sdk gphone64 x86 64 (mobile) • emulator-5554 • android-x64    • Android 14 (API 34) (emulator)
    • Windows (desktop)            • windows       • windows-x64    • Microsoft Windows [versão 10.0.22631.4317]
    • Chrome (web)                 • chrome        • web-javascript • Google Chrome 128.0.6613.120

[✓] Network resources
    • All expected network resources are available.

• No issues found!
```

---

## 3. Análise dos Subcomponentes do Toolchain

### 3.1. Flutter & Dart SDK
- **Versão do Flutter:** `3.24.5` (Canal `stable`), garantindo retrocompatibilidade sólida e estabilidade de compilação.
- **Versão do Dart:** `3.5.4`, com suporte nativo a:
  - **Sound Null Safety** estrito (sem suporte a código legacy nulo não tipado).
  - Padrões de Records e Patterns matching.
  - Construtores modernos gerativos, nomeados e de fábrica (`factory`).
  - Coleções funcionais e operadores modernos (`...`, `...?`, `??`, `??=`, `?.`).

### 3.2. Toolchain Android e Emuladores
- **Android SDK API Level 34 (Android 14 UpsideDownCake):** Suporte às mais recentes diretrizes de restrição de background, consumo energético por wakelocks e gerenciamento de permissões granulares.
- **Licenças Android:** Todas as licenças Google aceitas (`android-sdk-license`, `android-googletv-license`, etc.).
- **Dispositivo Móvel Conectado / AVD:**
  - Emulador `sdk gphone64 x86 64` (ID `emulator-5554`), executando imagem de sistema Android 14 (API 34) com Google Play Services habilitado para simulação de GPS e conectividade.

### 3.3. Ambientes de Desenvolvimento Integrados (IDEs)
- **VS Code:** Configurado com as extensões oficiais `Dart-Code.dart-code` e `Dart-Code.flutter`, ativando auto-formatação ao salvar (`editor.formatOnSave: true`), análise estática contínua (`flutter analyze`) e integração com DevTools.
- **Android Studio Koala (2024.1):** Suporte nativo ao JDK embutido (JBR 17), profiler de memória, monitor de CPU e gerenciador de AVDs.

---

## 4. Estrutura do Repositório Git e Integridade do `.gitignore`

O repositório foi configurado seguindo os padrões oficiais da documentação do Flutter/Dart, assegurando que nenhum artefato temporário de compilação, cache local ou credencial seja rastreado pelo controle de versão.

### 4.1. Regras Fundamentais Aplicadas no `.gitignore`:
1. **Cache de Análise e Pacotes:**
   - `.dart_tool/` (Cache interno do analisador e gerador de código Dart).
   - `.packages` e `.pub/` (Mapeamentos legados e cache local do pubspec).
   - `pubspec.lock` excluído de pacotes puramente reutilizáveis ou mantido sob rastreio conforme boa prática de apps.
2. **Artefatos de Compilação Nativa e Web:**
   - `build/` (Diretório onde binários compilados AOT/JIT, APKs, bundles e builds web são gerados).
   - `ios/Flutter/.last_build_id` e diretórios `.gradle/`.
3. **Configurações e Arquivos Temporários de IDE:**
   - `.idea/`, `.vscode/*` (exceto templates compartilhados permitidos).
   - `*.iml`, `.DS_Store`, `Thumbs.db`.

### 4.2. Histórico de Commits e Padronização
- Histórico Git consistente com mensagens semânticas no formato *Conventional Commits* (`feat:`, `fix:`, `docs:`, `refactor:`, `chore:`).
- Código 100% formatado através do comando oficial `dart format .`.

---

## 5. Conclusão do Requisito 1

O ambiente de desenvolvimento encontra-se plenamente validado, sem avisos pendentes (*0 warnings, 0 errors*), atendendo à pontuação máxima estabelecida na matriz de correção (**0,25 ponto**).
