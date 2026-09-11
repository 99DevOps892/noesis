<#
.SYNOPSIS
  STA Page3 Real-Time Server - exposes Page3 global platform over HTTP.
  Port 18791. No external deps. Wires directly into STA_Page3_Global.psm1.
  Endpoints:
    GET  /health               -> liveness + fabric env
    GET  /api/page3/status     -> Get-STAPage3Status
    GET  /api/page3/metrics    -> Get-STAGlobalScaleMetrics
    POST /api/page3/e2e        -> Invoke-STAPage3EndToEnd (guarded: ?confirm=yes)
    GET  /api/page3/master-loop?obs=... -> Invoke-STAMasterControlLoop
    POST /api/page3/event      -> Publish-STAEvent {type, data}
    GET  /api/page3/map?region=KE-Nairobi -> Get-STAMapState
#>
$ErrorActionPreference = "Continue"
$Port = 18791
$Root = "C:\Users\Administrator\OneDrive\Desktop\Ai Setup"
Import-Module "$Root\STA_Page3_Global.psm1" -Force

$LogFile = "$env:USERPROFILE\Desktop\AI_Agent_Logs\sta_page3_server.log"
function Log($m) {
  $e = "[$(Get-Date -Format 'HH:mm:ss')] $m"
  Add-Content -Path $LogFile -Value $e
  Write-Host $e -ForegroundColor Gray
}
function Send-Json($res, $obj, [int]$code=200) {
  $j = $obj | ConvertTo-Json -Depth 8
  $b = [Text.Encoding]::UTF8.GetBytes($j)
  $res.ContentType = "application/json"
  $res.StatusCode = $code
  $res.ContentLength64 = $b.Length
  $res.OutputStream.Write($b, 0, $b.Length)
  $res.Close()
}
function Parse-Query($url) {
  $q = @{}
  if ($url.Query -match '^\?(.*)') {
    foreach ($p in $Matches[1] -split '&') {
      $kv = $p -split '=', 2
      if ($kv.Count -eq 2) { $q[[System.Net.WebUtility]::UrlDecode($kv[0])] = [System.Net.WebUtility]::UrlDecode($kv[1]) }
    }
  }
  return $q
}

$listener = New-Object System.Net.HttpListener
$listener.Prefixes.Add("http://localhost:$Port/")
$listener.Prefixes.Add("http://127.0.0.1:$Port/")
try {
  $listener.Start()
  Log "STA Page3 Server STARTED on $Port"
  Write-Host "STA Page3 live: http://localhost:$Port/health" -ForegroundColor Green
  while ($true) {
    $ctx = $listener.GetContext()
    $req = $ctx.Request; $res = $ctx.Response
    $path = $req.Url.AbsolutePath
    $method = $req.HttpMethod
    Log "REQ $method $path"
    try {
      switch -Wildcard ($path) {
        "/health" { Send-Json $res @{ status="healthy"; server="STA-Page3"; port=$Port; time=(Get-Date -Format "o") } }
        "/api/page3/status" { Send-Json $res (Get-STAPage3Status) }
        "/api/page3/metrics" { Send-Json $res (Get-STAGlobalScaleMetrics) }
        "/api/page3/e2e" {
          if ($method -ne "POST") { Send-Json $res @{ error="POST only" } 405; break }
          $q = Parse-Query $req.Url
          if ($q["confirm"] -ne "yes") { Send-Json $res @{ error="add ?confirm=yes (writes probe data)"; hint="POST /api/page3/e2e?confirm=yes" } 400; break }
          Send-Json $res (Invoke-STAPage3EndToEnd)
        }
        "/api/page3/master-loop" {
          $q = Parse-Query $req.Url
          $obs = if ($q["obs"]) { $q["obs"] } else { "server-ping" }
          Send-Json $res (Invoke-STAMasterControlLoop -Observation $obs)
        }
        "/api/page3/event" {
          if ($method -ne "POST") { Send-Json $res @{ error="POST only" } 405; break }
          $body = (New-Object System.IO.StreamReader($req.InputStream)).ReadToEnd()
          $d = $body | ConvertFrom-Json
          $evt = Publish-STAEvent -Type ([string]$d.type) -Data @{ raw=([string]$d.data) }
          Send-Json $res @{ evt_id=$evt.evt_id; type=$evt.type }
        }
        "/api/page3/map" {
          $q = Parse-Query $req.Url
          $region = if ($q["region"]) { $q["region"] } else { "" }
          Send-Json $res @{ region=$region; signals=(Get-STAMapState -Region $region) }
        }
        default { Send-Json $res @{ error="not-found"; path=$path; try=@("/health","/api/page3/status","/api/page3/metrics") } 404 }
      }
    } catch { Send-Json $res @{ error=([string]$_) } 500 }
    Log "RES done $path"
  }
} catch { Log "FATAL: $_"; Write-Error "$_" }
finally { if ($listener.IsListening) { $listener.Stop() }; $listener.Close(); Log "STOPPED" }
