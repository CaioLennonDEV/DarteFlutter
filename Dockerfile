# ==========================================
# ReservaHub — Sistema de Reserva e Agendamento de Serviços (Tema 05)
# Dockerfile para execução do módulo Dart Puro (CLI)
# ==========================================
FROM dart:stable AS runtime

WORKDIR /app

# Copiar dependências primeiro (cache de camadas Docker)
COPY pubspec.yaml ./
RUN dart pub get

# Copiar código-fonte
COPY . .

# Resolver dependências offline
RUN dart pub get --offline

# Executar o módulo CLI
CMD ["dart", "run", "bin/main.dart"]
