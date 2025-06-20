########################
# Stage 1 — builder    #
########################
FROM python:3.11-alpine AS builder
WORKDIR /app

# 1) Системные пакеты, нужные для сборки psycopg[c] (и aiosqlite, если понадобятся C-модули)
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

# 2) Копируем файл pyproject.toml и код, чтобы pip мог построить наш пакет
COPY pyproject.toml ./
COPY src/ ./src/

# 3) Устанавливаем всю коллекцию зависимостей:
#    — runtime-зависимости (fastapi, sqlalchemy, psycopg-библиотека и т.д.)
#    — dev-зависимости (pytest, pytest-asyncio, httpx и т.п.)
#    Мы используем синтаксис "[test]" из секции [project.optional-dependencies].
RUN pip install --upgrade pip \
 && pip install --user ".[test]"

########################
# Stage 2 — runtime    #
########################
FROM python:3.11-alpine
WORKDIR /app

# 4) Runtime-зависимость для psycopg (libpq)
RUN apk add --no-cache libpq

# 5) Добавляем в PATH папку, куда установились пакеты в этапе builder
ENV PATH="/root/.local/bin:$PATH" \
    PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1

# 6) Копируем всё, что было установлено pip-ом (dependencies)
COPY --from=builder /root/.local /root/.local

# 7) Копируем «рабочий» код приложения и тесты
COPY src/ /app/src/
COPY tests/ /app/tests/

# 8) Открываем порт 8048
EXPOSE 8048

# 9) По умолчанию запускаем Uvicorn
CMD ["uvicorn", "src.main:app", "--host", "0.0.0.0", "--port", "8048"]
