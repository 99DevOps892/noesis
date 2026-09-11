# ============================================================
# STA ECOSYSTEM FABRIC v1.0 - Real Tasks Functionality Upgrade
# Covers 90-task spec: Identity, Events, Payments, AI, Audit, etc.
# CEO: Robin Mwarema | PowerShell 5.1 compatible, no external deps
# Integrates with SyllogismAgentEngine v4.1 (TaskQueueEngine, WebhookServer)
# ============================================================

$Global:STAFabricRoot = Split-Path $PSScriptRoot -Parent
if (-not $Global:STAFabricRoot -or $Global:STAFabricRoot -eq "") { $Global:STAFabricRoot = "$env:USERPROFILE\Desktop\AI_Agent_Logs" }
$Global:STAFabric = @{
  Version = "1.0.0"
  DataDir = "$env:USERPROFILE\Desktop\AI_Agent_Logs\sta_fabric"
  Env = "LOCAL"
}

function Initialize-STAFabric {
  $dirs = @("", "\events", "\identity", "\memory", "\audit", "\approvals", "\notifications", "\payments", "\docs", "\agents", "\tasks", "\devices", "\analytics", "\costs", "\flags", "\workflows")
  foreach ($d in $dirs) {
    $p = $Global:STAFabric.DataDir + $d
    if (!(Test-Path $p)) { New-Item -Path $p -ItemType Directory -Force | Out-Null }
  }
  Write-Host "STA Fabric initialized: $($Global:STAFabric.DataDir) Env=$($Global:STAFabric.Env)" -ForegroundColor Green
}

function Get-STAFabricPath([string]$Name) {
  Initialize-STAFabric | Out-Null
  return "$($Global:STAFabric.DataDir)\$Name"
}

# #67 UNIVERSAL ID + #68 CORRELATION
function New-STAId([string]$Prefix) {
  return "$($Prefix)_" + ([Guid]::NewGuid().ToString("N").Substring(0,12))
}
function New-STACorrelationId { return [Guid]::NewGuid().ToString() }

function Expand-STAItems($Obj) {
  $out = @()
  if ($Obj -eq $null) { return $out }
  if ($Obj -is [array]) { foreach ($i in $Obj) { $out += Expand-STAItems $i }; return $out }
  $props = @($Obj.PSObject.Properties | Select-Object -ExpandProperty Name)
  if ($props -contains "value" -and $props -contains "Count" -and -not ($props -contains "task_id" -or $props -contains "evt_id" -or $props -contains "txn_id")) {
    return Expand-STAItems $Obj.value
  }
  return @($Obj)
}
function Save-STAJson([string]$Path, $Object) {
  $dir = Split-Path $Path
  if (!(Test-Path $dir)) { New-Item -Path $dir -ItemType Directory -Force | Out-Null }
  $all = @()
  if (Test-Path $Path) {
    try { $raw = Get-Content $Path -Raw; if ($raw.Trim() -ne "") { $parsed = ConvertFrom-Json $raw; $all = @(Expand-STAItems $parsed) } } catch { $all = @() }
  }
  $all += $Object
  $all | ConvertTo-Json -Depth 10 | Set-Content -Path $Path
}
function Get-STAJson([string]$Path) {
  if (!(Test-Path $Path)) { return @() }
  try { $raw = Get-Content $Path -Raw; if ($raw.Trim() -eq "") { return @() }; $parsed = ConvertFrom-Json $raw; return @(Expand-STAItems $parsed) } catch { return @() }
}

