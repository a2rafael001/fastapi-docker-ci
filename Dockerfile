########################
# Stage 1 — build deps #
########################
FROM python:3.11-alpine AS builder

WORKDIR /app

# Системные библиотеки (gcc, rust, libpq) нужны для сборки psycopg[c]
RUN apk add --no-cache \
    gcc \
    musl-dev \
    libpq \
    libpq-dev \
    python3-dev \
    postgresql-dev \
    build-base \
    cargo \
    rust

# Копируем файл зависимостей
COPY pyproject.toml /app/

# Устанавливаем зависимости проекта в /root/.local
RUN pip install --upgrade pip \
 && pip install --user .

##############################
# Stage 2 — минимальный образ #
##############################
FROM python:3.11-alpine

WORKDIR /app
ENV PATH="/root/.local/bin:$PATH"

# Runtime-зависимость libpq
RUN apk add --no-cache libpq

# Берём установленную python-часть из билдера
COPY --from=builder /root/.local /root/.local

# Копируем исходники приложения
COPY src/ /app/src/

# (Тесты копируем только если они нужны в runtime — можно убрать)
COPY tests/ /app/tests/

EXPOSE 8048
CMD ["uvicorn", "src.main:app", "--host", "0.0.0.0", "--port", "8048"]
