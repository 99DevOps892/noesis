Write-Host ""
Write-Host "Checking port 18789..." -ForegroundColor Yellow
netstat -an | Where-Object { $_ -match ":18789" } | ForEach-Object { Write-Host $_ -ForegroundColor Green }

Write-Host ""
$procs = Get-Process | Where-Object { $_.Path -like "*openclaw*" -or $_.Path -like "*opencode*" -or $_.Path -like "*node*" }
if ($procs) {
    Write-Host "Running processes:" -ForegroundColor Yellow
    $procs | ForEach-Object { Write-Host "  $($_.ProcessName) - PID $($_.Id)" -ForegroundColor Gray }
}

Write-Host ""
try {
    $r = Invoke-RestMethod -Uri "http://127.0.0.1:18789/chat?session=agent%3Amain%3Amain" -Method Get -TimeoutSec 3
    Write-Host "SERVER RESPONDING" -ForegroundColor Green
    Write-Host $r -ForegroundColor Gray
} catch {
    Write-Host "Server not responding yet, trying health..." -ForegroundColor Yellow
    try {
        $r = Invoke-RestMethod -Uri "http://127.0.0.1:18789/health" -Method Get -TimeoutSec 3
        Write-Host "Health endpoint responding: $r" -ForegroundColor Green
    } catch {
        Write-Host "Port 18789: $(netstat -an 2>&1 | Select-String -Pattern ':18789' | Select-Object -First 3 | ForEach-Object { $_ })" -ForegroundColor Gray
    }
}

Write-Host ""
Write-Host "Opening browser..." -ForegroundColor Yellow
Start-Process "http://127.0.0.1:18789/chat?session=agent%3Amain%3Amain"
