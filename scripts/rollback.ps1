param(
    [Parameter(Mandatory=$true)][string]$Service,
    [Parameter(Mandatory=$true)][string]$Version
)

$ErrorActionPreference = "Stop"

if ($Service -ne "api-service") {
    Write-Host "This rollback script currently only supports api-service."
    exit 0
}

$ContainerName = "$($Service)-$($Version)"
$ImageName = "$($Service):$($Version)"

Write-Host "Rolling back to $ContainerName..."

# Check if image exists
$imageExists = docker images -q $ImageName
if (-not $imageExists) {
    Write-Host "Image $ImageName not found locally. Cannot rollback."
    exit 1
}

# The logic is basically the same as deploy: start the old version, health check, cutover
# We'll just call deploy.ps1 with the old version
.\scripts\deploy.ps1 -Service $Service -Version $Version
