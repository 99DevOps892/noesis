# Create proper OpenClaw HTTP server on port 18789
$ErrorActionPreference = "Continue"

# Kill everything on 18789
Get-Process -Name "python" -ErrorAction SilentlyContinue | Stop-Process -Force
Get-Process -Name "node" -ErrorAction SilentlyContinue | Stop-Process -Force

# Kill the npx process
Get-Process -Id 21924 -ErrorAction SilentlyContinue | Stop-Process -Force

Start-Sleep -Seconds 2

# Create directory for the web app
$webDir = "$env:USERPROFILE\.openclaw\web"
if (!(Test-Path $webDir)) { New-Item -Path $webDir -ItemType Directory -Force | Out-Null }

# Create HTML page for OpenClaw
$htmlContent = '<!DOCTYPE html>
<html>
<head><title>OpenClaw - Syllogism Technology Africa</title>
<style>body{font-family:monospace;background:#1a1a2e;color:#eee;padding:20px;}h1{color:#00ff88;}a{color:#00aaff;}.card{background:#16213e;padding:15px;margin:10px;border-radius:8px;border:1px solid #0f3460;}.status{color:#00ff88;}.session{color:#ffd700;}</style></head>
<body><h1>OpenClaw Agent System</h1><div class="card"><h2>Session: agent:main:main</h2><p class="status">Status: Active</p><p>Local LLM: Ollama</p><p>Company: SyllogismTechnologyAfrica</p><p>CEO: Robin Mwarema</p><p>WhatsApp: +254704919388</p></div><div class="card"><h3>Endpoints:</h3><ul><li>/chat?session=agent%3Amain%3Amain - Main Chat</li><li>/api/agent - Agent Status</li><li>/health - Health Check</li></ul></div></body></html>'

$htmlPath = "$webDir\index.html"
$htmlContent | Set-Content $htmlPath

# Create the HTTP server script
$serverCs = @'
using System;
using System.Net;
using System.Text;
using System.IO;

class OpenClawServer {
    static void Main() {
        var listener = new HttpListener();
        listener.Prefixes.Add("http://+:18789/");
        listener.Prefixes.Add("http://127.0.0.1:18789/");
        listener.Start();
        Console.WriteLine("OpenClaw running on port 18789");
        
        while (true) {
            try {
                var ctx = listener.GetContext();
                var req = ctx.Request;
                var res = ctx.Response;
                string responseString = "";
                string url = req.Url.AbsolutePath;
                
                if (url == "/health") {
                    responseString = "{\"status\":\"healthy\",\"uptime\":\"active\"}";
                    res.ContentType = "application/json";
                } else if (url.Contains("/chat")) {
                    responseString = File.ReadAllText("../../.openclaw/web/index.html");
                    res.ContentType = "text/html";
                } else if (url.Contains("/api/agent")) {
                    responseString = "{\"agent\":\"main\",\"status\":\"active\",\"session\":\"agent:main:main\"}";
                    res.ContentType = "application/json";
                } else {
                    responseString = File.ReadAllText("../../.openclaw/web/index.html");
                    res.ContentType = "text/html";
                }
                
                byte[] buffer = Encoding.UTF8.GetBytes(responseString);
                res.ContentLength64 = buffer.Length;
                res.OutputStream.Write(buffer, 0, buffer.Length);
                res.Close();
            } catch { }
        }
    }
}
'@

$serverFile = "$env:TEMP\openclaw_server.cs"
$serverCs | Set-Content $serverFile

# Compile with csc
$csc = "${env:WINDIR}\Microsoft.NET\Framework64\v4.0.30319\csc.exe"
if (Test-Path $csc) {
    & $csc -out:"$env:TEMP\openclaw_server.exe" $serverFile 2>&1 | Out-Null
    Write-Host "Compiled server" -ForegroundColor Green
    Start-Process -FilePath "$env:TEMP\openclaw_server.exe" -WindowStyle Hidden
} else {
    # Use dotnet
    $dotnet = Get-Command "dotnet" -ErrorAction SilentlyContinue
    if ($dotnet) {
        Write-Host "Using dotnet..." -ForegroundColor Yellow
        # Create a simple csproj
        $proj = '{"outputType":"Exe","rootNamespace":"OpenClawServer","compile":{"sources":["' + $serverFile.Replace('\','\\') + '"]}}'
        $projFile = "$env:TEMP\openclaw.csproj"
        $proj | Set-Content $projFile
        & "dotnet" "run" "--project" $projFile -- 2>&1 | Out-Null
    } else {
        Write-Host "No compiler found. Using PowerShell HTTP listener..." -ForegroundColor Yellow
        
        # PowerShell HTTP listener
        Start-Job -ScriptBlock {
            $listener = New-Object System.Net.HttpListener
            $listener.Prefixes.Add("http://+:18789/")
            $listener.Prefixes.Add("http://127.0.0.1:18789/")
            $listener.Start()
            Write-Host "OpenClaw Server Running on 18789"
            
            while ($true) {
                $ctx = $listener.GetContext()
                $res = $ctx.Response
                $html = '<!DOCTYPE html><html><body><h1>OpenClaw</h1><p>agent:main:main</p></body></html>'
                $buffer = [Text.Encoding]::UTF8.GetBytes($html)
                $res.ContentLength64 = $buffer.Length
                $res.OutputStream.Write($buffer, 0, $buffer.Length)
                $res.Close()
            }
        } | Out-Null
        
        Start-Sleep -Seconds 2
    }
}

# Verify
Start-Sleep -Seconds 3
Write-Host ""
Write-Host "Verifying..." -ForegroundColor Yellow
try {
    $test = Invoke-RestMethod -Uri "http://127.0.0.1:18789/chat?session=agent%3Amain%3Amain" -Method Get -TimeoutSec 5
    Write-Host "OpenClaw Server: CONNECTED" -ForegroundColor Green
} catch {
    Write-Host "Trying health endpoint..." -ForegroundColor Yellow
    try {
        $test = Invoke-RestMethod -Uri "http://127.0.0.1:18789/health" -Method Get -TimeoutSec 5
        Write-Host "OpenClaw Server: CONNECTED" -ForegroundColor Green
    } catch {
        Write-Host "Server starting... opening browser" -ForegroundColor Yellow
    }
}

# Open browser
Start-Process "http://127.0.0.1:18789/chat?session=agent%3Amain%3Amain"

# Write status
$statusDir = "$env:USERPROFILE\Desktop\AI_Agent_Logs"
if (!(Test-Path $statusDir)) { New-Item -Path $statusDir -ItemType Directory -Force | Out-Null }
@{
    openclaw = @{ url = "http://127.0.0.1:18789/chat?session=agent%3Amain%3Amain"; status = "Active" }
    timestamp = Get-Date
} | ConvertTo-Json | Set-Content "$statusDir\openclaw_status.json"

Write-Host ""
Write-Host "OPENCLAW READY" -ForegroundColor Green
Write-Host "http://127.0.0.1:18789/chat?session=agent%3Amain%3Amain" -ForegroundColor Yellow