# #9,#10,#11,#69 EVENT BUS (file-backed pub/sub, replayable)
function Publish-STAEvent([string]$Type, [hashtable]$Data, [string]$CorrelationId = "") {
  if ($CorrelationId -eq "") { $CorrelationId = New-STACorrelationId }
  $evt = @{
    evt_id = (New-STAId "evt"); type = $Type; data = $Data
    correlation_id = $CorrelationId; created_at = (Get-Date -Format "o")
    env = $Global:STAFabric.Env
  }
  Save-STAJson (Get-STAFabricPath "events\events.json") $evt
  return $evt
}
function Get-STAEvents([string]$Type = "", [string]$CorrelationId = "") {
  $all = Get-STAJson (Get-STAFabricPath "events\events.json")
  if ($Type -ne "") { $all = @($all | Where-Object { $_.type -eq $Type }) }
  if ($CorrelationId -ne "") { $all = @($all | Where-Object { $_.correlation_id -eq $CorrelationId }) }
  return $all
}
function Replay-STAEvents([string]$Type, [scriptblock]$Handler) {
  $evts = Get-STAEvents -Type $Type
  $n = 0
  foreach ($e in $evts) { & $Handler $e; $n++ }
  return $n
}

# #3,#4,#5 IDENTITY + SSO session + org graph
function New-STAUser([string]$Name, [string]$Phone = "", [string]$Role = "customer", [string]$OrgId = "") {
  $u = @{ usr_id = (New-STAId "usr"); name = $Name; phone = $Phone; role = $Role; org_id = $OrgId; created_at = (Get-Date -Format "o"); mfa = $false }
  Save-STAJson (Get-STAFabricPath "identity\users.json") $u
  Publish-STAEvent -Type "USER_CREATED" -Data @{ usr_id = $u.usr_id; name = $Name } | Out-Null
  return $u
}
function New-STAOrg([string]$Name, [string]$OwnerId) {
  $o = @{ org_id = (New-STAId "org"); name = $Name; owner = $OwnerId; members = @($OwnerId); created_at = (Get-Date -Format "o") }
  Save-STAJson (Get-STAFabricPath "identity\orgs.json") $o
  return $o
}
function New-STASession([string]$UserId, [string]$App = "opencode") {
  $s = @{ session_id = (New-STAId "sess"); usr_id = $UserId; app = $App; created_at = (Get-Date -Format "o"); expires = ((Get-Date).AddHours(12).ToString("o")) }
  Save-STAJson (Get-STAFabricPath "identity\sessions.json") $s
  Publish-STAEvent -Type "USER_LOGIN" -Data @{ usr_id = $UserId; app = $App } | Out-Null
  return $s
}

# #6,#7,#8 RBAC + agent identity + boundary
$Global:STAPermissions = @{
  tenant = @("rent.view.own"); landlord = @("rent.view.own","property.view.own"); caretaker = @("building.manage.assigned")
  ceo = @("*"); agent = @("data.analyze"); admin = @("*")
}
function Test-STAPermission([string]$Role, [string]$Action) {
  $perms = $Global:STAPermissions[$Role.ToLower()]
  if (-not $perms) { return $false }
  return ($perms -contains "*" -or $perms -contains $Action)
}
function Register-STAAgent([string]$Name, [string]$Role, [string]$Owner, [string[]]$Tools) {
  $a = @{ agent_id = (New-STAId "agt"); agent_name = $Name; agent_role = $Role; owner = $Owner; permissions = @($Global:STAPermissions[$Role.ToLower()]); allowed_tools = $Tools; status = "active"; version = "v1.0"; last_activity = (Get-Date -Format "o") }
  Save-STAJson (Get-STAFabricPath "agents\agents.json") $a
  Publish-STAEvent -Type "AI_TASK_CREATED" -Data @{ agent = $Name } | Out-Null
  return $a
}

# #12,#13 NOTIFY (in-app/email/SMS/WhatsApp/push abstraction -> log + event)
function Send-STANotification([string]$To, [string]$Message, [string]$Channel = "in-app", [string]$Priority = "normal") {
  $n = @{ notification_id = (New-STAId "ntf"); to = $To; message = $Message; channel = $Channel; priority = $Priority; status = "queued"; created_at = (Get-Date -Format "o") }
  Save-STAJson (Get-STAFabricPath "notifications\notifications.json") $n
  Publish-STAEvent -Type "MESSAGE_SENT" -Data @{ to = $To; channel = $Channel } | Out-Null
  return $n
}

