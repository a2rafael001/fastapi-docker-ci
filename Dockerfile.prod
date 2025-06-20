FROM python:3.11-alpine as builder

WORKDIR /app

RUN apk add --no-cache python3-dev py3-pip gcc musl-dev

RUN python -m venv /app/venv

ENV PATH="/app/venv/bin:$PATH"
ENV PYTHONUNBUFFERED=1

COPY pyproject.toml /app

RUN pip install --no-cache-dir --upgrade pip && \
    pip install --no-cache-dir .


FROM python:3.11-alpine

WORKDIR /app

COPY --from=builder /app/venv /app/venv
COPY src /app/src

ENV PATH="/app/venv/bin:$PATH"
ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1

CMD [ "uvicorn", "src.main:app", "--reload", "--host", "0.0.0.0", "--port", "8048" ]
