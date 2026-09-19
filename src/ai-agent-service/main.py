import os
import time
import asyncio
import logging
from fastapi import FastAPI
from fastapi.responses import Response
from prometheus_client import Counter, Histogram, generate_latest, CONTENT_TYPE_LATEST

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

# Prometheus metrics
AI_CALL_COUNT = Counter('ai_agent_call_count', 'AI agent call count')
AI_CALL_LATENCY = Histogram('ai_agent_call_latency_seconds', 'AI call latency')

app = FastAPI(title="AI Agent Service")

# Read secret to demonstrate secret handling
api_key = os.getenv("AI_PROVIDER_API_KEY")
if api_key:
    logger.info("Successfully loaded AI provider API key.")
else:
    logger.warning("AI provider API key not found.")

@app.middleware("http")
async def add_prometheus_metrics(request, call_next):
    start_time = time.time()
    response = await call_next(request)
    process_time = time.time() - start_time
    
    endpoint = request.url.path
    if endpoint not in ["/metrics", "/health"]:
        AI_CALL_COUNT.inc()
        AI_CALL_LATENCY.observe(process_time)
        
    return response

@app.get("/health")
def health():
    return {"status": "ok"}

@app.get("/metrics")
def metrics():
    return Response(generate_latest(), media_type=CONTENT_TYPE_LATEST)

@app.post("/predict")
async def predict(data: dict):
    # Simulate API call latency
    latency_ms = int(os.getenv("AI_LATENCY_MS", "500"))
    await asyncio.sleep(latency_ms / 1000.0)
    return {"result": "simulated_prediction", "latency_ms": latency_ms}
