# DONE OpenCode STA Intelligence OS integration.

{
  "$schema": "https://opencode.ai/config.json",
  "username": "Robin Bina Mwarema Donald",
  "default_agent": "orchestrator",
  "shell": "powershell",
  "logLevel": "INFO",
  "share": "manual",
  "autoupdate": "notify",
  "instructions": [
    "AGENTS.md",
    "SOUL.md",
    "TOOLS.md",
    "IDENTITY.md",
    "USER.md",
    "SCHEDULE.md",
    "HEARTBEAT.md"
  ],
  "agent": {
    "orchestrator": {
      "description": "STA Intelligence OS Orchestrator - connects all agents, apps, infrastructure, data, businesses, developers & African operating conditions as one connected ecosystem",
      "mode": "subagent",
      "color": "rainbow",
      "permission": {
        "read": "allow",
        "edit": { "*": "ask", "*.md": "allow", "*.ps1": "allow", "*.py": "allow", "*.json": "allow", "*.yaml": "allow", "*.yml": "allow" },
        "bash": { "git *": "allow", "opencode *": "allow", "powershell *": "allow", "ollama *": "allow", "docker *": "allow", "kubectl *": "allow", "*": "ask" },
        "webfetch": "allow",
        "websearch": "allow",
        "todowrite": "allow",
        "skill": "allow",
        "task": "allow"
      }
    },
    "build": {
      "description": "STA Engineering Agent - code, files, architecture, debugging, tests, implementation",
      "mode": "subagent",
      "color": "accent",
      "permission": {
        "read": "allow",
        "edit": { "*": "ask", "*.py": "allow", "*.js": "allow", "*.ts": "allow", "*.tsx": "allow", "*.md": "allow", "*.json": "allow", "*.yaml": "allow", "*.yml": "allow", "*.ps1": "allow", "*.sh": "allow" },
        "bash": { "git *": "allow", "npm *": "allow", "pnpm *": "allow", "python *": "allow", "pytest *": "allow", "docker *": "allow", "*": "ask" },
        "webfetch": "allow",
        "websearch": "allow"
      }
    },
    "ops": {
      "description": "STA Operations Agent - scheduling, monitoring, health checks, deployments, automation",
      "mode": "subagent",
      "color": "warning",
      "permission": {
        "read": "allow",
        "edit": { "*": "ask", "*.md": "allow", "*.ps1": "allow", "*.yaml": "allow", "*.yml": "allow" },
        "bash": { "powershell *": "allow", "git *": "allow", "kubectl *": "allow", "docker *": "allow", "az *": "allow", "*": "ask" },
        "webfetch": "allow",
        "websearch": "allow"
      }
    },
    "triage": {
      "description": "STA Triage Agent - GitHub issue/PR triage, event automation debugging, incident classification",
      "mode": "subagent",
      "color": "error",
      "permission": {
        "read": "allow",
        "edit": "deny",
        "bash": "ask",
        "webfetch": "allow",
        "websearch": "allow"
      }
    },
    "deploy": {
      "description": "STA Deployment Agent - app deploys, Supabase functions, GitHub Pages, infrastructure",
      "mode": "subagent",
      "color": "success",
      "permission": {
        "read": "allow",
        "edit": { "*.md": "allow", "*": "ask" },
        "bash": { "git *": "allow", "powershell * -File deploy*": "allow", "*": "ask" }
      }
    },
    "plan": {
      "description": "STA Planning Agent - design, architecture review, task breakdown, strategy simulation",
      "mode": "subagent",
      "color": "info",
      "permission": {
        "read": "allow",
        "edit": { "*.md": "allow", "*.py": "allow", "*": "ask" },
        "bash": { "git *": "allow", "*": "ask" },
        "webfetch": "allow",
        "websearch": "allow"
      }
    },
    "explore": {
      "description": "STA Exploration Agent - codebase search, file discovery, pattern matching, research",
      "mode": "subagent",
      "color": "secondary",
      "permission": {
        "read": "allow",
        "edit": "deny",
        "bash": "ask",
        "webfetch": "allow",
        "websearch": "allow"
      }
    },
    "general": {
      "description": "STA General Agent - multi-step tasks, research, complex queries, cross-domain coordination",
      "mode": "subagent",
      "color": "default",
      "permission": {
        "read": "allow",
        "edit": { "*": "ask", "*.md": "allow" },
        "bash": { "git *": "allow", "*": "ask" },
        "webfetch": "allow",
        "websearch": "allow"
      }
    },
    "sta-coder": {
      "description": "STA-Coder - specialized coding agent with full STA Intelligence OS integration",
      "mode": "subagent",
      "color": "accent",
      "permission": {
        "read": "allow",
        "edit": { "*.py": "allow", "*.js": "allow", "*.ts": "allow", "*.tsx": "allow", "*.md": "allow", "*.json": "allow", "*": "ask" },
        "bash": { "git *": "allow", "npm *": "allow", "pnpm *": "allow", "python *": "allow", "pytest *": "allow", "docker *": "allow", "*": "ask" },
        "webfetch": "allow",
        "websearch": "allow"
      }
    },
    "sta-architect": {
      "description": "STA-Architect - system architecture, service boundaries, scalability, interoperability",
      "mode": "subagent",
      "color": "info",
      "permission": {
        "read": "allow",
        "edit": { "*.md": "allow", "*.py": "allow", "*.yaml": "allow", "*.yml": "allow", "*": "ask" },
        "bash": { "git *": "allow", "*": "ask" },
        "webfetch": "allow",
        "websearch": "allow"
      }
    },
    "sta-finance": {
      "description": "STA-Finance - financial modeling, cost optimization, ROI analysis, payment systems",
      "mode": "subagent",
      "color": "success",
      "permission": {
        "read": "allow",
        "edit": { "*.md": "allow", "*.py": "allow", "*.json": "allow", "*": "ask" },
        "bash": { "git *": "allow", "python *": "allow", "*": "ask" },
        "webfetch": "allow",
        "websearch": "allow"
      }
    },
    "sta-security": {
      "description": "STA-Security - security auditing, vulnerability assessment, zero-trust, policy-as-code",
      "mode": "subagent",
      "color": "error",
      "permission": {
        "read": "allow",
        "edit": "deny",
        "bash": { "git *": "allow", "python *": "allow", "*": "ask" },
        "webfetch": "allow",
        "websearch": "allow"
      }
    },
    "sta-devops": {
      "description": "STA-DevOps - CI/CD, GitHub, Docker, Kubernetes, deployment, observability",
      "mode": "subagent",
      "color": "warning",
      "permission": {
        "read": "allow",
        "edit": { "*.yaml": "allow", "*.yml": "allow", "*.md": "allow", "*.ps1": "allow", "*": "ask" },
        "bash": { "git *": "allow", "docker *": "allow", "kubectl *": "allow", "az *": "allow", "terraform *": "allow", "*": "ask" },
        "webfetch": "allow",
        "websearch": "allow"
      }
    },
    "sta-data": {
      "description": "STA-Data - data engineering, pipelines, analytics, Supabase, PostgreSQL, RAG",
      "mode": "subagent",
      "color": "secondary",
      "permission": {
        "read": "allow",
        "edit": { "*.py": "allow", "*.sql": "allow", "*.md": "allow", "*": "ask" },
        "bash": { "git *": "allow", "python *": "allow", "psql *": "allow", "*": "ask" },
        "webfetch": "allow",
        "websearch": "allow"
      }
    },
    "sta-research": {
      "description": "STA-Research - deep research, competitive intelligence, innovation radar, market analysis",
      "mode": "subagent",
      "color": "info",
      "permission": {
        "read": "allow",
        "edit": { "*.md": "allow", "*.py": "allow", "*": "ask" },
        "bash": { "git *": "allow", "python *": "allow", "*": "ask" },
        "webfetch": "allow",
        "websearch": "allow"
      }
    },
    "sta-africa-markets": {
      "description": "STA-AfricaMarkets - African market intelligence, localization, payments, regulations",
      "mode": "subagent",
      "color": "accent",
      "permission": {
        "read": "allow",
        "edit": { "*.md": "allow", "*.py": "allow", "*.json": "allow", "*": "ask" },
        "bash": { "git *": "allow", "python *": "allow", "*": "ask" },
        "webfetch": "allow",
        "websearch": "allow"
      }
    }
  },
  "skills": {
    "paths": [
      ".opencode/skills",
      ".opencode/skills/orchestration",
      ".opencode/skills/intelligence-os"
    ]
  },
  "memory": {
    "path": "memory",
    "description": "STA Intelligence OS Memory Layers L0-L4: L0=Core Identity, L1=Project, L2=Operational, L3=Knowledge, L4=Reflection"
  },
  "mcp": {
    "fetch": {
      "type": "local",
      "command": ["uvx", "mcp-server-fetch@0.8.0"],
      "enabled": true
    },
    "github": {
      "type": "remote",
      "url": "https://api.github.com/mcp",
      "enabled": true,
      "headers": {
        "Authorization": "Bearer {env:GITHUB_TOKEN}"
      },
      "timeout": 15000
    },
    "supabase": {
      "type": "remote",
      "url": "https://spnerrqumefbuuscumhw.supabase.co/mcp",
      "enabled": true,
      "headers": {
        "Authorization": "Bearer {env:SUPABASE_SERVICE_ROLE_KEY}"
      },
      "timeout": 15000
    },
    "ollama": {
      "type": "local",
      "command": ["ollama", "serve"],
      "enabled": true,
      "timeout": 30000
    }
  },
  "permission": {
    "read": "allow",
    "edit": "ask",
    "glob": "allow",
    "grep": "allow",
    "list": "allow",
    "bash": {
      "git status*": "allow",
      "git log*": "allow",
      "git diff*": "allow",
      "powershell Get-*": "allow",
      "powershell Test-*": "allow",
      "*": "ask"
    },
    "external_directory": {
      "~/OneDrive/Documents/Default Project/*": "allow",
      "~/.openclaw/*": "allow",
      "*": "deny"
    },
    "webfetch": "allow",
    "websearch": "allow",
    "todowrite": "allow",
    "skill": "allow",
    "task": "allow",
    "question": "allow"
  },
  "tool_output": {
    "max_lines": 500,
    "max_bytes": 16384
  },
  "compaction": {
    "auto": true,
    "tail_turns": 30
  },
  "experimental": {
    "mcp_timeout": 30000,
    "agent_spawn_timeout": 60000,
    "max_concurrent_agents": 5
  },
  "sta_intelligence_os": {
    "version": "1.0.0",
    "core_priorities": [
      "STA Intelligence Graph",
      "STA Agent Orchestrator + Agent Passport",
      "STA Truth + Evidence Engine",
      "STA Digital Sovereignty + Offline/Edge Fabric",
      "STA Composable Application Economy"
    ],
    "architecture_layers": {
      "experience": ["Web", "Mobile", "API", "UI", "Voice", "USSD", "SMS"],
      "agents": ["STA-Coder", "STA-Architect", "STA-Finance", "STA-Legal", "STA-Security", "STA-DevOps", "STA-Data", "STA-Research", "STA-Marketing", "STA-Sales", "STA-CustomerCare", "STA-AfricaMarkets", "STA-Payments", "STA-Property", "STA-Energy", "STA-Education", "STA-Health"],
      "orchestrator": "STA Agent Orchestrator",
      "intelligence_core": ["Noesis Knowledge", "SAICOS Automation", "STA_FOLKED Capabilities"],
      "core_services": ["Truth Engine", "Memory", "Graph", "Reasoning", "Prediction", "Causality", "Simulation"],
      "fabric": ["AI Model Gateway", "Data Fabric", "Trust Fabric", "Identity Fabric", "Event Fabric", "Consent Engine"],
      "infrastructure": ["Cloud", "Edge", "Local", "Devices", "Kubernetes", "Community Compute"],
      "economy": ["African Digital Economy", "Payments", "SMEs", "Government", "Education", "Energy", "Property", "Commerce"]
    },
    "autonomy_levels": {
      "L0": "Observe",
      "L1": "Recommend",
      "L2": "Draft",
      "L3": "Execute with approval",
      "L4": "Execute within policy",
      "L5": "Autonomous"
    },
    "agent_dna_fields": [
      "AgentID", "Version", "Purpose", "Capabilities", "Tools", "Permissions", "Memory", "Model", "Cost", "Reliability", "SecurityLevel", "Owner", "Dependencies", "KnownFailures", "Performance"
    ],
    "digital_twin_domains": [
      "People", "Developers", "Customers", "Applications", "APIs", "Agents", "Repositories", "Databases", "Servers", "Cloud", "Devices", "Payments", "Infrastructure", "Businesses", "Locations", "Dependencies"
    ],
    "event_types": [
      "USER_CREATED", "PAYMENT_RECEIVED", "AGENT_ACTIVATED", "CODE_CHANGED", "DEPLOYMENT_STARTED", "DEPLOYMENT_FAILED", "SECURITY_ALERT", "MODEL_CHANGED", "DATABASE_MIGRATION", "CUSTOMER_SIGNUP", "AGENT_DECISION", "CAPABILITY_NEGOTIATED", "TRUTH_CLASSIFIED", "EVIDENCE_RECORDED", "JUDGE_RULING", "AUTONOMY_CHANGED", "ROLLBACK_TRIGGERED", "SIMULATION_COMPLETED", "PREDICTION_GENERATED", "CAUSALITY_ANALYZED"
    ],
    "model_gateway": {
      "local_models": ["qwen3:8b", "gemma3:4b", "llama3.2:3b"],
      "cloud_models": ["deepseek", "claude", "gpt-4", "gemini"],
      "specialized": {
        "coding": "qwen3:8b",
        "reasoning": "deepseek",
        "research": "claude",
        "security": "gemma3:4b",
        "analysis": "llama3.2:3b"
      },
      "fallback_chain": ["local", "ollama", "deepseek", "claude", "static"]
    },
    "africa_first": {
      "offline_first": true,
      "mobile_first": true,
      "payment_plurality": ["M-Pesa", "MoMo", "Airtel Money", "Card", "Bank Transfer", "USSD"],
      "languages": ["en", "sw", "am", "yo", "ig", "ha", "zu", "xh", "af", "fr", "pt", "ar"],
      "currencies": ["KES", "UGX", "TZS", "RWF", "GHS", "NGN", "ZAR", "XAF", "XOF", "USD", "EUR"],
      "connectivity": ["4G", "3G", "2G", "WiFi", "Satellite", "Offline"],
      "devices": ["Android Go", "Feature Phone", "Smartphone", "Tablet", "Laptop", "IoT"],
      "power": ["Grid", "Solar", "Battery", "Generator", "Unreliable"]
    },
    "composable_primitives": [
      "STA Identity", "STA Payments", "STA AI", "STA Notifications", "STA Search", "STA Maps", "STA Analytics", "STA Trust", "STA Wallet", "STA Messaging", "STA Documents", "STA Billing", "STA Audit", "STA Marketplace"
    ],
    "applications": [
      "Mwarokin Estates", "SylloPay", "SylloVibe", "STA Platform", "Mali Access Union", "STA Financial Advisory", "SAICOS", "Noesis"
    ]
  }
}