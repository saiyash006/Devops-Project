$ErrorActionPreference = "Stop"

Write-Host "Stopping Docker containers (data is preserved in volumes)..."
docker compose down

Write-Host "System stopped."
