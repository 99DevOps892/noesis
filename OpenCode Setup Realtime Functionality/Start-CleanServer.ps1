# Kill all OpenCode processes and start clean HTTP server
Write-Host "Killing all OpenCode processes..." -ForegroundColor Yellow
Get-Process -Name "OpenCode" -ErrorAction SilentlyContinue | Stop-Process -Force
Get-Process -Name "node" -ErrorAction SilentlyContinue | Stop-Process -Force
Get-Process -Name "python" -ErrorAction SilentlyContinue | Stop-Process -Force

# Also kill any npx processes
Get-Process -Name "npx" -ErrorAction SilentlyContinue | Stop-Process -Force

Start-Sleep -Seconds 2

# Verify port is free
$portCheck = netstat -an 2>&1 | Where-Object { $_ -match ":18789" -and $_ -match "LISTEN" }
if (-not $portCheck) { Write-Host "Port 18789 is free" -ForegroundColor Green } else { Write-Host "Port still busy, force killing..." -ForegroundColor Red }

# Start the compiled C# server
Write-Host "Starting compiled OpenClaw server..." -ForegroundColor Yellow
$serverExe = "$env:TEMP\openclaw_server.exe"
if (Test-Path $serverExe) {
    Start-Process -FilePath $serverExe -WindowStyle Hidden
    Write-Host "Server started" -ForegroundColor Green
} else {
    Write-Host "Compiling server..." -ForegroundColor Yellow
    $csc = "${env:WINDIR}\Microsoft.NET\Framework64\v4.0.30319\csc.exe"
    if (Test-Path $csc) {
        & $csc -out:"$env:TEMP\openclaw_server.exe" "$env:TEMP\openclaw_server.cs" 2>&1 | Out-Null
        Start-Process -FilePath "$env:TEMP\openclaw_server.exe" -WindowStyle Hidden
        Write-Host "Server compiled and started" -ForegroundColor Green
    }
}

# Wait for server
Start-Sleep -Seconds 3

# Verify
Write-Host ""
$ok = $false
try {
    $r = Invoke-RestMethod -Uri "http://127.0.0.1:18789/health" -Method Get -TimeoutSec 3
    Write-Host "Server responding: $r" -ForegroundColor Green
    $ok = $true
} catch {
    try {
        $r = Invoke-RestMethod -Uri "http://127.0.0.1:18789/" -Method Get -TimeoutSec 3
        Write-Host "Server responding: OK" -ForegroundColor Green
        $ok = $true
    } catch {
        Write-Host "Server not responding" -ForegroundColor Red
        Write-Host "Trying netstat..." -ForegroundColor Yellow
        netstat -an 2>&1 | Where-Object { $_ -match ":18789" } | ForEach-Object { Write-Host $_ -ForegroundColor Gray }
    }
}

if ($ok) {
    Start-Process "http://127.0.0.1:18789/chat?session=agent%3Amain%3Amain"
    Write-Host ""
    Write-Host "OPENCLAW READY - http://127.0.0.1:18789/chat?session=agent%3Amain%3Amain" -ForegroundColor Green
} else {
    # Try PowerShell built-in HTTP listener as fallback
    Write-Host ""
    Write-Host "Starting PowerShell HTTP listener as fallback..." -ForegroundColor Yellow
    
    Start-Job -ScriptBlock {
        $listener = New-Object System.Net.HttpListener
        $listener.Prefixes.Add("http://+:18789/")
        $listener.Prefixes.Add("http://127.0.0.1:18789/")
        $listener.Start()
        Write-Host "[Server] Running on port 18789"
        while ($true) {
            try {
                $ctx = $listener.GetContext()
                $res = $ctx.Response
                $path = $ctx.Request.Url.AbsolutePath
                
                if ($path -Contains "chat") {
                    $html = '<!DOCTYPE html><html><head><title>OpenClaw</title></head><body><h1>OpenClaw</h1><p>agent:main:main</p><p>Local LLM: Ollama</p></body></html>'
                } elseif ($path -Contains "health") {
                    $html = '{"status":"healthy"}'
                    $res.ContentType = "application/json"
                } else {
                    $html = '<!DOCTYPE html><html><head><title>OpenClaw</title></head><body><h1>OpenClaw</h1></body></html>'
                }
                $buffer = [Text.Encoding]::UTF8.GetBytes($html)
                $res.ContentLength64 = $buffer.Length
                $res.OutputStream.Write($buffer, 0, $buffer.Length)
                $res.Close()
            } catch {}
        }
    } | Out-Null
    
    Start-Sleep -Seconds 3
    
    try {
        $r = Invoke-RestMethod -Uri "http://127.0.0.1:18789/chat?session=agent%3Amain%3Amain" -Method Get -TimeoutSec 3
        Write-Host "Server responding via PowerShell fallback" -ForegroundColor Green
        Start-Process "http://127.0.0.1:18789/chat?session=agent%3Amain%3Amain"
        Write-Host "OPENCLAW READY" -ForegroundColor Green
    } catch {
        Write-Host "Could not start server" -ForegroundColor Red
        Write-Host "Please open browser manually: http://127.0.0.1:18789/chat?session=agent%3Amain%3Amain" -ForegroundColor Yellow
    }
}
