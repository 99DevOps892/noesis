<# 
.SYNOPSIS
    OpenClaw HTTP Server - Debug version with file logging
#>

$ErrorActionPreference = "Continue"

$Port = 18789
$LogFile = "$env:USERPROFILE\Desktop\AI_Agent_Logs\server_debug.log"

$listener = New-Object System.Net.HttpListener
$listener.Prefixes.Add("http://localhost:$Port/")
$listener.Prefixes.Add("http://127.0.0.1:$Port/")

function Log($msg) {
    $entry = "[$(Get-Date -Format 'HH:mm:ss')] $msg"
    Add-Content -Path $LogFile -Value $entry
    Write-Host $entry -ForegroundColor Gray
}

try {
    $listener.Start()
    Log "✅ OpenClaw Server STARTED on port $Port"
    Log "🌐 http://localhost:$Port/chat?session=agent%3Amain%3Amain"

    while ($true) {
        try {
            $context = $listener.GetContext()
            $request = $context.Request
            $response = $context.Response
            $path = $request.Url.AbsolutePath
            
            Log "REQUEST: $($request.HttpMethod) $path"
            
            $content = ""
            $contentType = "text/html"
            $statusCode = 200
            
            if ($path -eq "/health") {
                $contentType = "application/json"
                $content = (@{ status = "healthy"; timestamp = (Get-Date -Format "yyyy-MM-ddTHH:mm:ss"); server = "OpenClaw"; port = $Port } | ConvertTo-Json -Depth 3)
                Log "  -> MATCHED /health"
            } elseif ($path -eq "/api/agent") {
                $contentType = "application/json"
                if ($request.HttpMethod -eq "POST") {
                    $body = (New-Object System.IO.StreamReader($request.InputStream)).ReadToEnd()
                    $content = (@{ success = $true; session = "agent:main:main"; received = $body; timestamp = (Get-Date -Format "yyyy-MM-ddTHH:mm:ss") } | ConvertTo-Json -Depth 3)
                } else {
                    $content = (@{ status = "active"; session = "agent:main:main"; agents = @("opencode","deepseek","github","whatsapp","ollama","openclaw"); timestamp = (Get-Date -Format "yyyy-MM-ddTHH:mm:ss") } | ConvertTo-Json -Depth 3)
                }
                Log "  -> MATCHED /api/agent"
            } elseif ($path -like "/chat*") {
                $contentType = "text/html"
                $content = Get-ChatPage
                Log "  -> MATCHED /chat*"
            } elseif ($path -eq "/api/whatsapp/webhook" -and $request.HttpMethod -eq "POST") {
                $contentType = "application/json"
                $body = (New-Object System.IO.StreamReader($request.InputStream)).ReadToEnd()
                $data = $body | ConvertFrom-Json
                $logPath = "$env:USERPROFILE\Desktop\AI_Agent_Logs\whatsapp_incoming.json"
                $current = if (Test-Path $logPath) { Get-Content $logPath -Raw | ConvertFrom-Json } else { @() }
                $current += @{ message = $data.Body; from = $data.From; timestamp = (Get-Date -Format "yyyy-MM-ddTHH:mm:ss"); status = "unprocessed" }
                $current | ConvertTo-Json -Depth 10 | Set-Content $logPath
                $content = (@{ status = "received"; messageId = [Guid]::NewGuid().ToString() } | ConvertTo-Json)
                Log "  -> MATCHED /api/whatsapp/webhook"
            } elseif ($path -eq "/api/whatsapp/send" -and $request.HttpMethod -eq "POST") {
                $contentType = "application/json"
                $body = (New-Object System.IO.StreamReader($request.InputStream)).ReadToEnd()
                $data = $body | ConvertFrom-Json
                Log "📱 WhatsApp Send: $($data.message) → $($data.to)"
                $content = (@{ success = $true; messageId = [Guid]::NewGuid().ToString() } | ConvertTo-Json)
                Log "  -> MATCHED /api/whatsapp/send"
            } elseif ($path -eq "/api/github/webhook" -and $request.HttpMethod -eq "POST") {
                $contentType = "application/json"
                $body = (New-Object System.IO.StreamReader($request.InputStream)).ReadToEnd()
                $headers = @{}; foreach ($key in $request.Headers.AllKeys) { $headers[$key] = $request.Headers[$key] }
                $logPath = "$env:USERPROFILE\Desktop\AI_Agent_Logs\github_webhook_events.json"
                $current = if (Test-Path $logPath) { Get-Content $logPath -Raw | ConvertFrom-Json } else { @() }
                $current += @{ event = $headers["X-GitHub-Event"]; body = $body; timestamp = (Get-Date -Format "yyyy-MM-ddTHH:mm:ss"); status = "received" }
                $current | ConvertTo-Json -Depth 10 | Set-Content $logPath
                $content = (@{ status = "received"; event = $headers["X-GitHub-Event"] } | ConvertTo-Json)
                Log "  -> MATCHED /api/github/webhook"
            } else {
                $statusCode = 404
                $contentType = "application/json"
                $content = (@{ error = "Not found"; path = $path } | ConvertTo-Json)
                Log "  -> NO MATCH (404)"
            }
            
            $buffer = [Text.Encoding]::UTF8.GetBytes($content)
            $response.ContentType = $contentType
            $response.StatusCode = $statusCode
            $response.ContentLength64 = $buffer.Length
            $response.OutputStream.Write($buffer, 0, $buffer.Length)
            $response.Close()
            Log "RESPONSE: $statusCode ($contentType)"
        } catch {
            Log "ERROR: $_"
            if ($listener.IsListening) { Start-Sleep -Milliseconds 100 }
        }
    }
} catch {
    Log "FATAL: $_"
} finally {
    if ($listener.IsListening) { $listener.Stop() }
    $listener.Close()
    Log "🛑 OpenClaw Server STOPPED"
}

