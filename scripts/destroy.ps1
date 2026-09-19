$ErrorActionPreference = "Stop"

Write-Host "Stopping and removing Docker containers and volumes..."
docker compose down -v

Write-Host "Destroying Terraform infrastructure (dev environment)..."
Push-Location infra/envs/dev
terraform destroy -var-file="dev.tfvars" -auto-approve
Pop-Location

Write-Host "System destroyed completely."
