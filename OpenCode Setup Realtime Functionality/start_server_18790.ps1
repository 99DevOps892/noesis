# Simple OpenClaw HTTP Server
$ErrorActionPreference = "Continue"

$listener = New-Object System.Net.HttpListener
$listener.Prefixes.Add("http://localhost:18790/")
$listener.Prefixes.Add("http://127.0.0.1:18790/")
$listener.Start()

Write-Host "OpenClaw Server running on port 18790" -ForegroundColor Green

while ($true) {
    try {
        $ctx = $listener.GetContext()
        $res = $ctx.Response
        $html = '<!DOCTYPE html><html><body><h1>OpenClaw</h1><p>agent:main:main</p></body></html>'
        $buffer = [Text.Encoding]::UTF8.GetBytes($html)
        $res.ContentLength64 = $buffer.Length
        $res.OutputStream.Write($buffer, 0, $buffer.Length)
        $res.Close()
    } catch {
        Start-Sleep -Seconds 1
    }
}
