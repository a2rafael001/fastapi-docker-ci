########################
# Stage 1 – builder    #
########################
FROM python:3.11-alpine AS builder
WORKDIR /app

# Всё, что нужно, чтобы собрать psycopg[c] и т.п.
RUN apk add --no-cache \
        gcc musl-dev libpq libpq-dev \
        python3-dev postgresql-dev build-base cargo rust

# Копируем pyproject + исходники, чтобы pip видел package
COPY pyproject.toml .
COPY src ./src

# Ставим runtime + test-deps (секция [project.optional-dependencies.test])
RUN pip install --upgrade pip \
 && pip install --user ".[test]"

########################
# Stage 2 – runtime    #
########################
FROM python:3.11-alpine
WORKDIR /app

# libpq — runtime зависимость psycopg
RUN apk add --no-cache libpq

ENV PATH="/root/.local/bin:${PATH}" \
    PYTHONUNBUFFERED=1 \
    PYTHONDONTWRITEBYTECODE=1

# Перетаскиваем установленные пакеты
COPY --from=builder /root/.local /root/.local
# Код
COPY src ./src
# Тесты нужны только в CI, но они малы — копируем
COPY tests ./tests

EXPOSE 8048
CMD ["uvicorn", "src.main:app", "--host", "0.0.0.0", "--port", "8048"]
