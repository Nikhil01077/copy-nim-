# ──────────────────────────────────────────────────────────────────────────────
# Stage 1: Build React frontend
# ──────────────────────────────────────────────────────────────────────────────
FROM node:20-slim AS frontend-builder

WORKDIR /frontend
COPY package.json package-lock.json ./
RUN npm ci --ignore-scripts

COPY . .
# When built for production the frontend targets the Render backend directly.
ARG VITE_API_URL=https://medquantum-nin-backend.onrender.com
ENV VITE_API_URL=$VITE_API_URL
RUN npm run build

# ──────────────────────────────────────────────────────────────────────────────
# Stage 2: Build Python dependencies
# ──────────────────────────────────────────────────────────────────────────────
FROM python:3.11-slim AS backend-builder

RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential gcc libffi-dev libssl-dev \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /build
COPY backend/requirements.txt .
RUN pip install --no-cache-dir --prefix=/install -r requirements.txt

# ──────────────────────────────────────────────────────────────────────────────
# Stage 3: Runtime image
# ──────────────────────────────────────────────────────────────────────────────
FROM python:3.11-slim

RUN apt-get update && apt-get install -y --no-install-recommends \
    curl libgomp1 \
    && rm -rf /var/lib/apt/lists/*

COPY --from=backend-builder /install /usr/local

RUN useradd -r -s /bin/false medquantum

WORKDIR /app
# Copy backend source
COPY backend/ .
# Copy built frontend static assets served by FastAPI StaticFiles
COPY --from=frontend-builder /frontend/dist ./dist

RUN mkdir -p /app/data/samples /app/data/temp /app/logs \
    && chown -R medquantum:medquantum /app/data /app/logs /app/dist

ENV PYTHONPATH=/app
ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1

USER medquantum
EXPOSE 8000

CMD ["sh", "-c", "uvicorn app.main:app --host 0.0.0.0 --port ${PORT:-8000} --workers 2 --proxy-headers"]
