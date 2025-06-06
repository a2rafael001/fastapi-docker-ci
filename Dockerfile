########################
# Stage 1 – builder    #
########################
FROM python:3.11-alpine AS builder
WORKDIR /app

# Всё, что нужно, чтобы собрать psycopg[c] и т.п

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


COPY pyproject.toml ./
COPY src/ ./src/
RUN pip install --user .[test]

# --- Stage 2: Final image ---
FROM python:3.11-alpine

ENV PATH="/root/.local/bin:$PATH"
WORKDIR /app

# Ставим runtime зависимости
RUN apk add --no-cache libpq

COPY --from=builder /root/.local /root/.local
COPY src/ /app/src/
COPY tests/ /app/tests/

EXPOSE 8048

CMD ["uvicorn", "src.main:app", "--host", "0.0.0.0", "--port", "8048"]
