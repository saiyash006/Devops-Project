$ErrorActionPreference = "Stop"

Write-Host "Generating load on API and Queue..."

for ($i = 0; $i -lt 5000; $i++) {
    try {
        # Generate API traffic
        Invoke-RestMethod -Uri "http://localhost/health" -Method Get -ErrorAction SilentlyContinue | Out-Null
        
        # Generate some 500s randomly for error rate metrics (Increased from ~10% to ~40%)
        if ((Get-Random -Minimum 0 -Maximum 10) -gt 5) {
            Invoke-RestMethod -Uri "http://localhost/nonexistent" -Method Get -ErrorAction SilentlyContinue | Out-Null
        }
        
        # Enqueue jobs
        $body = @{
            patient_id = $i
            date = "2026-10-01"
            details = "Routine checkup"
        } | ConvertTo-Json
        Invoke-RestMethod -Uri "http://localhost/appointments" -Method Post -Body $body -ContentType "application/json" -ErrorAction SilentlyContinue | Out-Null

        # Call internal services via endpoints
        Invoke-RestMethod -Uri "http://localhost/call-ai" -Method Get -ErrorAction SilentlyContinue | Out-Null
    } catch {
        # Ignore errors so the load generator doesn't stop
    }
    
    Start-Sleep -Milliseconds 10
    if ($i % 100 -eq 0) { Write-Host -NoNewline "." }

}

Write-Host "`nLoad generation complete."
