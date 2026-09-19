$ErrorActionPreference = "Stop"

Write-Host "Backing up Postgres database..."
# Assuming dev environment
$VolumeName = "dev-postgres-data"
$BackupDir = "${PWD}/backups"
New-Item -ItemType Directory -Force $BackupDir | Out-Null
$Date = Get-Date -Format "yyyyMMdd-HHmmss"
$BackupFile = "postgres-backup-$Date.tar.gz"

# Run a temporary alpine container mounting the volume and our backup dir
docker run --rm `
  -v ${VolumeName}:/volume-data `
  -v ${BackupDir}:/backup `
  alpine tar czf /backup/$BackupFile -C /volume-data .

Write-Host "Backup created at backups/$BackupFile"
