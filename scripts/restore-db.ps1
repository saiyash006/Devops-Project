param(
    [Parameter(Mandatory=$true)][string]$BackupFile
)
$ErrorActionPreference = "Stop"

Write-Host "Restoring Postgres database from $BackupFile..."
$VolumeName = "dev-postgres-data"
$BackupDir = "${PWD}/backups"

# We should ideally stop postgres first
Write-Host "Stopping postgres container..."
docker stop postgres | Out-Null

docker run --rm `
  -v ${VolumeName}:/volume-data `
  -v ${BackupDir}:/backup `
  alpine sh -c "rm -rf /volume-data/* && tar xzf /backup/$BackupFile -C /volume-data"

Write-Host "Starting postgres container..."
docker start postgres | Out-Null

Write-Host "Restore complete."
