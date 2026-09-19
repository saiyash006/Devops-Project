import os
import time
import httpx
from fastapi import FastAPI, Depends, HTTPException, BackgroundTasks
from fastapi.responses import Response
from sqlalchemy.orm import Session
from sqlalchemy import Column, Integer, String, Text
from pydantic import BaseModel
from redis import Redis
from rq import Queue
from prometheus_client import Counter, Histogram, generate_latest, CONTENT_TYPE_LATEST
from database import get_db, Base, engine

# Prometheus metrics
REQUEST_COUNT = Counter('api_request_count', 'App Request Count', ['method', 'endpoint', 'http_status'])
REQUEST_LATENCY = Histogram('api_request_latency_seconds', 'Request latency', ['endpoint'])

app = FastAPI(title="API Service")

# Initialize DB (in a real app, use alembic)
class Patient(Base):
    __tablename__ = "patients"
    id = Column(Integer, primary_key=True, index=True)
    name = Column(String, index=True)
    medical_record_number = Column(String, unique=True, index=True)

Base.metadata.create_all(bind=engine)

# Redis Queue
redis_host = os.getenv("REDIS_HOST", "redis")
redis_port = int(os.getenv("REDIS_PORT", "6379"))
redis_conn = Redis(host=redis_host, port=redis_port)
q = Queue("appointments", connection=redis_conn)

# Middleware for metrics
@app.middleware("http")
async def add_prometheus_metrics(request, call_next):
    start_time = time.time()
    response = await call_next(request)
    process_time = time.time() - start_time
    
    endpoint = request.url.path
    if endpoint not in ["/metrics", "/health", "/ready"]:
        REQUEST_COUNT.labels(request.method, endpoint, response.status_code).inc()
        REQUEST_LATENCY.labels(endpoint).observe(process_time)
        
    return response

# Pydantic models
class PatientCreate(BaseModel):
    name: str
    medical_record_number: str

class AppointmentCreate(BaseModel):
    patient_id: int
    date: str
    details: str

@app.get("/health")
def health():
    return {"status": "ok"}

@app.get("/ready")
def ready(db: Session = Depends(get_db)):
    try:
        # Check DB
        db.execute("SELECT 1")
        # Check Redis
        redis_conn.ping()
        return {"status": "ready"}
    except Exception as e:
        raise HTTPException(status_code=503, detail=str(e))

@app.get("/metrics")
def metrics():
    return Response(generate_latest(), media_type=CONTENT_TYPE_LATEST)

@app.post("/patients")
def create_patient(patient: PatientCreate, db: Session = Depends(get_db)):
    db_patient = Patient(name=patient.name, medical_record_number=patient.medical_record_number)
    db.add(db_patient)
    db.commit()
    db.refresh(db_patient)
    return db_patient

@app.get("/patients")
def get_patients(db: Session = Depends(get_db)):
    return db.query(Patient).all()

@app.post("/appointments")
def create_appointment(app: AppointmentCreate):
    # Enqueue a job
    job = q.enqueue("worker.process_appointment", app.dict())
    return {"status": "enqueued", "job_id": job.id}

@app.get("/call-ai")
async def call_ai():
    # Demonstrates calling internal service
    ai_host = os.getenv("AI_SERVICE_HOST", "ai-agent-service")
    try:
        async with httpx.AsyncClient() as client:
            response = await client.get(f"http://{ai_host}:8000/health", timeout=5.0)
            return {"ai_status": response.status_code}
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Failed to call AI agent: {e}")

@app.get("/call-ehr")
async def call_ehr():
    # Demonstrates calling EHR mock
    ehr_host = os.getenv("EHR_SERVICE_HOST", "ehr-mock")
    try:
        async with httpx.AsyncClient() as client:
            response = await client.get(f"http://{ehr_host}:8000/ehr-data", timeout=5.0)
            return {"ehr_response": response.json()}
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Failed to call EHR mock: {e}")
