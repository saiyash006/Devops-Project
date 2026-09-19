FROM python:3.11-slim

# Create non-root user
RUN addgroup --system app && adduser --system --group app

WORKDIR /app

# Install system dependencies (needed for psycopg2 if building from source, but binary usually works)
RUN apt-get update && apt-get install -y --no-install-recommends gcc libpq-dev && rm -rf /var/lib/apt/lists/*

COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY . .

# Set ownership
RUN chown -R app:app /app

USER app

EXPOSE 8000

HEALTHCHECK --interval=10s --timeout=5s --start-period=5s --retries=3 \
  CMD curl -f http://localhost:8000/health || exit 1

# Note: The healthcheck requires curl. Let's install it.
USER root
RUN apt-get update && apt-get install -y --no-install-recommends curl && rm -rf /var/lib/apt/lists/*
USER app

CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8000"]
