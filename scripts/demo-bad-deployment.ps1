$ErrorActionPreference = "Stop"

Write-Host "Simulating a bad deployment by breaking the healthcheck in the Dockerfile..."
$Dockerfile = Get-Content "src\api-service\Dockerfile"
$BadDockerfile = $Dockerfile -replace "CMD curl -f http://localhost:8000/health \|\| exit 1", "CMD exit 1"
$BadDockerfile | Set-Content "src\api-service\Dockerfile"

try {
    Write-Host "Attempting deployment of vBroken..."
    .\scripts\deploy.ps1 -Service "api-service" -Version "vBroken"
} catch {
    Write-Host "Deployment script caught the error and rolled back (stopped the new container)."
} finally {
    Write-Host "Restoring Dockerfile..."
    $Dockerfile | Set-Content "src\api-service\Dockerfile"
}

Write-Host "Old version should still be serving traffic."
Invoke-RestMethod -Uri "http://localhost/health" -Method Get
