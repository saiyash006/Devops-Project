$ErrorActionPreference = "Stop"

Write-Host "Flipping EHR mock to timeout mode..."
$override = @"
version: '3.8'
services:
  ehr-mock:
    environment:
      - EHR_MODE=timeout
"@
$override | Out-File "docker-compose.override.yml"

docker compose up -d ehr-mock

Write-Host "EHR Mock is now timing out. Call API to see failure."
try {
    Invoke-RestMethod -Uri "http://localhost/call-ehr" -Method Get -TimeoutSec 15
} catch {
    Write-Host "API returned error due to EHR timeout: $_"
}

Write-Host "Restoring EHR mock to normal..."
Remove-Item "docker-compose.override.yml"
docker compose up -d ehr-mock
Write-Host "EHR mock restored."
