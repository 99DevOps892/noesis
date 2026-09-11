# ============================================================
# DEPLOYMENT SCRIPT - SyllogismTechnologyAfrica AI Agent Engine v4.0
# ============================================================
# CEO: Robin Mwarema | WhatsApp: +254704919388 | GitHub: 99DevOps892
# ============================================================

param(
    [string]$Mode = "production",
    [string]$GitHubToken = $env:GITHUB_TOKEN,
    [string]$WhatsAppNumber = "+254704919388",
    [switch]$Force = $false
)

# Ensure admin rights
$currentPrincipal = [Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()
$isAdmin = $currentPrincipal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)

if (-not $isAdmin) {
    Write-Warning "⚠️ Please run PowerShell as Administrator for full deployment"
}

Write-Host "🚀 Deploying AI Agent Engine v4.0..." -ForegroundColor Cyan
Write-Host "   Mode: $Mode | GitHub: $Global:STAG.GitHubUser | WhatsApp: $WhatsAppNumber" -ForegroundColor Gray

# ============================================================
# STEP 1: Install Required Modules
# ============================================================
Write-Host "`n[1/8] Installing Required Modules..." -ForegroundColor Yellow

$requiredModules = @("PSReadLine", "Microsoft.PowerShell.Utility", "Microsoft.PowerShell.Security")
foreach ($module in $requiredModules) {
    if (!(Get-Module -Name $module -ListAvailable)) {
        try {
            Install-Module -Name $module -Force -Scope CurrentUser -ErrorAction SilentlyContinue
            Write-Host "  ✅ Installed: $module" -ForegroundColor Green
        } catch {
            Write-Host "  ⚠️ Could not install: $module (may already be present)" -ForegroundColor Yellow
        }
    } else {
        Write-Host "  ✅ Already available: $module" -ForegroundColor Green
    }
}

# Install QRCode module if needed
if (!(Get-Module -Name QRCodeGenerator -ListAvailable)) {
    try {
        Install-Module -Name QRCodeGenerator -Force -Scope CurrentUser -ErrorAction SilentlyContinue
        Write-Host "  ✅ Installed: QRCodeGenerator" -ForegroundColor Green
    } catch {
        Write-Host "  ⚠️ QRCodeGenerator not available (optional)" -ForegroundColor Yellow
    }
}

# ============================================================
# STEP 2: Set Execution Policy
# ============================================================
Write-Host "`n[2/8] Setting Execution Policy..." -ForegroundColor Yellow
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser -Force
Write-Host "  ✅ Execution policy set to RemoteSigned" -ForegroundColor Green

# ============================================================
# STEP 3: Create Required Directories
# ============================================================
Write-Host "`n[3/8] Creating Directory Structure..." -ForegroundColor Yellow

$dirs = @(
    "$env:USERPROFILE\Desktop\AI_Agent_Logs",
    "$env:TEMP\DeepSeekAgent",
    "$env:USERPROFILE\.stag",
    "$env:USERPROFILE\.openclaw",
    "$env:USERPROFILE\.opencode",
    "$env:USERPROFILE\.opencode\plugins",
    "$env:USERPROFILE\Desktop"
)

foreach ($dir in $dirs) {
    if (!(Test-Path $dir)) {
        New-Item -Path $dir -ItemType Directory -Force | Out-Null
        Write-Host "  ✅ Created: $dir" -ForegroundColor Green
    } else {
        Write-Host "  ✅ Exists: $dir" -ForegroundColor Gray
    }
}

# ============================================================
# STEP 4: Install Ollama (if not present)
# ============================================================
Write-Host "`n[4/8] Checking Ollama..." -ForegroundColor Yellow

