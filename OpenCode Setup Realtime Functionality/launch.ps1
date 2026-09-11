param()
$ErrorActionPreference = "Continue"

Write-Host "Starting Ollama..." -ForegroundColor Yellow
try { Start-Process "ollama" -ArgumentList "serve" -WindowStyle Hidden } catch {}
Start-Sleep -Seconds 5
try {
    $models = Invoke-RestMethod -Uri "http://localhost:11434/api/tags" -Method Get -TimeoutSec 5
    Write-Host ("Ollama running - Models: " + ($models.models | ForEach-Object { $_.name }) -join ", ") -ForegroundColor Green
} catch { Write-Host "Ollama not available" -ForegroundColor Red }

Write-Host "Starting OpenCode on port 18789..." -ForegroundColor Yellow
try { Start-Process "opencode" -ArgumentList "serve --port 18789" -WindowStyle Hidden } catch {
    try { Start-Process "npx" -ArgumentList "opencode@latest serve --port 18789" -WindowStyle Hidden } catch {}
}
Start-Sleep -Seconds 5

$statusDir = "$env:USERPROFILE\Desktop\AI_Agent_Logs"
if (!(Test-Path $statusDir)) { New-Item -Path $statusDir -ItemType Directory -Force | Out-Null }
$pairingData = @{
    urls = @("http://127.0.0.1:18789")
    session = "agent:main:main"
    timestamp = (Get-Date).ToString("yyyy-MM-ddTHH:mm:ss")
    device = $env:COMPUTERNAME
}
$pairingData | ConvertTo-Json | Set-Content "$statusDir\openclaw_status.json"

Start-Process "http://127.0.0.1:18789/chat?session=agent%3Amain%3Amain"

Write-Host ""
Write-Host "OPENCLAW + OLLAMA + OPENCODE ACTIVATED" -ForegroundColor Green
Write-Host "URL: http://127.0.0.1:18789/chat?session=agent%3Amain%3Amain" -ForegroundColor Yellow
