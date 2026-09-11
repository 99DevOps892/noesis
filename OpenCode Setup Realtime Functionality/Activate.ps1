# Activate OpenClaw, Local LLM, and OpenCode
# CEO: Robin Mwarema | WhatsApp: +254704919388

$ErrorActionPreference = "Continue"

Write-Host ""
Write-Host "=============================================" -ForegroundColor Cyan
Write-Host "ACTIVATING OPENCLAW + LOCAL LLM + OPENCODE" -ForegroundColor Green
Write-Host "=============================================" -ForegroundColor Cyan
Write-Host ""

# --- OpenClaw Config ---
$ocPath = "$env:USERPROFILE\.openclaw"
if (!(Test-Path $ocPath)) { New-Item -Path $ocPath -ItemType Directory -Force | Out-Null }

@{
    gateway = @{ bind = "lan"; port = 18789; host = "0.0.0.0" }
    tailscale = @{ enabled = $true; serve = $true }
    sessions = @{ main = @{ agent = "main"; dashboard = "enabled" } }
} | ConvertTo-Json -Depth 5 | Set-Content "$ocPath\config.json"
Write-Host "[1/4] OpenClaw config written" -ForegroundColor Gray

# --- Check Ollama / Local LLM ---
$llmModels = @()
try {
    $models = Invoke-RestMethod -Uri "http://localhost:11434/api/tags" -Method Get -TimeoutSec 5 -ErrorAction Stop
    $llmModels = $models.models | ForEach-Object { $_.name }
    Write-Host "[2/4] Local LLM connected - Models: $($llmModels -join ', ')" -ForegroundColor Green
} catch {
    Write-Host "[2/4] Ollama not running - starting..." -ForegroundColor Yellow
    try { Start-Process "ollama" -ArgumentList "serve" -WindowStyle Hidden } catch {}
    Start-Sleep -Seconds 5
    try {
        $models = Invoke-RestMethod -Uri "http://localhost:11434/api/tags" -Method Get -TimeoutSec 5
        $llmModels = $models.models | ForEach-Object { $_.name }
        Write-Host "[2/4] Local LLM connected - Models: $($llmModels -join ', ')" -ForegroundColor Green
    } catch {
        Write-Host "[2/4] Local LLM not available (install Ollama)" -ForegroundColor Red
        $llmModels = @("gemma3:4b", "llama3", "qwen3")
    }
}

# --- OpenCode as MAIN Orchestrator ---
$ocConfigPath = "$env:USERPROFILE\.opencode"
if (!(Test-Path $ocConfigPath)) { New-Item -Path $ocConfigPath -ItemType Directory -Force | Out-Null }

@{
    orchestrator = @{
        enabled = $true
        mainAgent = "agent:main:main"
        agents = @("deepseek", "opencode", "github", "whatsapp", "ollama", "openclaw")
        maxConcurrentTasks = 5
    }
    localLLM = @{
        endpoint = "http://localhost:11434"
        models = $llmModels
        thinkingMode = $true
    }
    openclaw = @{ endpoint = "http://127.0.0.1:18789" }
} | ConvertTo-Json -Depth 5 | Set-Content "$ocConfigPath\config.json"
Write-Host "[3/4] OpenCode configured as MAIN Orchestrator" -ForegroundColor Green

# --- Generate Pairing Data ---
@{
    urls = @("http://127.0.0.1:18789")
    session = "agent:main:main"
    timestamp = (Get-Date).ToString("yyyy-MM-ddTHH:mm:ss")
    device = $env:COMPUTERNAME
} | ConvertTo-Json | Set-Content "$ocPath\pairing.json"
Write-Host "[4/4] OpenClaw pairing data generated" -ForegroundColor Green

# --- Start OpenClaw if not running ---
try {
    $test = Invoke-RestMethod -Uri "http://127.0.0.1:18789/" -Method Get -TimeoutSec 2 -ErrorAction SilentlyContinue
    Write-Host "OpenClaw already running" -ForegroundColor Gray
} catch {
    Write-Host "Starting OpenClaw server..." -ForegroundColor Yellow
    try { Start-Process "opencode" -ArgumentList "serve --port 18789" -WindowStyle Hidden } catch {
        try { Start-Process "npx" -ArgumentList "opencode@latest serve --port 18789" -WindowStyle Hidden } catch {}
    }
    Start-Sleep -Seconds 3
}

# --- Output ---
Write-Host ""
Write-Host "=============================================" -ForegroundColor Cyan
Write-Host "ACTIVATION COMPLETE" -ForegroundColor Green
Write-Host "=============================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "OpenClaw: http://127.0.0.1:18789/chat?session=agent%3Amain%3Amain" -ForegroundColor Yellow
Write-Host "Local LLM: Ollama at http://localhost:11434" -ForegroundColor Yellow
if ($llmModels.Count -gt 0) { Write-Host "Models: $($llmModels -join ', ')" -ForegroundColor Gray }
Write-Host "OpenCode: MAIN Orchestrator at http://127.0.0.1:18789" -ForegroundColor Yellow
Write-Host ""
Write-Host "SyllogismTechnologyAfrica | CEO: Robin Mwarema" -ForegroundColor Cyan
Write-Host "WhatsApp: +254704919388 | GitHub: 99DevOps892" -ForegroundColor Gray
Write-Host ""
Write-Host ("Status saved: " + "$env:USERPROFILE\Desktop\AI_Agent_Logs\openclaw_status.json") -ForegroundColor Gray
Write-Host ""
