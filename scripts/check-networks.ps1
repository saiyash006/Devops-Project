# ==============================================================================
# Network Isolation & Segmentation Verification
# Demonstrates which service belongs to Public vs Private networks
# ==============================================================================

Write-Host "`n=== CONTAINER NETWORK SEGMENTATION AUDIT ===" -ForegroundColor Cyan

$results = docker ps --format "{{.Names}}" | ForEach-Object {
    $name = $_
    $nets = (docker inspect $name --format "{{range `$k, `$v := .NetworkSettings.Networks}}{{`$k}} {{end}}").Trim()
    
    $group = if ($nets -match 'public-net' -and $nets -match 'private-net') {
        'DUAL-HOMED (DMZ / Gateway)'
    } elseif ($nets -match 'public-net') {
        'PUBLIC NET'
    } else {
        'PRIVATE NET (Isolated)'
    }

    [PSCustomObject]@{
        "Container / Service" = $name
        "Assigned Network(s)" = $nets
        "Security Zone"       = $group
    }
}

$results | Sort-Object "Security Zone", "Container / Service" | Format-Table -AutoSize

Write-Host "--- Network Membership by Network Name ---" -ForegroundColor Yellow
docker network inspect dev-public-net dev-private-net --format "{{.Name}}: {{range .Containers}}{{.Name}} {{end}}"
Write-Host ""
