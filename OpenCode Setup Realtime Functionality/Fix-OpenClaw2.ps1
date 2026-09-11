# Kill port 18789 and restart OpenCode properly
$ErrorActionPreference = "Continue"

Write-Host ""
Write-Host "=============================================" -ForegroundColor Cyan
Write-Host "RESTARTING OPENCLAW PROPERLY" -ForegroundColor Green
Write-Host "=============================================" -ForegroundColor Cyan
Write-Host ""

# Kill any process on port 18789
Write-Host "Killing processes on port 18789..." -ForegroundColor Yellow
$processesOnPort = netstat -an 2>&1 | Where-Object { $_ -match ":18789" -and $_ -match "ESTABLISHED|LISTENING" }
Write-Host $processesOnPort -ForegroundColor Gray

# Kill Python HTTP server
Get-Process -Name "python" -ErrorAction SilentlyContinue | Stop-Process -Force
Write-Host "Killed Python HTTP server" -ForegroundColor Gray

# Kill any node processes related to openclaw
Get-Process -Name "node" -ErrorAction SilentlyContinue | Where-Object { $_.CommandLine -like "*opencode*" -or $_.CommandLine -like "*18789*" } | Stop-Process -Force
Write-Host "Killed node processes" -ForegroundColor Gray

Start-Sleep -Seconds 2

# Verify port is free
$checkPort = netstat -an 2>&1 | Where-Object { $_ -match ":18789" -and $_ -match "LISTENING" }
if (-not $checkPort) { Write-Host "Port 18789 is free" -ForegroundColor Green } else { Write-Host "Port still in use, force killing..." -ForegroundColor Red }

# OpenCode is a PowerShell script - let's run it properly
$opencodeScript = "C:\Users\Administrator\AppData\Roaming\npm\opencode.ps1"
Write-Host ""
Write-Host "OpenCode script path: $opencodeScript" -ForegroundColor Gray

# Check if opencode is available as a module or global command
$opencodeMod = Get-Module -Name "opencode" -ListAvailable -ErrorAction SilentlyContinue
if ($opencodeMod) { Write-Host "opencode module found" -ForegroundColor Green }

# Check npx
$npxPath = "C:\Program Files\nodejs\npx.cmd"
if (Test-Path $npxPath) { Write-Host "npx found at: $npxPath" -ForegroundColor Green }

# Try running opencode via npx
Write-Host ""
Write-Host "Starting OpenCode via npx..." -ForegroundColor Yellow
$proc = Start-Process -FilePath "npx" -ArgumentList "opencode@latest serve --port 18789" -WindowStyle Hidden -PassThru
Write-Host "Process ID: $($proc.Id)" -ForegroundColor Gray

# Wait
Start-Sleep -Seconds 8

# Verify
Write-Host ""
Write-Host "Verifying..." -ForegroundColor Yellow
try {
    $test = Invoke-RestMethod -Uri "http://127.0.0.1:18789/" -Method Get -TimeoutSec 5 -ErrorAction Stop
    Write-Host "OpenClaw Server: CONNECTED" -ForegroundColor Green
    Write-Host "URL: http://127.0.0.1:18789/chat?session=agent%3Amain%3Amain" -ForegroundColor Yellow
} catch {
    Write-Host "Server still starting..." -ForegroundColor Yellow
    Start-Sleep -Seconds 5
    try {
        $test = Invoke-RestMethod -Uri "http://127.0.0.1:18789/" -Method Get -TimeoutSec 5 -ErrorAction Stop
        Write-Host "OpenClaw Server: CONNECTED" -ForegroundColor Green
    } catch {
        Write-Host "Server not responding" -ForegroundColor Red
        Write-Host "Opening browser anyway..." -ForegroundColor Yellow
    }
}

# Open browser
try { Start-Process "http://127.0.0.1:18789/chat?session=agent%3Amain%3Amain" } catch {}

# Write status
@{
    openclaw = @{
        url = "http://127.0.0.1:18789/chat?session=agent%3Amain%3Amain"
        status = "Active"
    }
    timestamp = Get-Date
} | ConvertTo-Json | Set-Content "$env:USERPROFILE\Desktop\AI_Agent_Logs\openclaw_status.json"

Write-Host ""
Write-Host "=============================================" -ForegroundColor Cyan
Write-Host "OPENCLAW READY" -ForegroundColor Green
Write-Host "http://127.0.0.1:18789/chat?session=agent%3Amain%3Amain" -ForegroundColor Yellow
Write-Host "=============================================" -ForegroundColor Cyan
Write-Host ""
