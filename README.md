# 🧠 NotaIA - Gerenciador Inteligente de Notas

[![Flutter](https://img.shields.io/badge/Flutter-3.x-02569B?style=for-the-badge&logo=flutter&logoColor=white)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.x-0175C2?style=for-the-badge&logo=dart&logoColor=white)](https://dart.dev)
[![Docker](https://img.shields.io/badge/Docker-Multi--stage-2496ED?style=for-the-badge&logo=docker&logoColor=white)](https://www.docker.com/)
[![Nginx](https://img.shields.io/badge/Nginx-Alpine-009639?style=for-the-badge&logo=nginx&logoColor=white)](https://nginx.org)
[![Storage](https://img.shields.io/badge/Storage-100%25%20Local%20Hive-FF9800?style=for-the-badge)](https://pub.dev/packages/hive)

> **NotaIA** é um aplicativo de anotações moderno, ágil e inteligente desenvolvido em **Flutter** com foco em privacidade (100% offline e local) e esteira de deploy conteinerizada com **Docker** e **Nginx**.

---

## 📸 Recursos Principais

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

## 📦 Estrutura DevOps

- **`Dockerfile`**: Compilação em multi-stage build. A primeira etapa usa a imagem do Flutter SDK para compilar os artefatos web otimizados (`flutter build web --release`). A segunda etapa empacota os arquivos em uma imagem leve `nginx:alpine`.
- **`nginx.conf`**: Configuração com compressão gzip, cache de arquivos estáticos, cabeçalhos de segurança e roteamento SPA (`try_files $uri $uri/ /index.html`).
- **`docker-compose.yml`**: Serviço com mapeamento de porta `8080:80`, healthcheck e reinicialização automática.
- **`.gitignore`**: Configuração abrangente ignorando arquivos de build, SDKs, chaves e dependências locais.

---

## 📄 Licença

Este projeto é de código aberto sob a licença [MIT](LICENSE).
