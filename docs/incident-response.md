# Incident Response

## Scenario: Worker Service Crash

1. **Failure**: The worker service crashes due to an unhandled exception (simulated by `WORKER_CRASH=true`).
2. **Detection**: Alertmanager fires a `WorkerRestarts` and/or `HighQueueDepth` alert based on Prometheus metrics. Grafana shows a spike in restarts and an increasing Queue Depth.
3. **Investigation**: On-call engineer views the Grafana dashboard. They switch to the Loki log panel and see a Python traceback: "Intentional crash triggered...".
4. **Root Cause**: A rogue environmental variable or bad data triggered a sys.exit(1).
5. **Recovery**: Docker's `restart: unless-stopped` policy automatically restarts the worker. Since it's a transient mock failure, it recovers. (If it was a code bug, the engineer runs `deploy.ps1 worker vFix` to rollback/forward).
6. **Verification**: Grafana queue depth drops back to near zero.
7. **Prevention**: Implement a Dead Letter Queue (DLQ) in RQ so toxic jobs don't repeatedly crash the worker, and add better exception handling in the code.