function Get-ChatPage {
    return @"
<!DOCTYPE html>
<html>
<head>
    <title>OpenClaw - Agent Session</title>
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <style>
        body { font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif; max-width: 800px; margin: 0 auto; padding: 20px; background: #0d1117; color: #e6edf3; }
        .header { border-bottom: 1px solid #30363d; padding-bottom: 15px; margin-bottom: 20px; }
        .session { background: #161b22; border: 1px solid #30363d; border-radius: 8px; padding: 15px; margin: 10px 0; font-family: monospace; }
        .status { color: #3fb950; }
        .endpoint { color: #58a6ff; word-break: break-all; }
        button { background: #238636; color: white; border: none; padding: 10px 20px; border-radius: 6px; cursor: pointer; font-size: 14px; margin: 5px; }
        button:hover { background: #2ea043; }
        .messages { background: #161b22; border: 1px solid #30363d; border-radius: 8px; padding: 15px; min-height: 200px; max-height: 400px; overflow-y: auto; }
        .msg { padding: 8px; margin: 5px 0; border-radius: 4px; }
        .msg-user { background: #1f6feb; text-align: right; }
        .msg-agent { background: #238636; }
        input { width: 70%; padding: 10px; background: #0d1117; border: 1px solid #30363d; color: #e6edf3; border-radius: 4px; }
    </style>
</head>
<body>
    <div class="header">
        <h1>🤖 OpenClaw Mobile</h1>
        <div class="session">Session: <span class="endpoint">agent:main:main</span></div>
        <div class="session status">● Connected to Syllogism Agent Engine</div>
    </div>
    <div class="session">
        <strong>Endpoints:</strong><br>
        <span class="endpoint">GET /chat?session=agent:main:main</span> - This interface<br>
        <span class="endpoint">GET /health</span> - Health check<br>
        <span class="endpoint">GET /api/agent</span> - Agent status JSON<br>
    </div>
    <div class="messages" id="messages">
        <div class="msg msg-agent">🤖 OpenClaw ready. Session: agent:main:main</div>
        <div class="msg msg-agent">📱 Connected to SyllogismTechnologyAfrica AI Agent Engine</div>
        <div class="msg msg-agent">⚡ OpenCode Orchestrator: MAIN task router active</div>
    </div>
    <div style="margin-top: 15px; display: flex; gap: 10px;">
        <input type="text" id="msgInput" placeholder="Type message to agent..." onkeypress="if(event.key==='Enter')sendMsg()">
        <button onclick="sendMsg()">Send</button>
        <button onclick="refreshMsgs()">Refresh</button>
    </div>
    <script>
        async function sendMsg() {
            const input = document.getElementById('msgInput');
            const msg = input.value.trim();
            if (!msg) return;
            addMsg(msg, 'user');
            input.value = '';
            try {
                const res = await fetch('/api/agent', { method: 'POST', headers: {'Content-Type': 'application/json'}, body: JSON.stringify({message: msg, session: 'agent:main:main'}) });
                const data = await res.json();
                addMsg(JSON.stringify(data, null, 2), 'agent');
            } catch (e) { addMsg('Error: ' + e.message, 'agent'); }
        }
        function addMsg(text, type) {
            const div = document.createElement('div');
            div.className = 'msg msg-' + type;
            div.textContent = (type === 'user' ? '👤 You: ' : '🤖 Agent: ') + text;
            document.getElementById('messages').appendChild(div);
            document.getElementById('messages').scrollTop = document.getElementById('messages').scrollHeight;
        }
        async function refreshMsgs() {
            try {
                const res = await fetch('/chat?session=agent:main:main');
                addMsg('Refreshed - Server responding', 'agent');
            } catch (e) { addMsg('Refresh error: ' + e.message, 'agent'); }
        }
        setInterval(refreshMsgs, 30000);
    </script>
</body>
</html>
"@
}