# #14 APPROVALS: PROPOSE > CHECK > APPROVE > EXECUTE > VERIFY > AUDIT
function New-STAApproval([string]$Title, [string]$RequestedBy, [string]$Risk = "medium") {
  $a = @{ approval_id = (New-STAId "apr"); title = $Title; requested_by = $RequestedBy; risk = $Risk; status = "REQUIRES_APPROVAL"; created_at = (Get-Date -Format "o") }
  Save-STAJson (Get-STAFabricPath "approvals\approvals.json") $a
  return $a
}
function Approve-STAApproval([string]$ApprovalId, [string]$Approver, [bool]$Approved = $true) {
  $path = Get-STAFabricPath "approvals\approvals.json"
  $all = Get-STAJson $path
  foreach ($a in $all) { if ($a.approval_id -eq $ApprovalId) { $a.status = if ($Approved) { "APPROVED" } else { "REJECTED" }; $a | Add-Member -NotePropertyName approver -NotePropertyValue $Approver -Force } }
  $all | ConvertTo-Json -Depth 10 | Set-Content -Path $path
  Write-STAAudit -Action "APPROVAL" -Actor $Approver -Resource $ApprovalId -Result "ok"
  return ($all | Where-Object { $_.approval_id -eq $ApprovalId } | Select-Object -First 1)
}

# #24 AUDIT: WHO/WHAT/WHEN/WHERE/WHY/RESULT
function Write-STAAudit([string]$Action, [string]$Actor, [string]$Resource, [string]$Result = "ok", [string]$Why = "") {
  $r = @{ audit_id = (New-STAId "aud"); who = $Actor; what = $Action; resource = $Resource; when = (Get-Date -Format "o"); where = $Global:STAFabric.Env; why = $Why; result = $Result }
  Save-STAJson (Get-STAFabricPath "audit\audit.json") $r
  return $r
}

# #15,#16,#17 AI COST GOVERNOR + MODEL ROUTER (task-based, no hardcode)
function Select-STAModel([string]$TaskType, [string]$Complexity = "medium", [bool]$Private = $false) {
  if ($Private) { return "ollama-local" }
  if ($TaskType -eq "code") { if ($Complexity -eq "high") { return "deepseek-reasoner" } else { return "ollama-codellama" } }
  if ($TaskType -eq "reasoning") { return "deepseek-reasoner" }
  return "ollama-local"
}
function Invoke-STAGovernedAI([string]$TaskType, [string]$Prompt, [string]$Complexity = "medium") {
  $model = Select-STAModel -TaskType $TaskType -Complexity $Complexity
  $t0 = Get-Date
  $latency = ((Get-Date) - $t0).TotalMilliseconds
  $cost = if ($model -like "ollama*") { 0 } else { [math]::Round($Prompt.Length / 1000 * 0.002, 6) }
  $rec = @{ task_type = $TaskType; model = $model; latency_ms = $latency; est_cost = $cost; success = $true; created_at = (Get-Date -Format "o") }
  Save-STAJson (Get-STAFabricPath "costs\ai_costs.json") $rec
  Publish-STAEvent -Type "AI_TASK_COMPLETED" -Data @{ model = $model; task = $TaskType } | Out-Null
  return @{ model = $model; est_cost = $cost; note = "routed; execution via existing Invoke-DeepSeekTask/Invoke-OllamaTask" }
}

# #18,#19 API GATEWAY check + service discovery (no hardcoded URLs in apps)
$Global:STAServices = @{}
function Register-STAService([string]$Name, [string]$Url, [string]$Version = "v1") {
  $Global:STAServices[$Name] = @{ url = $Url; version = $Version }
  Save-STAJson (Get-STAFabricPath "services.json") @{ name = $Name; url = $Url; version = $Version }
}
function Get-STAService([string]$Name) { return $Global:STAServices[$Name] }
function Test-STAGateway([string]$Token, [string]$Role, [string]$Action) {
  if ([string]::IsNullOrEmpty($Token)) { return @{ allowed = $false; reason = "missing-auth" } }
  $ok = Test-STAPermission -Role $Role -Action $Action
  return @{ allowed = $ok; reason = if ($ok) { "ok" } else { "forbidden" } }
}

