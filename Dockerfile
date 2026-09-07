# ==============================================================================
# ReservaHub — Sistema de Reserva e Agendamento de Serviços (Tema 05)
# Dockerfile Multi-Stage Otimizado com Compilação AOT (Ahead-Of-Time)
# ==============================================================================

# Estágio 1: Compilação AOT nativa usando o Dart SDK completo
FROM dart:stable AS build

WORKDIR /app

# Cache de dependências
COPY pubspec.yaml ./
RUN dart pub get

# Copiar código-fonte e compilar em binário nativo de máquina
COPY . .
RUN dart pub get --offline
RUN dart compile exe bin/main.dart -o bin/reserva_hub

# Estágio 2: Imagem mínima de runtime (Reduz de ~1.2GB para ~80MB)
FROM debian:bookworm-slim

WORKDIR /app

# Copia apenas o executável AOT compilado (sem o peso do SDK)
COPY --from=build /app/bin/reserva_hub /app/bin/reserva_hub

# Executa o binário nativo diretamente
CMD ["/app/bin/reserva_hub"]
