param(
    [Parameter(Mandatory=$true)][string]$Service,
    [Parameter(Mandatory=$true)][string]$Version
)

$ErrorActionPreference = "Stop"

if ($Service -ne "api-service") {
    Write-Host "This deployment script currently only supports api-service for blue-green cutover."
    # For other services, standard compose restart is enough for this demo
    Write-Host "For other services, use docker compose up -d --build $Service"
    exit 0
}

$Network = "dev-public-net"
$PrivateNetwork = "dev-private-net"
$NewContainerName = "$($Service)-$($Version)"
$ImageName = "$($Service):$($Version)"

Write-Host "1. Building image $ImageName..."
docker build -t $ImageName "./src/$Service"

Write-Host "2. Starting new container $NewContainerName..."
# Mount .env as it has secrets
docker run -d --name $NewContainerName `
    --network $Network `
    --env-file .env `
    $ImageName

docker network connect $PrivateNetwork $NewContainerName

Write-Host "3. Polling for health..."
$isHealthy = $false
for ($i = 0; $i -lt 10; $i++) {
    Start-Sleep -Seconds 2
    # Check health from host if exposed, or via another container. 
    # Since api-service only exposes internally, we check via curl inside the container itself or through a temp container
    $status = docker inspect -f '{{.State.Health.Status}}' $NewContainerName
    if ($status -eq "healthy") {
        $isHealthy = $true
        break
    }
    Write-Host "Waiting for container to be healthy... ($status)"
}

if (-not $isHealthy) {
    Write-Host "New version failed health check. Rolling back..."
    docker stop $NewContainerName
    docker rm $NewContainerName
    exit 1
}

Write-Host "4. Container is healthy. Repointing Nginx..."
# For the demo, we dynamically rewrite nginx.conf to point to the new container name
$NginxConf = Get-Content "config\nginx\nginx.conf"
$NginxConf = $NginxConf -replace "proxy_pass http://api-service([^\:]*):8000;", "proxy_pass http://$NewContainerName:8000;"
$NginxConf | Set-Content "config\nginx\nginx.conf"

# Reload Nginx
docker exec nginx nginx -s reload

Write-Host "5. Stopping old containers..."
$oldContainers = docker ps --format "{{.Names}}" | Select-String -Pattern "^api-service(-v.*)?$" | Where-Object { $_ -ne $NewContainerName }
foreach ($old in $oldContainers) {
    Write-Host "Stopping and removing $old..."
    docker stop $old
    docker rm $old
}

Write-Host "Deployment of $Service $Version successful."
