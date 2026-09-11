param()
# Kill any existing opencode server processes on port 18789
Get-Process -Name "opencode" -ErrorAction SilentlyContinue | Stop-Process -Force
Start-Sleep -Seconds 2

# Start opencode server
Start-Process "opencode" -ArgumentList "serve --port 18789" -WindowStyle Hidden
Start-Sleep -Seconds 5

# Check if it's running
try {
    $r = Invoke-RestMethod -Uri "http://127.0.0.1:18789/" -Method Get -TimeoutSec 5
    Write-Host "OpenCode server: CONNECTED" -ForegroundColor Green
} catch {
    Write-Host "Trying alternative..." -ForegroundColor Yellow
    # Try the npm version
    Start-Process "npx" -ArgumentList "opencode serve --port 18789" -WindowStyle Hidden
    Start-Sleep -Seconds 5
    try {
        $r = Invoke-RestMethod -Uri "http://127.0.0.1:18789/" -Method Get -TimeoutSec 5
        Write-Host "OpenCode server: CONNECTED via npx" -ForegroundColor Green
    } catch {
        Write-Host "Could not connect to OpenCode server" -ForegroundColor Red
    }
}

# Open browser
Start-Process "http://127.0.0.1:18789/chat?session=agent%3Amain%3Amain"
Write-Host "Browser opened to chat session" -ForegroundColor Yellow