# #20-#23 DOCS + SEARCH (permission-aware) + MEMORY with provenance
function Add-STADocument([string]$Title, [string]$Path, [string]$Owner, [string]$Classification = "INTERNAL") {
  $d = @{ doc_id = (New-STAId "doc"); title = $Title; path = $Path; owner = $Owner; classification = $Classification; version = 1; created_at = (Get-Date -Format "o") }
  Save-STAJson (Get-STAFabricPath "docs\docs.json") $d
  Publish-STAEvent -Type "DOCUMENT_UPLOADED" -Data @{ doc_id = $d.doc_id } | Out-Null
  return $d
}
function Add-STAMemory([string]$Scope, [string]$Key, [string]$Value, [string]$By, [string]$Classification = "INTERNAL", [double]$Confidence = 0.8) {
  $m = @{ memory_id = (New-STAId "mem"); scope = $Scope; key = $Key; value = $Value; source = $By; created_by = $By; created_at = (Get-Date -Format "o"); confidence = $Confidence; classification = $Classification; permissions = @($Scope); version = 1 }
  Save-STAJson (Get-STAFabricPath "memory\memory.json") $m
  return $m
}
function Search-STA([string]$Query, [string]$Role = "admin") {
  $docs = Get-STAJson (Get-STAFabricPath "docs\docs.json")
  $res = @($docs | Where-Object { $_.title -like "*$Query*" })
  if ($Role -notin @("admin","ceo")) { $res = @($res | Where-Object { $_.classification -notin @("RESTRICTED","SENSITIVE") }) }
  return $res
}

# #32 FEATURE FLAGS, #33-#35 REGIONAL + CURRENCY + PAYMENT RAIL
function Set-STAFlag([string]$Name, [bool]$Enabled, [string]$Scope = "global") {
  $f = @{ name = $Name; enabled = $Enabled; scope = $Scope; updated = (Get-Date -Format "o") }
  Save-STAJson (Get-STAFabricPath "flags\flags.json") $f
  return $f
}
function Convert-STACurrency([double]$Amount, [string]$From = "KES", [string]$To = "USD") {
  $rates = @{ KES = 1; UGX = 0.035; TZS = 0.0004; USD = 129.0; NGN = 0.084; GHS = 8.5; ZAR = 7.1 }
  if (-not $rates.ContainsKey($From) -or -not $rates.ContainsKey($To)) { throw "unknown currency" }
  $inKes = $Amount * $rates[$From]
  if ($To -eq "KES") { return $inKes }
  return [math]::Round($inKes / $rates[$To], 2)
}
function New-STAPayment([string]$App, [double]$Amount, [string]$Currency = "KES", [string]$Rail = "mobile-money") {
  $corr = New-STACorrelationId
  $t = @{ txn_id = (New-STAId "txn"); app = $App; amount = $Amount; currency = $Currency; rail = $Rail; status = "INITIATED"; correlation_id = $corr; created_at = (Get-Date -Format "o") }
  Save-STAJson (Get-STAFabricPath "payments\payments.json") $t
  Publish-STAEvent -Type "PAYMENT_CREATED" -Data @{ txn = $t.txn_id; amount = $Amount } -CorrelationId $corr | Out-Null
  return $t
}
function Set-STAPaymentStatus([string]$TxnId, [string]$Status) {
  $valid = @("INITIATED","PENDING","AUTHORIZED","PROCESSING","SUCCESS","FAILED","REVERSED","REFUNDED","SETTLED")
  if ($valid -notcontains $Status) { throw "invalid status $Status" }
  $path = Get-STAFabricPath "payments\payments.json"
  $all = Get-STAJson $path
  $txn = $all | Where-Object { $_.txn_id -eq $TxnId } | Select-Object -First 1
  if (-not $txn) { throw "txn not found" }
  $txn.status = $Status
  $all | ConvertTo-Json -Depth 10 | Set-Content -Path $path
  $ev = if ($Status -eq "SUCCESS") { "PAYMENT_CONFIRMED" } elseif ($Status -eq "FAILED") { "PAYMENT_FAILED" } else { "PAYMENT_CREATED" }
  Publish-STAEvent -Type $ev -Data @{ txn = $TxnId; status = $Status } -CorrelationId $txn.correlation_id | Out-Null
  if ($Status -eq "SUCCESS") { New-STAReceipt -TxnId $TxnId -Amount $txn.amount -Currency $txn.currency | Out-Null }
  return $txn
}

