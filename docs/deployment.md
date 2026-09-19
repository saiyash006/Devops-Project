# Deployment Strategy

Since this project avoids heavy orchestrators like Kubernetes, it implements a custom Blue-Green/Rolling hybrid local deploy script (`deploy.ps1`).

## How it works

1. **Build**: The script builds a new Docker image version (e.g., `api-service:v2`).
2. **Parallel Start**: It starts the new container attached to the existing networks but with a distinct name (`api-service-v2`).
3. **Health Gate**: It polls the container health status (via `docker inspect`). 
4. **Cutover (Success)**: If healthy, it uses a quick regex replace on Nginx config to point to the new container name and reloads Nginx. Then it stops/removes the old container.
5. **Rollback (Failure)**: If the new container fails the health check within the timeout, the script destroys the new container immediately, leaving the old one untouched and still serving traffic.

## Usage

```powershell
.\scripts\deploy.ps1 -Service "api-service" -Version "v2"
.\scripts\rollback.ps1 -Service "api-service" -Version "v1"
```