$ollamaPath = Get-Command "ollama" -ErrorAction SilentlyContinue
if (-not $ollamaPath) {
    Write-Host "  ⬇️ Downloading Ollama..." -ForegroundColor Yellow
    try {
        $ollamaUrl = "https://github.com/ollama/ollama/releases/latest/download/ollama-setup.exe"
        $ollamaInstaller = "$env:TEMP\ollama-setup.exe"
        Invoke-WebRequest -Uri $ollamaUrl -OutFile $ollamaInstaller -ErrorAction SilentlyContinue
        Start-Process -FilePath $ollamaInstaller -ArgumentList "/S" -Wait
        Write-Host "  ✅ Ollama installed" -ForegroundColor Green
    } catch {
        Write-Warning "  ⚠️ Could not auto-install Ollama. Please install manually."
    }
} else {
    Write-Host "  ✅ Ollama already installed" -ForegroundColor Green
}

# Pull required models
Write-Host "  📦 Pulling LLM models..." -ForegroundColor Yellow
$models = @("gemma3:4b", "llama3", "qwen3")
foreach ($model in $models) {
    try {
        $existing = Invoke-RestMethod -Uri "http://localhost:11434/api/show" -Method Post -Body @{ name = $model } -ContentType "application/json" -TimeoutSec 3 -ErrorAction SilentlyContinue
        if (-not $existing) {
            Write-Host "    Pulling $model..." -ForegroundColor Gray
            Start-Process "ollama" -ArgumentList "pull $model" -WindowStyle Hidden
        } else {
            Write-Host "    ✅ $model already available" -ForegroundColor Green
        }
    } catch {
        Write-Host "    ⚠️ Could not verify $model" -ForegroundColor Yellow
    }
}

# ============================================================
# STEP 5: Install OpenCode
# ============================================================
Write-Host "`n[5/8] Checking OpenCode..." -ForegroundColor Yellow

$openCodePath = Get-Command "opencode" -ErrorAction SilentlyContinue
if (-not $openCodePath) {
    Write-Host "  ⬇️ Installing OpenCode..." -ForegroundColor Yellow
    try {
        Start-Process "npx" -ArgumentList "opencode@latest" -WindowStyle Hidden
        Write-Host "  ✅ OpenCode installation initiated" -ForegroundColor Green
    } catch {
        Write-Warning "  ⚠️ Could not auto-install OpenCode. Install via: npm install -g @opencode-ai/cli"
    }
} else {
    Write-Host "  ✅ OpenCode already installed" -ForegroundColor Green
}

# ============================================================
# STEP 6: Install Tailscale (for OpenClaw mobile)
# ============================================================
Write-Host "`n[6/8] Checking Tailscale..." -ForegroundColor Yellow

$tailscalePath = Get-Command "tailscale" -ErrorAction SilentlyContinue
if (-not $tailscalePath) {
    Write-Host "  ⬇️ Downloading Tailscale..." -ForegroundColor Yellow
    try {
        $tailscaleUrl = "https://pkgs.tailscale.com/stable/windows/tailscale-setup.exe"
        $tailscaleInstaller = "$env:TEMP\tailscale-setup.exe"
        Invoke-WebRequest -Uri $tailscaleUrl -OutFile $tailscaleInstaller -ErrorAction SilentlyContinue
        Start-Process -FilePath $tailscaleInstaller -ArgumentList "/quiet" -Wait
        Write-Host "  ✅ Tailscale installed" -ForegroundColor Green
    } catch {
        Write-Warning "  ⚠️ Could not auto-install Tailscale"
    }
} else {
    Write-Host "  ✅ Tailscale already installed" -ForegroundColor Green
}

# ============================================================
# STEP 7: Configure Scheduled Task (Auto-start on boot)
# ============================================================
Write-Host "`n[7/8] Setting up Auto-Start..." -ForegroundColor Yellow

