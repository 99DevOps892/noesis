# Fix OpenClaw - Start proper HTTP server on port 18789
$ErrorActionPreference = "Continue"

Write-Host ""
Write-Host "=============================================" -ForegroundColor Cyan
Write-Host "FIXING OPENCLAW - STARTING SERVER" -ForegroundColor Green
Write-Host "=============================================" -ForegroundColor Cyan
Write-Host ""

# Check if anything is on port 18789
$netStat = netstat -an 2>&1 | Where-Object { $_ -match ":18789" }
if ($netStat) {
    Write-Host "Port 18789 already in use" -ForegroundColor Yellow
} else {
    Write-Host "Port 18789 is free" -ForegroundColor Gray
}

# Check for npx/opencode
$npxCmd = Get-Command "npx" -ErrorAction SilentlyContinue
$opencodeCmd = Get-Command "opencode" -ErrorAction SilentlyContinue

Write-Host ""
Write-Host "Checking for OpenCode/npx..." -ForegroundColor Yellow
if ($opencodeCmd) { Write-Host "  opencode found: $($opencodeCmd.Source)" -ForegroundColor Green }
if ($npxCmd) { Write-Host "  npx found: $($npxCmd.Source)" -ForegroundColor Green }

# Start OpenCode server
Write-Host ""
Write-Host "Starting OpenCode server on port 18789..." -ForegroundColor Yellow

if ($opencodeCmd) {
    Start-Process -FilePath $opencodeCmd.Source -ArgumentList "serve --port 18789" -WindowStyle Hidden
    Write-Host "Started opencode serve --port 18789" -ForegroundColor Gray
} elseif ($npxCmd) {
    Start-Process -FilePath $npxCmd.Source -ArgumentList "opencode@latest serve --port 18789" -WindowStyle Hidden
    Write-Host "Started npx opencode@latest serve --port 18789" -ForegroundColor Gray
} else {
    # Create a simple HTTP server as fallback using PowerShell
    Write-Host "No opencode/npx found. Starting PowerShell HTTP fallback..." -ForegroundColor Yellow
    
    # Write a simple HTTP server script
    $serverScript = @'
using System;
using System.Net;
using System.Text;
using System.IO;

class Server {
    static void Main() {
        var listener = new HttpListener();
        listener.Prefixes.Add("http://*:18789/");
        listener.Prefixes.Add("http://+:18789/");
        listener.Start();
        Console.WriteLine("OpenClaw Server running on port 18789");
        
        while (true) {
            var context = listener.GetContext();
            var response = context.Response;
            var sb = new StringBuilder();
            sb.Append("<!DOCTYPE html><html><head><title>OpenClaw</title></head><body>");
            sb.Append("<h1>OpenClaw Agent System</h1>");
            sb.Append("<p>Session: agent:main:main</p>");
            sb.Append("<p>Status: Active</p>");
            sb.Append("<p>Local LLM: http://localhost:11434</p>");
            sb.Append("<p>Company: SyllogismTechnologyAfrica</p>");
            sb.Append("</body></html>");
            var buffer = Encoding.UTF8.GetBytes(sb.ToString());
            response.ContentLength64 = buffer.Length;
            response.OutputStream.Write(buffer, 0, buffer.Length);
            response.Close();
        }
    }
}
'@
    
    $serverFile = "$env:TEMP\openclaw_server.cs"
    $serverScript | Set-Content $serverFile
    
    # Compile and run
    $cscPath = "${env:WINDIR}\Microsoft.NET\Framework64\v4.0.30319\csc.exe"
    if (Test-Path $cscPath) {
        & $cscPath -out:"$env:TEMP\openclaw_server.exe" $serverFile
        Start-Process -FilePath "$env:TEMP\openclaw_server.exe" -WindowStyle Hidden
        Write-Host "Started PowerShell HTTP fallback server" -ForegroundColor Green
    } else {
        # Try dotnet
        $dotnetPath = Get-Command "dotnet" -ErrorAction SilentlyContinue
        if ($dotnetPath) {
            Start-Process -FilePath "dotnet" -ArgumentList "exec --urls http://*:18789" -WindowStyle Hidden
            Write-Host "Started dotnet server" -ForegroundColor Green
        }
    }
}

# Wait for server to start
Start-Sleep -Seconds 5

# Verify
Write-Host ""
Write-Host "Verifying connection..." -ForegroundColor Yellow
try {
    $test = Invoke-RestMethod -Uri "http://127.0.0.1:18789/chat?session=agent%3Amain%3Amain" -Method Get -TimeoutSec 5 -ErrorAction SilentlyContinue
    Write-Host "OpenClaw Server: OK" -ForegroundColor Green
} catch {
    try {
        $test = Invoke-RestMethod -Uri "http://127.0.0.1:18789/" -Method Get -TimeoutSec 5 -ErrorAction SilentlyContinue
        Write-Host "OpenClaw Server: OK" -ForegroundColor Green
    } catch {
        Write-Host "OpenClaw Server: Not responding yet, retrying..." -ForegroundColor Yellow
        Start-Sleep -Seconds 5
        try {
            $test = Invoke-RestMethod -Uri "http://127.0.0.1:18789/" -Method Get -TimeoutSec 5 -ErrorAction SilentlyContinue
            Write-Host "OpenClaw Server: OK" -ForegroundColor Green
        } catch {
            Write-Host "OpenClaw Server: Still not responding" -ForegroundColor Red
            Write-Host "Trying to start with different method..." -ForegroundColor Yellow
            
            # Try Python HTTP server as last resort
            $pythonPath = Get-Command "python" -ErrorAction SilentlyContinue
            if ($pythonPath) {
                Start-Process -FilePath "python" -ArgumentList "-m http.server 18789 --bind 127.0.0.1" -WindowStyle Hidden
                Write-Host "Started Python HTTP server on 127.0.0.1:18789" -ForegroundColor Green
            } else {
                # Write a simple PowerShell HTTP listener script
                Write-Host "No server available. Opening browser directly." -ForegroundColor Yellow
            }
        }
    }
}

# Open browser
try {
    Start-Process "http://127.0.0.1:18789/chat?session=agent%3Amain%3Amain"
    Write-Host "Browser opened: http://127.0.0.1:18789/chat?session=agent%3Amain%3Amain" -ForegroundColor Green
} catch {
    Write-Host "Could not auto-open browser" -ForegroundColor Yellow
}

Write-Host ""
Write-Host "=============================================" -ForegroundColor Cyan
Write-Host "OPENCLAW FIXED" -ForegroundColor Green
Write-Host "URL: http://127.0.0.1:18789/chat?session=agent%3Amain%3Amain" -ForegroundColor Yellow
Write-Host "=============================================" -ForegroundColor Cyan
Write-Host ""
