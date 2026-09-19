# Final Evaluation Demo Runbook

Execute these exact commands in a PowerShell console from the root of the repository to demonstrate the environment to the evaluator.

## 1. Startup & Base Functionality
```powershell
# Starts terraform, docker compose, generates .env
.\scripts\start.ps1

# Wait 30s. Open browser to http://localhost/health (Should see {"status":"ok"})
# Open Grafana http://localhost:3000 (admin/admin), skip password change. View "DevSecOps Dashboard".
```

## 2. Load Generation & Traffic
```powershell
# Generates API traffic, enqueues jobs, calls AI agent
.\scripts\demo-load.ps1
# Check Grafana: See API request rate, latency, queue depth, jobs processed.
```

## 3. Resilience: Worker Failure
```powershell
# Simulates a fatal crash in the worker process
.\scripts\demo-worker-failure.ps1
# Check Grafana: See "Worker Restarts" spike to 1, then queue depth begins dropping again as it recovers.
```

## 4. Resilience: External Dependency Failure
```powershell
# Simulates external EHR API timing out
.\scripts\demo-ehr-failure.ps1
# The script will output a simulated timeout from the API.
```

## 5. Deployment Safety
```powershell
# Simulates deploying a version of the API with a broken Dockerfile healthcheck
.\scripts\demo-bad-deployment.ps1
# Notice the script refuses to cut over traffic and deletes the bad container.
# Run `Invoke-RestMethod http://localhost/health` to prove the old API is still up.
```

## 6. Security & CI Validation
```powershell
# Run the local security scanners (simulating CI)
.\scripts\security-scan.ps1
# View the GitHub Actions pipeline runs on the repo to show the required checks.
```

## 7. Teardown
```powershell
# Demonstrates clean terraform and compose teardown
.\scripts\destroy.ps1
```
