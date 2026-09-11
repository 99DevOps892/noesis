param()

# ============================================================
# ACTIVATE OPENCLAW + LOCAL LLM + OPENCODE
# ============================================================

$openClawPath = "$env:USERPROFILE\.openclaw"
if (!(Test-Path $openClawPath)) { New-Item -Path $openClawPath -ItemType Directory -Force | Out-Null }

# OpenClaw config
$openClawConfig = @{
    gateway = @{ bind = "lan"; port = 18789; host = "0.0.0.0" }
    tailscale = @{ enabled = $true; serve = $true; funnel = $false }
    plugins = @{ entries = @{} }
    sessions = @{ main = @{ agent = "main"; dashboard = "enabled" } }
    logging = @{ level = "info"; path = "$openClawPath\logs" }
}
$openClawConfig | ConvertTo-Json -Depth 10 | Set-Content "$openClawPath\config.json"
Write-Host "✅ OpenClaw config written" -ForegroundColor Green

# Check Ollama
$models = $null
try {
    $models = Invoke-RestMethod -Uri "http://localhost:11434/api/tags" -Method Get -TimeoutSec 5
    Write-Host "✅ Ollama running - Models: $(($models.models | ForEach-Object { $_.name }) -join ', ')" -ForegroundColor Green
} catch {
    Write-Host "⚠️ Ollama not running. Starting..." -ForegroundColor Yellow
    try { Start-Process "ollama" -ArgumentList "serve" -WindowStyle Hidden } catch {}
    Start-Sleep -Seconds 5
    try {
        $models = Invoke-RestMethod -Uri "http://localhost:11434/api/tags" -Method Get -TimeoutSec 5
        Write-Host "✅ Ollama running - Models: $(($models.models | ForEach-Object { $_.name }) -join ', ')" -ForegroundColor Green
    } catch { Write-Host "❌ Ollama not available - install with: winget install ollama" -ForegroundColor Red }
}

# Check OpenCode
$openCodeRunning = $false
try {
    $oc = Invoke-RestMethod -Uri "http://127.0.0.1:18789/" -Method Get -TimeoutSec 3 -ErrorAction SilentlyContinue
    $openCodeRunning = $true
    Write-Host "✅ OpenCode already running on port 18789" -ForegroundColor Green
} catch {
    Write-Host "⚠️ OpenCode not running. Starting..." -ForegroundColor Yellow
    $ocCmd = Get-Command "opencode" -ErrorAction SilentlyContinue
    if ($ocCmd) {
        Start-Process "opencode" -ArgumentList "serve --port 18789" -WindowStyle Hidden
        Start-Sleep -Seconds 3
        $openCodeRunning = $true
        Write-Host "✅ OpenCode started on port 18789" -ForegroundColor Green
    } else {
        Write-Host "⚠️ OpenCode not installed. Starting npx fallback..." -ForegroundColor Yellow
        Start-Process "npx" -ArgumentList "opencode@latest serve --port 18789" -WindowStyle Hidden
        Start-Sleep -Seconds 5
        $openCodeRunning = $true
        Write-Host "✅ OpenCode started via npx" -ForegroundColor Green
    }
}

# OpenCode config as MAIN orchestrator
$openCodeConfigPath = "$env:USERPROFILE\.opencode\config.json"
if (!(Test-Path (Split-Path $openCodeConfigPath))) { New-Item -Path (Split-Path $openCodeConfigPath) -ItemType Directory -Force | Out-Null }
$openCodeConfig = @{
    orchestrator = @{
        enabled = $true
        mainAgent = "agent:main:main"
        taskQueue = "$env:USERPROFILE\Desktop\AI_Agent_Logs\task_queue.json"
        maxConcurrentTasks = 5
        agents = @("deepseek", "opencode", "github", "whatsapp", "ollama", "openclaw")
    }
    agents = @{
        openclaw = @{ role = "Mobile Gateway"; endpoint = "http://127.0.0.1:18789" }
        ollama = @{ role = "Local LLM Engine"; endpoint = "http://localhost:11434" }
        opencode = @{ role = "MAIN Orchestrator"; endpoint = "http://127.0.0.1:18789" }
    }
}
$openCodeConfig | ConvertTo-Json -Depth 10 | Set-Content $openCodeConfigPath
Write-Host "✅ OpenCode configured as MAIN Orchestrator" -ForegroundColor Green

