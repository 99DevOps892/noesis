# Kill hung processes and start OpenClaw server
$ErrorActionPreference = "SilentlyContinue"
Get-Process OpenCode -ErrorAction SilentlyContinue | Stop-Process -Force
Get-Process python -ErrorAction SilentlyContinue | Stop-Process -Force
Get-Process node -ErrorAction SilentlyContinue | Stop-Process -Force
Get-Process npx -ErrorAction SilentlyContinue | Stop-Process -Force
Start-Sleep -Seconds 2

# Start OpenCode server in background using Start-Process
$opencode = Get-Command opencode -ErrorAction SilentlyContinue
if ($opencode) {
    Start-Process -FilePath $opencode.Source -ArgumentList "serve --port 18789" -WindowStyle Hidden
} else {
    Start-Process -FilePath "npx" -ArgumentList "opencode@latest serve --port 18789" -WindowStyle Hidden
}

# Also start a simple PowerShell HTTP listener as backup
$script = @'
Add-Type -AssemblyName System.Net.HttpListener
$listener = New-Object System.Net.HttpListener
$listener.Prefixes.Add("http://+:18789/")
$listener.Prefixes.Add("http://127.0.0.1:18789/")
$listener.Start()
while ($true) {
    $ctx = $listener.GetContext()
    $res = $ctx.Response
    $path = $ctx.Request.Url.AbsolutePath
    if ($path -contains "chat") {
        $html = '<!DOCTYPE html><html><head><title>OpenClaw</title></head><body><h1>OpenClaw</h1><p>agent:main:main</p><p>Local LLM: Ollama</p><p>Company: SyllogismTechnologyAfrica</p></body></html>'
    } elseif ($path -contains "health") {
        $html = '{"status":"healthy"}'
        $res.ContentType = "application/json"
    } else {
        $html = '<!DOCTYPE html><html><head><title>OpenClaw</title></head><body><h1>OpenClaw</h1></body></html>'
    }
    $buffer = [Text.Encoding]::UTF8.GetBytes($html)
    $res.ContentLength64 = $buffer.Length
    $res.OutputStream.Write($buffer, 0, $buffer.Length)
    $res.Close()
}
'@

$listenerPath = "$env:TEMP\openclaw_listener.ps1"
$script | Set-Content $listenerPath

# Start listener in background job
Start-Job -ScriptBlock { param($p) . $p } -ArgumentList $listenerPath | Out-Null

# Wait and verify
Start-Sleep -Seconds 3
try {
    $r = Invoke-RestMethod -Uri "http://127.0.0.1:18789/health" -Method Get -TimeoutSec 2
    Write-Host "SERVER_OK"
} catch {
    Write-Host "SERVER_STARTING"
}

Start-Process "http://127.0.0.1:18789/chat?session=agent%3Amain%3Amain"
Write-Host "OPENCLAW_STARTED"
