# ============================================================
# QUICK START COMMANDS - Copy and Paste
# ============================================================
# SyllogismTechnologyAfrica | CEO: Robin Mwarema
# WhatsApp: +254704919388 | GitHub: 99DevOps892
# ============================================================

# --- DEPLOYMENT ---
# Run as Administrator:
# .\Deploy-STAG.ps1 -Mode production

# --- MODULE IMPORT ---
Import-Module SyllogismAgentEngine

# --- START SYSTEM ---
Start-AIAgentEngine
# OR
start-engine

# --- QUICK COMMANDS ---
# Check system status:
engine-status | Format-List

# Send CEO status update via WhatsApp:
status-msg

# Process all queued tasks:
process-queue

# Retry failed tasks:
retry-tasks

# CEO command:
ceo-cmd -Command "Review all GitHub repositories"

# Run all systems:
Invoke-AgenticTask -Task "all"

# Live dashboard:
dashboard

# System test:
system-test

# Backup:
backup

# Audit report:
audit

# --- ONE-LINE DEPLOY & START ---
# .\Deploy-STAG.ps1 -Mode production -Force; Import-Module SyllogismAgentEngine; Start-AIAgentEngine

# --- OPENCLAW MOBILE SETUP ---
Initialize-OpenClawGateway
# Generates QR code for mobile pairing

# --- WHATSAPP TEST ---
Send-WhatsAppMessage -Message "System operational - CEO Pipeline Active" -To "+254704919388"

# --- GITHUB TEST ---
Connect-GitHubRealTime -GitHubToken $env:GITHUB_TOKEN

# --- DEEPSEEK TEST ---
Connect-DeepSeekAgent -SessionId "agent:main:main"

# --- OLLAMA TEST ---
Connect-OllamaEngine

# --- OPENCODE ORCHESTRATOR TEST ---
Connect-OpenCodeOrchestrator

# --- INTEGRATION TEST ---
Invoke-AgenticTask -Task "all"

# --- CHECK SYSTEM INTEGRITY ---
Test-SystemIntegrity

# --- GET SYSTEM REPORT ---
Get-SystemReport | ConvertTo-Json -Depth 10 | Set-Content "$env:USERPROFILE\Desktop\system_report.json"
