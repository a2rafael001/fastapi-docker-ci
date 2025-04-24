# --- Stage 1: Build environment ---
FROM python:3.11-alpine AS builder

WORKDIR /app

RUN apk add --no-cache gcc musl-dev libpq-dev python3-dev

COPY requirements.txt .
RUN pip install --user -r requirements.txt

# --- Stage 2: Final image ---
FROM python:3.11-alpine

ENV PATH="/root/.local/bin:$PATH"
WORKDIR /app

COPY --from=builder /root/.local /root/.local
COPY src/ /app/src/
COPY tests/ /app/tests/

EXPOSE 58529

CMD ["uvicorn", "src.main:app", "--host", "0.0.0.0", "--port", "58529"]
