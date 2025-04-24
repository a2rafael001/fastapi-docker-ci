# --- Stage 1: Build ---
FROM python:3.11-slim AS builder

WORKDIR /app

COPY app/requirements.txt .
RUN pip install --user -r requirements.txt

# --- Stage 2: Final ---
FROM python:3.11-slim

ENV PATH=/root/.local/bin:$PATH
WORKDIR /app

COPY --from=builder /root/.local /root/.local
COPY app/ /app/

EXPOSE 58529

CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "58529"]
