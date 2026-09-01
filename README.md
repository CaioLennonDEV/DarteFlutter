# 🧠 NotaIA & 🏠 Cici — Gerenciador Inteligente & Automação Residencial

[![Flutter](https://img.shields.io/badge/Flutter-3.x-02569B?style=for-the-badge&logo=flutter&logoColor=white)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.x-0175C2?style=for-the-badge&logo=dart&logoColor=white)](https://dart.dev)
[![Docker](https://img.shields.io/badge/Docker-Multi--stage-2496ED?style=for-the-badge&logo=docker&logoColor=white)](https://www.docker.com/)
[![Nginx](https://img.shields.io/badge/Nginx-Alpine-009639?style=for-the-badge&logo=nginx&logoColor=white)](https://nginx.org)
[![CI/CD](https://img.shields.io/badge/CI%2FCD-GitHub%20Actions-2088FF?style=for-the-badge&logo=githubactions&logoColor=white)](https://github.com)
[![Antigravity](https://img.shields.io/badge/Antigravity-Codifica%C3%A7%C3%A3o-4285F4?style=for-the-badge)](https://antigravity.google)
[![Gemini](https://img.shields.io/badge/Gemini-Consultas-8E75C2?style=for-the-badge)](https://gemini.google)

> **NotaIA** é um aplicativo de anotações moderno, ágil e inteligente desenvolvido em **Flutter** com foco em privacidade (100% offline e local) e esteira de deploy conteinerizada com **Docker** e **Nginx**.

---

## 🌿 Estrutura de Branches & Versões do Projeto

> [!IMPORTANT]
> O repositório está organizado em branches modulares para atender a diferentes entregas e escopos do projeto:
>
> - 📱 **`cici-ui`** (*Branch da Interface Completa Cici*): Contém a aplicação Flutter completa do **Cici — Automação e Monitoramento Residencial** (Tema 09 de Computação Móvel), com dashboard dark premium, controle interativo de lâmpadas, termostatos e sensores, Hub de IA com reconhecimento de voz Web (Web Speech API) e esteira de CI/CD para GitHub Pages. *(Pull Request da interface Cici pendente de merge para a main)*.
> - 💻 **`cici-cli`** (*Branch CLI em Dart Puro*): Contém a implementação dos modelos de POO avançada, mixins, tratamento de exceções customizadas e script executável via terminal (`dart run bin/main.dart`).
> - 🚀 **`main`** (*Branch Principal*): Contém o código base do gerenciador **NotaIA** com suporte a PWA offline-first, Docker multi-stage e Nginx.

### Como alternar para a branch com a interface do Cici (`cici-ui`):
```bash
# Obter e mudar para a branch com a interface completa do Cici
git checkout cici-ui

# Executar com Docker Compose
docker compose up -d --build
```

---

## 📸 Recursos Principais (NotaIA)

- 📝 **CRUD Completo de Notas**: Crie, visualize, edite e remova notas com feedback instantâneo e suporte a desfazer exclusão (*Undo*).
- 🔍 **Busca e Filtros em Tempo Real**: Filtre por palavras no título, conteúdo ou tags, e selecione por categorias inteligentes (Trabalho, Estudos, Ideias, Pessoal, Finanças, Geral).
- 🧠 **Módulo de Inteligência Artificial Local (NotaIA)**:
  - ✨ **Resumo Inteligente**: Extrai insights e pontos principais do texto.
  - 🪄 **Melhoria de Escrita**: Formata, pontua e estrutura o texto automaticamente.
  - 📋 **Extração de Checklist**: Converte anotações e frases de ação em tarefas estruturadas em Markdown.
  - 🏷️ **Sugestão de Tags**: Gera tags inteligentes para organização.
  - 💡 **Gerador de Título**: Sugere títulos contextuais com base no conteúdo.
- 💾 **Persistência 100% Local NoSQL**: Utiliza **Hive** (IndexedDB na web e NoSQL ultrarrápido em dispositivos móveis e desktop). Seus dados nunca saem do seu dispositivo.
- 🎨 **Design Moderno & Material 3**:
  - Tema Claro e Tema Escuro persistidos.
  - Paleta de cores pastel customizável para cada nota.
  - Layout adaptativo e responsivo para Celulares, Tablets e Navegadores Web (Staggered Grid / Masonry).
- 📌 **Fixação de Notas**: Fixe anotações importantes no topo com um clique.

---

## 🐳 Executando com Docker (Recomendado)

Você não precisa instalar Flutter ou Dart na sua máquina local! Basta ter o **Docker** instalado.

### 1. Subir a aplicação com Docker Compose:
```bash
docker compose up -d --build
```

### 2. Acessar a aplicação:
Abra seu navegador em: **`http://localhost:8080`**

### 3. Parar a aplicação:
```bash
docker compose down
```

---

## 🛠️ Arquitetura do Projeto (Clean Architecture / MVVM)

```
lib/
├── main.dart                          # Ponto de entrada e injeção de dependências
├── core/
│   ├── constants/                     # Cores, Strings, Tema Material 3
│   │   ├── app_colors.dart
│   │   ├── app_strings.dart
│   │   └── app_theme.dart
│   ├── services/                      # Serviços locais e IA
│   │   ├── ai_assistant_service.dart
│   │   └── local_storage_service.dart
│   └── utils/                         # Formatação de datas e responsividade
│       ├── date_formatter.dart
│       └── responsive_layout.dart
├── domain/                            # Camada de domínio (Entidades e Interfaces)
│   ├── models/
│   │   ├── note_category.dart
│   │   └── note_model.dart
│   └── repositories/
│       └── note_repository.dart
├── data/                              # Camada de dados (Implementações e Datasources)
│   ├── datasources/
│   │   └── note_local_datasource.dart
│   └── repositories/
│       └── note_repository_impl.dart
└── presentation/                      # Camada de apresentação (Telas, Widgets e Controllers)
    ├── controllers/
    │   ├── notes_controller.dart
    │   └── theme_controller.dart
    ├── views/
    │   ├── home/
    │   │   ├── home_screen.dart
    │   │   └── widgets/
    │   ├── editor/
    │   │   ├── note_editor_screen.dart
    │   │   └── widgets/
    │   └── settings/
    │       └── settings_screen.dart
    └── widgets/
        ├── custom_snackbar.dart
        └── confirmation_dialog.dart
```

---

## 🚀 Execução Local (Opcional - Requer Flutter SDK)

Caso tenha o Flutter instalado e queira rodar diretamente:

```bash
# Obter dependências
flutter pub get

# Executar na Web
flutter run -d chrome

# Executar em dispositivo ou emulador
flutter run
```

---

## 📦 Estrutura DevOps & CI/CD

- **`Dockerfile`**: Compilação em multi-stage build. A primeira etapa usa a imagem do Flutter SDK para compilar os artefatos web otimizados (`flutter build web --release`). A segunda etapa empacota os arquivos em uma imagem leve `nginx:alpine`.
- **`nginx.conf`**: Configuração com compressão gzip, cache de arquivos estáticos, cabeçalhos de segurança e roteamento SPA (`try_files $uri $uri/ /index.html`).
- **`docker-compose.yml`**: Serviço com mapeamento de porta `8080:80`, healthcheck e reinicialização automática.
- **`.github/workflows/deploy.yml`**: Esteira de **CI/CD** automatizada via GitHub Actions para compilação e deploy contínuo no GitHub Pages.
- **`.gitignore`**: Configuração abrangente ignorando arquivos de build, SDKs, chaves e dependências locais.

---

## 🤖 Uso de Inteligência Artificial no Desenvolvimento

Este projeto foi construído e é mantido com o auxílio de ferramentas de Inteligência Artificial:

- **Antigravity**: Utilizado como assistente de codificação, geração de componentes, estruturação e refatoração do código-fonte.
- **Gemini**: Utilizado para consultas técnicas, pesquisas de documentação, arquitetura e validação de soluções.

---

## 📄 Licença

Este projeto é de código aberto sob a licença [MIT](LICENSE).

