param()
Start-Sleep -Seconds 2
try {
    $r = Invoke-RestMethod -Uri "http://127.0.0.1:18789/" -Method Get -TimeoutSec 5
    Write-Host "OpenCode server: CONNECTED" -ForegroundColor Green
    Write-Host "Browser should already be open at:" -ForegroundColor Yellow
    Write-Host "http://127.0.0.1:18789/chat?session=agent%3Amain%3Amain" -ForegroundColor Yellow
} catch {
    Write-Host "OpenCode not ready yet, retrying..." -ForegroundColor Yellow
    try {
        $r = Invoke-RestMethod -Uri "http://127.0.0.1:18789/health" -Method Get -TimeoutSec 5
        Write-Host "Health check: CONNECTED" -ForegroundColor Green
    } catch {
        Write-Host "Server not responding on port 18789" -ForegroundColor Red
        Write-Host "Attempting to start via npx..." -ForegroundColor Yellow
        Start-Process "npx" -ArgumentList "opencode@latest serve --port 18789" -WindowStyle Hidden
        Start-Sleep -Seconds 5
        try {
            $r = Invoke-RestMethod -Uri "http://127.0.0.1:18789/" -Method Get -TimeoutSec 5
            Write-Host "OpenCode server: CONNECTED via npx" -ForegroundColor Green
        } catch {
            Write-Host "Could not start OpenCode server" -ForegroundColor Red
        }
    }
}
