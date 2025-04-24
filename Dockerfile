# --- Stage 1: Build environment ---
FROM python:3.11-alpine AS builder

WORKDIR /app

# Устанавливаем нужные библиотеки для сборки psycopg[c]
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

COPY requirements.txt .
RUN pip install --user -r requirements.txt

# --- Stage 2: Final image ---
FROM python:3.11-alpine

ENV PATH="/root/.local/bin:$PATH"
WORKDIR /app

# Ставим runtime зависимости
RUN apk add --no-cache libpq

COPY --from=builder /root/.local /root/.local
COPY src/ /app/src/
COPY tests/ /app/tests/

EXPOSE 58529

CMD ["uvicorn", "src.main:app", "--host", "0.0.0.0", "--port", "58529"]