if ($isAdmin) {
    $scriptPath = "$env:USERPROFILE\Desktop\STAG\stag.psm1"
    $action = New-ScheduledTaskAction -Execute "powershell.exe" -Argument "-NoProfile -WindowStyle Hidden -ExecutionPolicy RemoteSigned -File `"$scriptPath`""
    $trigger = New-ScheduledTaskTrigger -AtStartup
    $settings = New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries -RestartCount 3 -RestartInterval (New-TimeSpan -Minutes 1)
    
    try {
        Register-ScheduledTask -TaskName "SyllogismAIAgent" -Action $action -Trigger $trigger -Settings $settings -User $env:USERNAME -RunLevel Highest -Force -ErrorAction SilentlyContinue
        Write-Host "  ✅ Auto-start scheduled task created" -ForegroundColor Green
    } catch {
        Write-Host "  ⚠️ Could not create scheduled task: $_" -ForegroundColor Yellow
    }
} else {
    Write-Host "  ⚠️ Admin rights needed for scheduled task" -ForegroundColor Yellow
}

# ============================================================
# STEP 8: Copy Module Files
# ============================================================
Write-Host "`n[8/8] Copying Module Files..." -ForegroundColor Yellow

$moduleDir = "$env:USERPROFILE\Documents\WindowsPowerShell\Modules\SyllogismAgentEngine"
if (!(Test-Path $moduleDir)) {
    New-Item -Path $moduleDir -ItemType Directory -Force | Out-Null
}

# Copy the module
$sourceModule = "$PSScriptRoot\SyllogismAgentEngine.psm1"
if (Test-Path $sourceModule) {
    Copy-Item $sourceModule -Destination "$moduleDir\SyllogismAgentEngine.psm1" -Force
    Write-Host "  ✅ Module copied to: $moduleDir" -ForegroundColor Green
}

# Create the deployment file
$deployPath = "$env:USERPROFILE\Desktop\STAG\deploy.ps1"
New-Item -Path (Split-Path $deployPath) -ItemType Directory -Force | Out-Null

# ============================================================
# DEPLOYMENT COMPLETE
# ============================================================
Write-Host "`n" + "=" * 60 -ForegroundColor Cyan
Write-Host "✅ DEPLOYMENT COMPLETE!" -ForegroundColor Green
Write-Host "=" * 60 -ForegroundColor Cyan

Write-Host @"
📋 Deployment Summary:
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
   Mode:           $Mode
   Ollama:         $(if($ollamaPath){'✅'}else{'⚠️'})
   OpenCode:       $(if($openCodePath){'✅'}else{'⚠️'})
   Tailscale:      $(if($tailscalePath){'✅'}else{'⚠️'})
   GitHub Token:   $(if($GitHubToken){'✅'}else{'⚠️'})
   WhatsApp:       $WhatsAppNumber
   Auto-Start:     $(if($isAdmin){'✅'}else{'⚠️'})
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
"@ -ForegroundColor Cyan

Write-Host "`n🚀 To Start the System:" -ForegroundColor Yellow
Write-Host "   Import-Module SyllogismAgentEngine" -ForegroundColor Gray
Write-Host "   Start-AIAgentEngine" -ForegroundColor Gray
Write-Host "   OR: start-engine" -ForegroundColor Gray

Write-Host "`n📱 CEO Pipeline Ready:" -ForegroundColor Yellow
Write-Host "   ceo-cmd -Command 'your command here'" -ForegroundColor Gray
Write-Host "   status-msg" -ForegroundColor Gray

Write-Host "`n📋 Quick Commands:" -ForegroundColor Yellow
Write-Host "   engine-status" -ForegroundColor Gray
Write-Host "   process-queue" -ForegroundColor Gray
Write-Host "   retry-tasks" -ForegroundColor Gray
Write-Host "   backup" -ForegroundColor Gray
Write-Host "   audit" -ForegroundColor Gray

Write-Host "`n💾 Backup created: $(Backup-SystemState)" -ForegroundColor Green

Write-Host "`n✅ System ready for SyllogismTechnologyAfrica" -ForegroundColor Green
Write-Host "🏢 CEO: Robin Mwarema | WhatsApp: +254704919388" -ForegroundColor Cyan
Write-Host `n"