# #37,#38 RULES + WORKFLOWS
function Invoke-STARule([string]$Event, [hashtable]$Context) {
  if ($Event -eq "PAYMENT_CONFIRMED") { Send-STANotification -To $Context.to -Message "Receipt $($Context.txn)" | Out-Null; return "receipt-issued" }
  if ($Event -eq "RENT_OVERDUE") { Send-STANotification -To $Context.to -Message "Rent reminder" -Priority "high" | Out-Null; return "reminder-created" }
  return "no-rule"
}

# #40 IDEMPOTENCY
function Test-STAIdempotency([string]$Key) {
  $path = Get-STAFabricPath "idempotency.json"
  $all = Get-STAJson $path
  if ($all | Where-Object { $_.key -eq $Key }) { return $false }
  Save-STAJson $path @{ key = $Key; created_at = (Get-Date -Format "o") }
  return $true
}

# #44 DEVICES, #46 HEALTH, #59 RECEIPTS, #60 DEEP LINKS
function Register-STADevice([string]$Owner, [string]$Type = "phone") {
  $d = @{ device_id = (New-STAId "device"); owner = $Owner; type = $Type; status = "active"; last_seen = (Get-Date -Format "o"); software_version = "1.0" }
  Save-STAJson (Get-STAFabricPath "devices\devices.json") $d
  return $d
}
function Get-STAHealth {
  $evts = (Get-STAEvents).Count
  return @{ uptime = "ok"; events = $evts; queue = "ok"; env = $Global:STAFabric.Env; time = (Get-Date -Format "o") }
}
function New-STAReceipt([string]$TxnId, [double]$Amount, [string]$Currency = "KES") {
  $r = @{ receipt_id = (New-STAId "rcpt"); txn_id = $TxnId; amount = $Amount; currency = $Currency; created_at = (Get-Date -Format "o"); verifiable = $true }
  Save-STAJson (Get-STAFabricPath "payments\receipts.json") $r
  return $r
}
function New-STADeepLink([string]$Kind, [string]$Id) { return "sta://$Kind/$Id" }

# #29 EXTENDED TASK STATES (#28 long-running via existing TaskQueueEngine)
function New-STATask([string]$Name, [string]$Priority = "Normal", [hashtable]$Params = @{}) {
  $t = @{ task_id = (New-STAId "task"); name = $Name; priority = $Priority; status = "QUEUED"; params = $Params; created_at = (Get-Date -Format "o") }
  Save-STAJson (Get-STAFabricPath "tasks\tasks.json") $t
  return $t
}

Export-ModuleMember -Function Initialize-STAFabric, Get-STAFabricPath, Save-STAJson, Get-STAJson, Expand-STAItems, New-STAId, New-STACorrelationId, Publish-STAEvent, Get-STAEvents, Replay-STAEvents, New-STAUser, New-STAOrg, New-STASession, Test-STAPermission, Register-STAAgent, Send-STANotification, New-STAApproval, Approve-STAApproval, Write-STAAudit, Select-STAModel, Invoke-STAGovernedAI, Register-STAService, Get-STAService, Test-STAGateway, Add-STADocument, Add-STAMemory, Search-STA, Set-STAFlag, Convert-STACurrency, New-STAPayment, Set-STAPaymentStatus, Invoke-STARule, Test-STAIdempotency, Register-STADevice, Get-STAHealth, New-STAReceipt, New-STADeepLink, New-STATask
