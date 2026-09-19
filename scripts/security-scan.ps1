$ErrorActionPreference = "Continue"

Write-Host "Running local security scans using Docker..."

Write-Host "`n--- Gitleaks (Secrets Scan) ---"
docker run --rm -v ${PWD}:/path zricethezav/gitleaks:latest detect --source="/path" -v

Write-Host "`n--- tfsec (Infrastructure Scan) ---"
docker run --rm -v ${PWD}:/src aquasec/tfsec /src/infra

Write-Host "`n--- Trivy (Image Scan on api-service) ---"
docker build -t api-service:scan-temp ./src/api-service
docker run --rm -v /var/run/docker.sock:/var/run/docker.sock aquasec/trivy:latest image --severity HIGH,CRITICAL api-service:scan-temp

Write-Host "`nLocal scans complete."
