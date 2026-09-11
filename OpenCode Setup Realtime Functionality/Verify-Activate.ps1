# Verify OpenClaw, LLM, and OpenCode connections
$ErrorActionPreference = "Continue"

Write-Host ""
Write-Host "=============================================" -ForegroundColor Cyan
Write-Host "SYSTEM VERIFICATION" -ForegroundColor Green
Write-Host "=============================================" -ForegroundColor Cyan
Write-Host ""

# Check Ollama
try {
    $models = Invoke-RestMethod -Uri "http://localhost:11434/api/tags" -Method Get -TimeoutSec 5
    $modelNames = $models.models | ForEach-Object { $_.name }
    Write-Host "[OK] Ollama Local LLM Running" -ForegroundColor Green
    Write-Host "      Models: $($modelNames -join ', ')" -ForegroundColor Gray
} catch {
    Write-Host "[FAIL] Ollama Not Running" -ForegroundColor Red
    Write-Host "      Start with: ollama serve" -ForegroundColor Yellow
}

# Check OpenClaw on port 18789
try {
    $oc = Invoke-RestMethod -Uri "http://127.0.0.1:18789/" -Method Get -TimeoutSec 5 -ErrorAction SilentlyContinue
    Write-Host "[OK] OpenClaw Running on 127.0.0.1:18789" -ForegroundColor Green
} catch {
    Write-Host "[CHECK] OpenClaw Starting..." -ForegroundColor Yellow
    Start-Sleep -Seconds 3
    try {
        $oc = Invoke-RestMethod -Uri "http://127.0.0.1:18789/" -Method Get -TimeoutSec 5 -ErrorAction SilentlyContinue
        Write-Host "[OK] OpenClaw Running on 127.0.0.1:18789" -ForegroundColor Green
    } catch {
        Write-Host "[INFO] OpenClaw will start on next launch" -ForegroundColor Gray
    }
}

# Check OpenClaw session URL
Write-Host ""
Write-Host "=============================================" -ForegroundColor Cyan
Write-Host "CONNECTION URLs" -ForegroundColor Yellow
Write-Host "=============================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "OpenClaw: http://127.0.0.1:18789/chat?session=agent%3Amain%3Amain" -ForegroundColor Yellow
Write-Host "Local LLM: http://localhost:11434/api/generate" -ForegroundColor Yellow
Write-Host "OpenCode: http://127.0.0.1:18789 (MAIN Orchestrator)" -ForegroundColor Yellow
Write-Host ""
Write-Host "SyllogismTechnologyAfrica" -ForegroundColor Cyan
Write-Host "CEO: Robin Mwarema | WhatsApp: +254704919388" -ForegroundColor Gray
Write-Host ""
