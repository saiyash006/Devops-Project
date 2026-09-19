$ErrorActionPreference = "Stop"

if (-not (Test-Path -Path ".env")) {
    Write-Host "Creating .env from .env.example..."
    Copy-Item ".env.example" -Destination ".env"
}

Write-Host "Applying Terraform infrastructure (dev environment)..."
Push-Location infra/envs/dev
terraform init
terraform apply -var-file="dev.tfvars" -auto-approve
Pop-Location

Write-Host "Starting Docker containers..."
docker compose up -d --build

Write-Host "System started successfully. Nginx is listening on http://localhost"