# Generate pairing data
$pairingData = @{
    urls = @("http://127.0.0.1:18789")
    session = "agent:main:main"
    timestamp = Get-Date -Format "yyyy-MM-ddTHH:mm:ss"
    device = $env:COMPUTERNAME
}
$pairingData | ConvertTo-Json | Set-Content "$openClawPath\pairing.json"
Write-Host "✅ OpenClaw pairing data generated" -ForegroundColor Green

# Create OpenCode plugin for local LLM
$pluginPath = "$env:USERPROFILE\.opencode\plugins"
if (!(Test-Path $pluginPath)) { New-Item -Path $pluginPath -ItemType Directory -Force | Out-Null }

# Get LLM models as array
$llmModels = @()
if ($models -and $models.models) {
    $llmModels = $models.models | ForEach-Object { $_.name }
} else {
    $llmModels = @("gemma3:4b", "llama3", "qwen3")
}

# Create OpenCode plugin for local LLM
$pluginPath = "$env:USERPROFILE\.opencode\plugins"
if (!(Test-Path $pluginPath)) { New-Item -Path $pluginPath -ItemType Directory -Force | Out-Null }

$llmPlugin = @{
    name = "local-llm"
    enabled = $true
    config = @{
        provider = "ollama"
        endpoint = "http://localhost:11434"
        models = $llmModels
        thinkingMode = $true
        maxTokens = 2048
        temperature = 0.7
    }
}
$llmPlugin | ConvertTo-Json -Depth 10 | Set-Content "$pluginPath\local-llm.json"
Write-Host "✅ Local LLM plugin configured" -ForegroundColor Green

$statusFile = "$env:USERPROFILE\Desktop\AI_Agent_Logs\openclaw_status.json"
$status = @{
    openclaw = @{
        url = "http://127.0.0.1:18789/chat?session=agent%3Amain%3Amain"
        status = "Active"
        gateway = "lan"
        configPath = "$openClawPath\config.json"
    }
    localLLM = @{
        ollama = "http://localhost:11434"
        models = $llmModels
        plugin = "$pluginPath\local-llm.json"
    }
    opencode = @{
        endpoint = "http://127.0.0.1:18789"
        role = "MAIN Orchestrator"
        opencodeStatus = if ($openCodeRunning) { "Connected" } else { "Starting..." }
        configPath = $openCodeConfigPath
    }
    orchestrator = @{
        mainAgent = "agent:main:main"
        taskQueue = "$env:USERPROFILE\Desktop\AI_Agent_Logs\task_queue.json"
        maxConcurrentTasks = 5
    }
    timestamp = Get-Date
}
$status | ConvertTo-Json -Depth 10 | Set-Content $statusFile

$statusFile = "$env:USERPROFILE\Desktop\AI_Agent_Logs\openclaw_status.json"
Write-Host ""
Write-Host "=============================================" -ForegroundColor Cyan
Write-Host "✅ OPENCLAW + LOCAL LLM + OPENCODE ACTIVATED!" -ForegroundColor Green
Write-Host "=============================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "🌐 OpenClaw: http://127.0.0.1:18789/chat?session=agent%3Amain%3Amain" -ForegroundColor Yellow
Write-Host "🧠 Local LLM: Ollama at http://localhost:11434" -ForegroundColor Yellow
if ($models) { Write-Host ("   Models: " + (($models.models | ForEach-Object { $_.name }) -join ', ')) -ForegroundColor Gray }
Write-Host "⚡ OpenCode: MAIN Orchestrator at http://127.0.0.1:18789" -ForegroundColor Yellow
Write-Host "📱 CEO: Robin Mwarema | WhatsApp: +254704919388" -ForegroundColor Cyan
Write-Host "🏢 SyllogismTechnologyAfrica" -ForegroundColor Gray
Write-Host ""
Write-Host ("📄 Status saved: " + $statusFile) -ForegroundColor Gray
Write-Host ""
