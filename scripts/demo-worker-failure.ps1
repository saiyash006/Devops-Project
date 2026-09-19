$ErrorActionPreference = "Stop"

Write-Host "Crashing the worker by setting WORKER_CRASH=true inside the container..."
# This modifies the env of the running container in a hacky way or just restarts it with the env var
# A simpler way to demo is to use docker-compose to recreate just the worker with an override

$override = @"
version: '3.8'
services:
  worker:
    environment:
      - WORKER_CRASH=true
"@
$override | Out-File "docker-compose.override.yml"

Write-Host "Applying crash configuration..."
docker compose up -d worker

Write-Host "Worker should now crash on the next job."
Start-Sleep -Seconds 2
Write-Host "Sending a job to trigger crash..."
$body = @{ patient_id = 999; date = "2026-10-01"; details = "Crash trigger" } | ConvertTo-Json
Invoke-RestMethod -Uri "http://localhost/appointments" -Method Post -Body $body -ContentType "application/json" | Out-Null

Start-Sleep -Seconds 5
Write-Host "Check Grafana 'Worker Restarts' panel. Restart policy will recover it."
Write-Host "Removing crash configuration..."
Remove-Item "docker-compose.override.yml"
docker compose up -d worker
