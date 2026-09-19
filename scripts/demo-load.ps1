$ErrorActionPreference = "Stop"

Write-Host "Generating load on API and Queue..."

for ($i = 0; $i -lt 50; $i++) {
    # Generate API traffic
    Invoke-RestMethod -Uri "http://localhost/health" -Method Get | Out-Null
    
    # Generate some 500s randomly for error rate metrics
    if ((Get-Random -Minimum 0 -Maximum 10) -gt 8) {
        try {
            Invoke-RestMethod -Uri "http://localhost/nonexistent" -Method Get | Out-Null
        } catch {}
    }
    
    # Enqueue jobs
    $body = @{
        patient_id = $i
        date = "2026-10-01"
        details = "Routine checkup"
    } | ConvertTo-Json
    Invoke-RestMethod -Uri "http://localhost/appointments" -Method Post -Body $body -ContentType "application/json" | Out-Null

    # Call internal services via endpoints
    Invoke-RestMethod -Uri "http://localhost/call-ai" -Method Get | Out-Null
    
    Start-Sleep -Milliseconds 100
    Write-Host -NoNewline "."
}

Write-Host "`nLoad generation complete."
