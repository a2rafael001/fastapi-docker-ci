########################
# Stage 1 – builder    #
########################
FROM python:3.11-alpine AS builder
WORKDIR /app

# Всё, что нужно, чтобы собрать psycopg[c] и т.п.
RUN apk add --no-cache \
        gcc musl-dev libpq libpq-dev \
        python3-dev postgresql-dev build-base cargo rust

COPY pyproject.toml .          # файл-манифест
# исходники нужны для «editable»-установки KubSU
COPY src ./src

RUN pip install --upgrade pip \
 && pip install --user ".[test]"

########################
# Stage 2 – runtime    #
########################
FROM python:3.11-alpine
WORKDIR /app

RUN apk add --no-cache libpq

ENV PATH="/root/.local/bin:${PATH}" \
    PYTHONUNBUFFERED=1 \
    PYTHONDONTWRITEBYTECODE=1

COPY --from=builder /root/.local /root/.local
COPY src ./src
COPY tests ./tests     # тесты малы – можно оставить

EXPOSE 8048
CMD ["uvicorn", "src.main:app", "--host", "0.0.0.0", "--port", "8048"]
