##############################################
# Stage 1 – builder: собираем всё, включая   #
#           deps для psycopg[c] и тесты      #
##############################################
FROM python:3.11-alpine AS builder

WORKDIR /app

# ─────── Системные зависимости для сборки ───────
RUN apk add --no-cache \
    gcc musl-dev \
    libpq libpq-dev postgresql-dev \
    python3-dev build-base cargo rust

# ─────── Копируем метаданные и код ───────
COPY pyproject.toml .        # чтобы pip понимал, что устанавливать
COPY src ./src               # нужен для «editable»-установки
# Если в каталогах tests, README и др. есть пакеты-зависимости,
# их тоже можно скопировать до pip install

# ─────── Устанавливаем зависимости ───────
# 1) обновляем pip
# 2) ставим основной пакет + extras «test»
#    → pytest, pytest-asyncio, httpx, aiosqlite и др. окажутся в слое builder
RUN pip install --upgrade pip && \
    pip install --user ".[test]"

##############################################
# Stage 2 – runtime: только то, что нужно    #
##############################################
FROM python:3.11-alpine

WORKDIR /app

# ─────── runtime-зависимости ОС ───────
RUN apk add --no-cache libpq  # нужен psycopg

# ─────── переменные окружения ───────
ENV PATH="/root/.local/bin:${PATH}" \
    PYTHONUNBUFFERED=1 \
    PYTHONDONTWRITEBYTECODE=1

# ─────── перенос установленного из builder-слоя ───────
COPY --from=builder /root/.local /root/.local

# ─────── код приложения ───────
COPY src ./src

# ─────── (необязательно) копируем tests — полезно на CI ───────
COPY tests ./tests

EXPOSE 8048

# ─────── команда по-умолчанию ───────
CMD ["uvicorn", "src.main:app", "--host", "0.0.0.0", "--port", "8048"]
