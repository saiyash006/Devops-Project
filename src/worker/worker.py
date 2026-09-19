import os
import sys
import time
import threading
from redis import Redis
from rq import Worker, Queue, Connection
from prometheus_client import start_http_server, Counter, Gauge

# Metrics
QUEUE_DEPTH = Gauge('worker_queue_depth', 'Current depth of the job queue')
JOBS_PROCESSED = Counter('worker_jobs_processed_total', 'Total jobs processed successfully')
JOBS_FAILED = Counter('worker_jobs_failed_total', 'Total jobs failed')
WORKER_RESTARTS = Counter('worker_restarts_total', 'Worker process restarts')

def process_appointment(data):
    # Simulate processing
    time.sleep(1)
    if os.getenv("WORKER_CRASH", "false").lower() == "true":
        print("Intentional crash triggered by WORKER_CRASH=true!")
        sys.exit(1) # Crash the worker
    return "processed"

def update_metrics(q):
    while True:
        QUEUE_DEPTH.set(len(q))
        time.sleep(5)

if __name__ == '__main__':
    # Start metrics server on port 8000
    start_http_server(8000)
    WORKER_RESTARTS.inc()

    redis_host = os.getenv("REDIS_HOST", "redis")
    redis_port = int(os.getenv("REDIS_PORT", "6379"))
    
    redis_conn = Redis(host=redis_host, port=redis_port)
    q = Queue("appointments", connection=redis_conn)
    
    # Start background thread to update queue depth
    metrics_thread = threading.Thread(target=update_metrics, args=(q,), daemon=True)
    metrics_thread.start()

    # Define exception handler to track failed jobs
    def track_failure(job, exc_type, exc_value, traceback):
        JOBS_FAILED.inc()
        return True # Continue handling

    # Simple wrapper around worker loop to track processed jobs
    # In a real app we might subclass Worker
    with Connection(redis_conn):
        worker = Worker([q], exception_handlers=[track_failure])
        # We can't easily hook into every successful job with just rq cleanly without subclassing, 
        # so for this simulation we'll just increment JOBS_PROCESSED in process_appointment or custom worker
        # Let's subclass to make it clean
        
        class MetricsWorker(Worker):
            def perform_job(self, job, queue):
                rv = super().perform_job(job, queue)
                if job.get_status() == 'finished':
                    JOBS_PROCESSED.inc()
                return rv
                
        metrics_worker = MetricsWorker([q], exception_handlers=[track_failure])
        metrics_worker.work()
