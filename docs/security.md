# Security Documentation

## Container Security
- **Minimal Images**: All applications use `python:3.11-slim` (or `alpine` where possible).
- **Non-root Users**: Application Dockerfiles create and switch to a dedicated `app` user, avoiding root privileges.
- **Resource Limits**: Compose defines CPU/Memory limits to prevent noisy neighbor and DoS via resource exhaustion.
- **Network Isolation**: Only Nginx maps to host ports. Internal services use `private-net`.

## Secrets Management
- No secrets are hardcoded in the codebase.
- We use `.env.example` as a committed template. 
- In a real deployment, a Secrets Manager (like HashiCorp Vault or AWS Secrets Manager) would inject these at runtime, or we would use Docker Swarm/K8s native secrets mounted into the container filesystem (e.g. `/run/secrets/...`).

## CI Pipeline Checks
The GitHub Actions workflow implements:
1. **Gitleaks**: Scans commit history for accidentally committed secrets.
2. **Safety/Trivy**: Scans Python dependencies and Docker images for CVEs.
3. **tfsec**: Scans Terraform configuration for IaC misconfigurations (e.g., exposed ports, missing encryption).
