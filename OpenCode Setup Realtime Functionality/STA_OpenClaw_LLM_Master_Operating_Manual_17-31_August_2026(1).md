# Syllogism Technology Africa — OpenClaw + LLM Autonomous Operating System
## Master Agent Operating Manual | 17–31 August 2026

> **Purpose:** This document is the master execution contract for OpenClaw, local/cloud LLMs, AI agents, automation workers, CI/CD, and human operators supporting Syllogism Technology Africa (STA).
>
> **Primary objective:** Convert the 17–31 August 2026 STA sprint into a controlled, testable, secure production foundation rather than attempting to finish every feature simultaneously.

---

## 1. COMMAND PRINCIPLES

### 1.1 Core operating loop

Every task MUST follow:

```text
INTAKE
  ↓
CLASSIFY
  ↓
PLAN
  ↓
EXECUTE
  ↓
TEST
  ↓
REVIEW
  ↓
SECURITY
  ↓
APPROVAL
  ↓
DEPLOY
  ↓
MONITOR
  ↓
DOCUMENT
  ↓
LEARN
```

### 1.2 Non-negotiable rules

1. Never expose secrets, API keys, passwords, private tokens, banking credentials, signing keys, or production connection strings.
2. Never hard-code secrets into source code.
3. Never deploy financial, banking, security-sensitive, destructive, or production infrastructure changes autonomously.
4. Never bypass authentication, authorization, RLS, approval gates, branch protection, CI checks, or audit logging.
5. Never test third-party production systems without explicit authorization.
6. Prefer sandbox/test environments for payment and banking integrations.
7. Every database change requires a migration.
8. Every production change requires rollback planning.
9. Every autonomous task must leave an auditable trail.
10. If requirements are ambiguous, stop and request clarification rather than inventing business rules.
11. AI-generated code is untrusted until reviewed and tested.
12. Production credentials are never copied into local prompts, chat logs, Git repositories, or generated documentation.
13. Data minimization and least privilege are mandatory.
14. Preserve existing working functionality unless the task explicitly authorizes a breaking change.
15. Optimize for reliability and maintainability before novelty.

---

# 2. HUMAN + AI RESPONSIBILITY MODEL

## CEO / Human Owner

Human authority is required for:

- Architecture decisions with material business impact
- Banking configuration
- Production payment activation
- Legal/compliance decisions
- Domain ownership
- Subscription pricing approval
- Financial settlement rules
- Production secrets
- Destructive migrations
- External security testing authorization
- Production deployment of sensitive systems

The AI may recommend, prepare, test, compare, document, and stage these changes.

It does not become the final authority.

---

# 3. AI AGENT HIERARCHY

```text
                         CEO / HUMAN OWNER
                                │
                         GOVERNANCE AGENT
                                │
                       OPENCLAW ORCHESTRATOR
                                │
              ┌─────────────────┼─────────────────┐
              │                 │                 │
          PLANNER            REVIEWER          MEMORY
              │                 │                 │
     ┌────────┼────────┬────────┼────────┬────────┐
     │        │        │        │        │        │
   CODER   DATABASE     UI   SECURITY   DEVOPS    QA
     │        │        │        │        │        │
     └────────┴────────┴────────┴────────┴────────┘
                                │
                           CI/CD GATES
                                │
                       STAGING / PREVIEW
                                │
                         HUMAN APPROVAL
                                │
                           PRODUCTION
                                │
                        OBSERVABILITY
```

---

# 4. AGENT CONTRACT

Every agent must operate with:

```yaml
agent:
  name:
  role:
  objective:
  allowed_tools:
  forbidden_actions:
  input_schema:
  output_schema:
  approval_required:
  risk_level:
  timeout:
  retry_policy:
  audit_required:
  rollback_strategy:
```

Each agent must report:

```yaml
task:
status:
summary:
files_changed:
database_changes:
tests_run:
security_checks:
risks:
blockers:
approval_required:
next_action:
rollback:
```

---

# 5. AGENT ROLES

## 5.1 Planner Agent

Responsibilities:

- Convert objectives into executable tasks.
- Break large work into atomic units.
- Identify dependencies.
- Assign agents.
- Estimate complexity.
- Identify risks.
- Produce acceptance criteria.

Never:

- Modify production directly.
- Invent missing requirements.
- Skip security review.

---

## 5.2 Coder Agent

Responsibilities:

- Implement approved tasks.
- Follow repository conventions.
- Write tests.
- Refactor safely.
- Update documentation.
- Produce small reviewable commits.

Required before completion:

```text
Build
Lint
Typecheck
Unit Tests
Integration Tests where applicable
Security checks
Diff review
```

---

## 5.3 Database Agent

Responsibilities:

- PostgreSQL schema.
- Supabase migrations.
- Constraints.
- Foreign keys.
- Indexes.
- RLS.
- Seed/test data.
- Backup verification.
- Query optimization.

Never:

- Drop production tables without explicit authorization.
- Disable RLS merely to make a feature work.
- Modify production data without an auditable migration/job.

---

## 5.4 UI Agent

Responsibilities:

- Web interfaces.
- Responsive design.
- Accessibility.
- Mobile layouts.
- Dashboards.
- Forms.
- Error states.
- Loading states.
- Offline/PWA behavior where supported.

Acceptance:

```text
Desktop
Tablet
Mobile
Keyboard navigation
Accessible labels
Error handling
Loading states
Empty states
Offline behavior
```

---

## 5.5 Security Agent

Responsibilities:

- Threat modeling.
- Dependency scanning.
- Secret scanning.
- SAST.
- DAST in authorized environments.
- Authentication review.
- Authorization review.
- Rate limiting.
- CORS.
- CSRF.
- XSS.
- SQL/NoSQL injection defenses.
- API abuse controls.
- Security headers.

Never perform unauthorized testing.

---

## 5.6 DevOps Agent

Responsibilities:

- GitHub Actions.
- CI/CD.
- Podman.
- Containers.
- Nginx.
- VPS.
- Cloud infrastructure.
- Backups.
- Monitoring.
- Health checks.
- Rollbacks.
- Git mirrors.

---

## 5.7 QA Agent

Responsibilities:

- Unit tests.
- Integration tests.
- End-to-end tests.
- Regression tests.
- API tests.
- Payment sandbox tests.
- Device compatibility.
- Performance checks.
- Release validation.

---

## 5.8 Reviewer Agent

Responsibilities:

- Review code.
- Compare implementation against requirements.
- Detect hidden regressions.
- Review architecture.
- Review tests.
- Review security findings.

Output:

```text
APPROVE
REQUEST_CHANGES
BLOCK
```

---

# 6. LLM ROUTING STRATEGY

Use multiple LLMs as a coordinated fleet rather than allowing every model to perform every task.

```text
                     LLM ROUTER
                         │
        ┌────────────────┼────────────────┐
        │                │                │
   LOCAL MODELS      CLOUD MODELS      SPECIALISTS
        │                │                │
   Low-cost work     Complex work      Review/security
        │                │                │
        └────────────────┼────────────────┘
                         │
                    OpenClaw
```

## Local LLMs

Prefer local models for:

- Repository indexing.
- Documentation.
- Simple refactoring.
- Test generation.
- Code explanation.
- Classification.
- Repetitive transformations.
- Private source analysis.

## Cloud LLMs

Use cloud models for:

- Complex architecture.
- Difficult debugging.
- Large reasoning tasks.
- High-quality code review.
- Cross-system planning.

## Cost Governor

Every AI task should be evaluated:

```text
Task
 ↓
Complexity
 ↓
Privacy
 ↓
Latency
 ↓
Cost
 ↓
Model selection
```

---

# 7. AI COST GOVERNOR

Maintain:

```text
Provider
Model
Task
Tokens
Requests
Latency
Cost
Project
Agent
Success Rate
ROI
```

Rules:

- Use the cheapest model that reliably completes the task.
- Escalate only when quality requires it.
- Cache reusable outputs.
- Avoid repeated context transmission.
- Stop runaway loops.
- Set task-level budgets.
- Set daily and monthly budgets.
- Alert on abnormal usage.
- Require approval before changing annual subscriptions materially.

---

# 8. MEMORY ARCHITECTURE

Use layered memory:

```text
┌──────────────────────────────┐
│ CEO Decisions / Governance   │
├──────────────────────────────┤
│ Architecture Memory          │
├──────────────────────────────┤
│ Project Memory               │
├──────────────────────────────┤
│ Repository Memory            │
├──────────────────────────────┤
│ Task Memory                  │
├──────────────────────────────┤
│ Temporary Context            │
└──────────────────────────────┘
```

Memory must distinguish:

- Confirmed facts
- Decisions
- Assumptions
- Open questions
- Rejected approaches
- Technical debt
- Known failures

Never treat an AI assumption as an authoritative business fact.

---

# 9. REPOSITORY OPERATING STANDARD

Recommended structure:

```text
sta/
├── apps/
│   ├── mwarokin/
│   ├── mali-access/
│   ├── syllopay/
│   ├── saicos/
│   └── noesis/
├── services/
│   ├── payments/
│   ├── banking/
│   ├── notifications/
│   ├── identity/
│   └── analytics/
├── agents/
│   ├── planner/
│   ├── coder/
│   ├── database/
│   ├── ui/
│   ├── security/
│   ├── devops/
│   └── qa/
├── packages/
├── database/
│   ├── migrations/
│   ├── seeds/
│   └── tests/
├── infrastructure/
│   ├── podman/
│   ├── nginx/
│   ├── monitoring/
│   └── deployment/
├── docs/
├── security/
├── scripts/
├── tests/
└── .github/
    └── workflows/
```

---

# 10. GIT WORKFLOW

Default:

```text
main
  ↑
release/*
  ↑
develop
  ↑
feature/*
```

For every task:

```text
Create branch
 ↓
Implement
 ↓
Test
 ↓
Commit
 ↓
Push
 ↓
CI
 ↓
Review
 ↓
Merge
```

Commit style:

```text
feat:
fix:
refactor:
test:
docs:
security:
infra:
database:
chore:
```

Never commit:

```text
.env
private keys
certificates
tokens
passwords
production dumps
customer secrets
bank credentials
```

---

# 11. GITHUB ACTIONS GATES

Every pull request should aim to run:

```text
Install
 ↓
Lint
 ↓
Typecheck
 ↓
Unit tests
 ↓
Integration tests
 ↓
Security scan
 ↓
Build
 ↓
Artifact validation
 ↓
Deploy preview
```

Production:

```text
PR
 ↓
Review
 ↓
CI
 ↓
Security
 ↓
Staging
 ↓
Smoke tests
 ↓
Human approval
 ↓
Production
```

---

# 12. SUPABASE STANDARD

Primary backend responsibilities:

- PostgreSQL.
- Authentication.
- RLS.
- Storage.
- Realtime.
- Database functions where appropriate.
- Migrations.
- Observability.

Property hierarchy:

```text
Property
 ↓
Building
 ↓
Unit
 ↓
Tenant
 ↓
Lease
 ↓
Billing
 ↓
Payment
 ↓
Finance
```

Required database principles:

- Foreign keys.
- Unique constraints.
- Check constraints.
- Appropriate indexes.
- Timestamps.
- Audit fields.
- Soft-delete where appropriate.
- RLS.
- Migration history.

---

# 13. STORAGE STANDARD

Use a controlled abstraction:

```text
Application
 ↓
Storage Service
 ↓
Supabase Storage / S3
 ↓
Metadata Database
```

Never store large files directly in relational tables unless there is a deliberate reason.

Document metadata should include:

```text
document_id
owner_id
property_id
tenant_id
document_type
storage_provider
object_key
mime_type
size
checksum
created_at
updated_at
retention_policy
```

---

# 14. PAYMENT ENGINE

Payment architecture:

```text
Client
 ↓
Authenticated API
 ↓
Payment Service
 ↓
Gateway Adapter
 ├── M-Pesa
 ├── PesaPal
 ├── Airtel Money
 ├── Stripe
 └── Bank
 ↓
Webhook
 ↓
Verification
 ↓
Idempotency
 ↓
Transaction Ledger
 ↓
Reconciliation
 ↓
Notification
```

## Required controls

- Server-side validation.
- Signature verification where supported.
- Idempotency keys.
- Replay protection.
- Transaction state machine.
- Audit logs.
- Retry policy.
- Timeout handling.
- Duplicate detection.
- Reconciliation.

Example state machine:

```text
CREATED
 ↓
INITIATED
 ↓
PENDING
 ├── SUCCESS
 ├── FAILED
 ├── CANCELLED
 └── EXPIRED
```

Never mark a transaction successful solely because a browser says it succeeded.

---

# 15. MWAROKIN + MALI ACCESS

## Mwarokin

Support:

- Property management.
- Tenant management.
- Rent.
- Leasing.
- Storage.
- Local tourism/Airbnb workflows.
- Landlord self-management.
- Caretaker management.
- Agreements.
- Commission processing.
- Analytics.

## Mali Access Union

Support:

- Members.
- Subscriptions.
- Payments.
- Notifications.
- Financial activity.
- Member communication.

## Transaction fee engine

Support configurable:

```text
KSh 1
KSh 2
KSh 3
KSh 4
KSh 5
```

Pricing must be configuration-driven, not hard-coded.

Tenant-count subscription tiers must also be configuration-driven.

---

# 16. BANKING + CASH FLOW

Build a financial ledger rather than simply displaying bank transactions.

```text
Transaction
 ↓
Validation
 ↓
Classification
 ↓
Ledger
 ↓
Reconciliation
 ↓
Settlement
 ↓
Reporting
```

Maintain:

- Revenue.
- Expenses.
- Receivables.
- Payables.
- Payment settlements.
- Bank reconciliation.
- Fees.
- Commissions.
- Refunds.
- Failed transactions.

Actual bank credentials remain in secure infrastructure.

---

# 17. NOTIFICATIONS

Notification abstraction:

```text
Notification Service
 ├── Email
 ├── SMS
 ├── Push
 ├── WhatsApp where authorized
 └── In-app
```

Use templates and event-driven notifications.

Events:

```text
PAYMENT_RECEIVED
PAYMENT_FAILED
RENT_DUE
RENT_OVERDUE
SUBSCRIPTION_CREATED
SUBSCRIPTION_EXPIRING
SECURITY_ALERT
SYSTEM_FAILURE
```

---

# 18. SECURITY BASELINE

Required controls:

- Authentication.
- Authorization.
- RBAC.
- RLS.
- Input validation.
- Output encoding.
- Rate limiting.
- CORS policy.
- CSRF controls where applicable.
- XSS protection.
- SQL injection protection.
- NoSQL injection protection.
- Secure headers.
- TLS.
- Secret management.
- Dependency scanning.
- Container scanning.
- SAST.
- DAST in authorized environments.
- Audit logging.

---

# 19. OBSERVABILITY

Every production service should expose:

```text
Health
Readiness
Latency
Errors
Throughput
Resource usage
Dependencies
```

Observability stack may include:

```text
Application
 ↓
Structured Logs
 ↓
Metrics
 ↓
Traces
 ↓
Prometheus / Datadog / compatible systems
 ↓
Alerts
 ↓
Incident response
```

Minimum alerts:

- API unavailable.
- Database unavailable.
- Payment failure spike.
- Authentication failure spike.
- Queue backlog.
- High latency.
- Disk exhaustion.
- CPU/memory saturation.
- Backup failure.
- Certificate expiry.
- Unusual security events.

---

# 20. CDN + NETWORK

Target architecture:

```text
User
 ↓
DNS
 ↓
CDN
 ↓
WAF
 ↓
Reverse Proxy
 ↓
Application
 ↓
API
 ↓
Database / Object Storage
```

Possible CDN providers:

- Cloudflare.
- Akamai.
- Fastly.
- Google Cloud CDN.

Do not activate multiple CDNs in production merely for complexity. Introduce multi-CDN/failover only when there is a measurable requirement.

---

# 21. SERVERS + DECENTRALIZATION

Support multiple deployment classes:

```text
LOCAL SSD/CPU
      ↓
PRIVATE SERVER
      ↓
VPS
      ↓
CLOUD
      ↓
DECENTRALIZED NODE
```

Use private networking for administrative services.

Potential components:

- Podman.
- Nginx.
- Hostinger VPS.
- Tailscale.
- Twingate.
- Cloud infrastructure.

Decentralization must not mean uncontrolled replication of sensitive data.

Define:

```text
What data?
Where replicated?
Why?
Encrypted?
Retention?
Who can access?
How revoked?
How restored?
```

---

# 22. BACKUP + DISASTER RECOVERY

Use the principle:

```text
3 copies
2 storage types
1 geographically separate copy
```

Back up:

- Database.
- Object storage metadata.
- Critical configuration.
- Infrastructure definitions.
- Deployment manifests.
- Documentation.

Test restoration, not merely backup creation.

Required test:

```text
Backup
 ↓
Restore
 ↓
Validate
 ↓
Application test
 ↓
Record result
```

---

# 23. GIT MIRROR STRATEGY

Primary:

```text
GitHub
```

Mirrors:

```text
GitLab
Bitbucket
Local repository
Authorized backup server
```

Mirror automation must:

- Preserve history.
- Preserve tags.
- Detect divergence.
- Alert on failure.
- Avoid accidental overwrite.
- Never copy secrets.

---

# 24. SAFE PROOF CYBER RANGE

All security experimentation must use:

- STA-owned systems.
- Dedicated test systems.
- Explicitly authorized third-party systems.
- Simulated government/bank/telecom/power-grid environments.

Architecture:

```text
Cyber Range
 ├── API simulator
 ├── Bank simulator
 ├── Telecom simulator
 ├── Power-grid simulator
 ├── Government-service simulator
 ├── Database simulator
 ├── Identity simulator
 └── Monitoring
```

Do not probe real critical infrastructure without authorization.

---

# 25. AI SYSTEMS

## Mwarokin AI

Capabilities:

- Property intelligence.
- Tenant assistance.
- Landlord assistance.
- Rent analysis.
- Property recommendations.
- Notifications.

## Mali Access AI

Capabilities:

- Member support.
- Subscription intelligence.
- Financial notifications.
- Knowledge retrieval.

## SAICOS

Capabilities:

- Fraud detection.
- Transaction anomaly detection.
- Risk scoring.
- Security intelligence.
- Investigation assistance.

## Noesis

Capabilities:

- Enterprise knowledge.
- RAG.
- Research.
- Reasoning.
- Internal knowledge discovery.

AI decisions affecting financial outcomes should be explainable, logged, and subject to appropriate human review.

---

# 26. OPENCLAW TASK QUEUE

Every task must have:

```yaml
id:
priority:
project:
agent:
objective:
inputs:
dependencies:
tools:
risk:
deadline:
acceptance_criteria:
approval_required:
rollback:
```

Priority:

```text
P0 = production blocker / security / money
P1 = important product capability
P2 = enhancement
P3 = research / backlog
```

---

# 27. NIGHTLY AUTONOMOUS WORK

At the end of each day OpenClaw may execute approved background jobs:

### Night 1
Repository analysis.

### Night 2
Database migration review.

### Night 3
API test generation.

### Night 4
Payment sandbox tests.

### Night 5
Financial reconciliation tests.

### Night 6
Python review.

### Night 7
Container optimization.

### Night 8
Infrastructure health checks.

### Night 9
Security scanning.

### Night 10
Documentation generation.

### Night 11
Agent testing.

### Night 12
Mobile compatibility.

### Night 13
Cyber-range tests.

### Night 14
Full regression.

### Night 15
Release candidate validation.

---

# 28. DAILY CEO OPERATING SYSTEM

Every morning:

```text
1. Read overnight report.
2. Review failures.
3. Review security alerts.
4. Review cost alerts.
5. Select top 3 outcomes.
6. Approve sensitive tasks.
7. Start execution.
```

Every evening:

```text
1. Review completed work.
2. Review blockers.
3. Review production risk.
4. Review Git changes.
5. Review costs.
6. Approve overnight queue.
7. Stop unsafe tasks.
```

---

# 29. DAILY AI REPORT

OpenClaw must generate:

```markdown
# Daily AI Operations Report

## Date

## Completed
- 

## Failed
- 

## Blocked
- 

## Code Changes
- 

## Database Changes
- 

## Tests
- 

## Security
- 

## Infrastructure
- 

## AI Usage
- 

## Estimated Cost
- 

## New Risks
- 

## CEO Decisions Required
- 

## Tomorrow
- 
```

---

# 30. PRODUCTION RELEASE GATE

No production release until:

```text
[ ] Requirements accepted
[ ] Code reviewed
[ ] Tests passed
[ ] Security checks passed
[ ] Database migration reviewed
[ ] Backup confirmed
[ ] Rollback prepared
[ ] Monitoring active
[ ] Secrets verified
[ ] Staging smoke test passed
[ ] Human approval obtained
```

---

# 31. 17–31 AUGUST EXECUTION MAP

## 17 Aug — Command Centre

- OpenClaw.
- Agents.
- Repository.
- GitHub Actions.
- Supabase architecture.
- LLM routing.

## 18 Aug — Backend

- PostgreSQL.
- Supabase.
- Auth.
- RLS.
- Storage.
- Node.js APIs.

## 19 Aug — Mwarokin/Mali

- Property data.
- Tenant data.
- Subscription engine.
- Pricing.
- Dashboards.

## 20 Aug — Payments

- M-Pesa sandbox.
- PesaPal sandbox.
- Airtel architecture.
- Stripe architecture.
- Webhooks.
- Ledger.

## 21 Aug — Banking

- Cooperative workflow.
- I&M workflow.
- Cash flow.
- Reconciliation.

## 22 Aug — AI Workstation

- OpenClaw.
- Python.
- Linux.
- Local LLMs.
- RAG.
- UI-TARS.

## 23 Aug — Servers

- Podman.
- VPS.
- Nginx.
- Tailscale.
- Twingate.
- FastAPI/Node.

## 24 Aug — Distributed Infrastructure

- CDN.
- Mirrors.
- Failover.
- Cloud architecture.

## 25 Aug — Security

- API protection.
- Prometheus.
- Datadog.
- SAST.
- DAST.
- Secrets.

## 26 Aug — Compliance

- Corporate documentation.
- Data protection.
- IP documentation.
- Technical documentation.

## 27 Aug — AI Ecosystem

- Mwarokin AI.
- Mali Access AI.
- SAICOS.
- Noesis.
- Agents.md.

## 28 Aug — Multi-device

- Web.
- Android.
- iOS.
- Tablet.
- TV.
- Automotive.
- Wearables.
- Offline.

## 29 Aug — Cyber Range

- Safe Proof lab.
- Security tests.
- Disaster recovery.
- Incident response.

## 30 Aug — Business Verticals

- Mwarokin property.
- Tourism.
- Rentals.
- Leasing.
- Storage.
- Hydro farming.
- Kehuti Logistics.
- Faraja Sky Exports.

## 31 Aug — Release

- Full regression.
- Production readiness.
- Git mirrors.
- Backup verification.
- Executive dashboard.
- Sprint review.

---

# 32. P0 PRIORITY

If time becomes constrained, protect these first:

1. Supabase.
2. Database.
3. Authentication/RLS.
4. Mwarokin property/tenant data.
5. Subscription engine.
6. M-Pesa sandbox.
7. PesaPal sandbox.
8. Payment ledger.
9. Server-side validation.
10. GitHub Actions.
11. OpenClaw.
12. LLM workstation.
13. Backups.
14. Security baseline.
15. Monitoring.

---

# 33. P1 PRIORITY

After P0:

16. Cooperative/I&M banking workflows.
17. Airtel Money.
18. Stripe.
19. Resend.
20. SylloPay.
21. Mwarokin AI.
22. Mali Access AI.
23. SAICOS.
24. Noesis.
25. CDN.
26. Podman.
27. VPS.
28. Tailscale/Twingate.
29. Git mirrors.
30. Multi-device testing.

---

# 34. P2 BACKLOG

Do not allow these to derail the core sprint:

- Large global marketing campaign.
- Full multi-CDN deployment without a requirement.
- Full decentralized data infrastructure.
- Complete patent process.
- Regional data-centre deployment.
- Large-scale external security testing.
- Complete hydro-export marketplace.
- Every possible device integration.

Move unfinished P2 work into the September roadmap.

---

# 35. DEFINITION OF DONE

A task is DONE only when:

```text
Code exists
+
Tests exist
+
Tests pass
+
Security reviewed
+
Documentation updated
+
Git committed
+
CI passed
+
Monitoring considered
+
Rollback understood
+
Acceptance criteria satisfied
```

"Code generated" is NOT "done."

---

# 36. FAILURE HANDLING

If an agent fails:

```text
FAIL
 ↓
Capture logs
 ↓
Classify failure
 ↓
Retry safely
 ↓
Change strategy
 ↓
Escalate
```

Maximum autonomous retries should be bounded.

Never allow:

```text
Infinite retry
Infinite token usage
Infinite deployment loop
Infinite migration loop
Infinite browser automation
```

---

# 37. INCIDENT SEVERITY

```text
SEV-0 = catastrophic/security-critical
SEV-1 = production/payment outage
SEV-2 = major functionality failure
SEV-3 = degraded/non-critical
SEV-4 = minor defect
```

SEV-0/SEV-1 requires immediate human escalation.

---

# 38. ENVIRONMENT MODEL

```text
LOCAL
 ↓
DEV
 ↓
TEST
 ↓
STAGING
 ↓
PRODUCTION
```

Never use production data in development unless appropriately authorized, minimized, protected, and anonymized where required.

Payment integrations should have explicit sandbox and production configurations.

---

# 39. ENVIRONMENT VARIABLES

Example names:

```text
DATABASE_URL
SUPABASE_URL
SUPABASE_ANON_KEY
SUPABASE_SERVICE_ROLE_KEY
S3_BUCKET
S3_REGION
S3_ACCESS_KEY_ID
S3_SECRET_ACCESS_KEY
MPESA_CONSUMER_KEY
MPESA_CONSUMER_SECRET
MPESA_PASSKEY
PESAPAL_KEY
PESAPAL_SECRET
STRIPE_SECRET_KEY
RESEND_API_KEY
OPENROUTER_API_KEY
MODEL_PROVIDER_KEY
```

Never place real values in this document.

---

# 40. DOCUMENTATION STANDARD

Every major system must have:

```text
README.md
ARCHITECTURE.md
SECURITY.md
API.md
DATABASE.md
DEPLOYMENT.md
OPERATIONS.md
TROUBLESHOOTING.md
CHANGELOG.md
```

For AI:

```text
Agents.md
Governance.md
Memory.md
Tools.md
Automation.md
Model-Routing.md
Cost-Governor.md
```

---

# 41. OBSERVABILITY DASHBOARD

Executive dashboard:

```text
SYSTEM HEALTH
API HEALTH
DATABASE HEALTH
PAYMENT SUCCESS RATE
PAYMENT FAILURE RATE
ACTIVE USERS
TRANSACTIONS
REVENUE
SUBSCRIPTIONS
AI COST
INFRASTRUCTURE COST
SECURITY ALERTS
OPEN INCIDENTS
DEPLOYMENT STATUS
BACKUP STATUS
```

---

# 42. AUTOMATION SCORECARD

Track:

```text
Manual tasks eliminated
Automated tasks
Agent success rate
Human intervention rate
Build success rate
Test pass rate
Deployment frequency
Rollback frequency
Mean time to recovery
AI cost per successful task
```

---

# 43. FINAL OPERATING PHILOSOPHY

STA should operate as:

```text
Human Strategy
      +
AI Reasoning
      +
Agentic Execution
      +
Reliable Software
      +
Secure Infrastructure
      +
Observable Systems
      +
Documented Knowledge
      =
Syllogism Technology Africa Operating System
```

The goal is not maximum automation.

The goal is:

**SAFE AUTOMATION + FAST EXECUTION + HUMAN GOVERNANCE + MEASURABLE RESULTS.**

---

# 44. FINAL COMMAND TO OPENCLAW

When a new task arrives:

```text
1. Understand the objective.
2. Inspect the repository before changing it.
3. Search existing documentation and memory.
4. Identify dependencies.
5. Classify P0/P1/P2/P3.
6. Select the correct agent.
7. Select the appropriate LLM.
8. Estimate cost.
9. Create an execution plan.
10. Execute only within permissions.
11. Test every material change.
12. Run security checks.
13. Review the diff.
14. Produce an audit report.
15. Request human approval where required.
16. Deploy only after the required gate.
17. Monitor the result.
18. Document the outcome.
19. Update memory.
20. Queue the next approved task.
```

## Golden Rule

> **OpenClaw and every STA LLM are execution partners, not unrestricted owners of the infrastructure.**

> **When money, identity, security, legal compliance, production data, banking, or critical infrastructure is involved: stop, validate, log, and obtain the required human authorization.**

---

## Sprint Completion Standard

By 31 August 2026, the target is a functioning STA control plane with:

```text
Supabase
+ PostgreSQL
+ Auth/RLS
+ Storage
+ APIs
+ Payment sandbox
+ Financial ledger
+ Mwarokin/Mali subscription foundation
+ OpenClaw
+ Local/cloud LLM routing
+ AI agents
+ GitHub Actions
+ Containers
+ Server platform
+ Security baseline
+ Monitoring
+ Backups
+ Git mirrors
+ Documentation
+ Safe cyber range
+ Production-readiness evidence
```

Everything else becomes a controlled, prioritized roadmap rather than uncontrolled scope.


# 45. OMNISTRATE — STA CONTROL-PLANE MANAGEMENT LAYER

**Official platform:** https://omnistrate.com/

Omnistrate should be treated as a **management/control-plane layer** for the STA distributed SaaS and infrastructure strategy—not as a replacement for Supabase, GitHub, OpenClaw, Kubernetes/Podman, CDN providers, or the underlying cloud infrastructure.

Omnistrate describes its platform as a private-label enterprise control plane for deploying, operating, scaling, governing, and monetizing software across cloud, on-premises, BYOC, single-tenant, cellular multi-tenant, and air-gapped environments. Its documentation also describes generated APIs, customer portals, deployment workflows, tenancy/subscription management, usage metering, observability, governance, and day-2 operations. 

## 45.1 STA Omnistrate Position

Use this architectural relationship:

```text
                         STA CEO
                            │
                     Governance Layer
                            │
                   OpenClaw Orchestrator
                            │
                    STA Control Plane
                            │
                       Omnistrate
                            │
        ┌───────────────────┼───────────────────┐
        │                   │                   │
      CLOUD              ON-PREM             BYOC
        │                   │                   │
      AWS/GCP             Servers          Customer Cloud
      Azure/OCI           VPS              Private VPC
        │                   │                   │
        └───────────────────┼───────────────────┘
                            │
                   STA Applications
                            │
       ┌──────────────┬─────┴──────┬──────────────┐
       │              │            │              │
    Mwarokin        Mali Access  SylloPay       SAICOS
       │              │            │              │
       └──────────────┴────────────┴──────────────┘
                            │
                    Core Services
                            │
        Supabase / PostgreSQL / S3 / APIs / AI
```

Omnistrate's current documentation states that it can use existing artifacts such as GitHub repositories, container images, Helm, Kubernetes, Terraform/OpenTofu, Kustomize, and Docker Compose as inputs to its control-plane workflow. citeturn0search2turn0search7

## 45.2 What Omnistrate Manages for STA

The STA Omnistrate layer should be responsible for coordinating:

- Customer environments.
- SaaS deployments.
- Multi-tenant deployments.
- Single-tenant deployments.
- BYOC deployments.
- On-premises deployments.
- Air-gapped deployment models where appropriate.
- Environment lifecycle.
- Versioned upgrades.
- Rollbacks.
- Deployment health.
- Fleet operations.
- Tenant-aware infrastructure.
- Subscription/plan management.
- Usage metering.
- Cost visibility.
- Operational workflows.
- Governance.
- Access controls.
- Auditability.
- Day-2 operations.

Omnistrate states that its control plane supports deployment, lifecycle management, billing/monetization, governance, observability, backup/recovery and operational automation. citeturn0view0

## 45.3 STA + OpenClaw + Omnistrate

OpenClaw remains the **AI execution/orchestration layer**.

Omnistrate becomes the **infrastructure/product control-plane layer**.

```text
CEO
 ↓
OpenClaw
 ↓
Planner Agent
 ↓
Architecture / Deployment Plan
 ↓
Reviewer + Security Agent
 ↓
Omnistrate Control Plane
 ↓
Provision / Deploy / Upgrade / Monitor
 ↓
Infrastructure
 ↓
Application
 ↓
Observability
 ↓
OpenClaw learns from results
```

OpenClaw must never blindly execute infrastructure actions merely because an LLM generated them.

The agent must first determine:

```text
Is this action:
- Read-only?
- Development?
- Staging?
- Production?
- Financial?
- Security-sensitive?
- Destructive?
- Customer-impacting?
```

Production, destructive, financial, security-sensitive and customer-impacting actions require the appropriate human approval gate.

---

# 46. OMNISTRATE AGENT

Create a dedicated:

```text
Omnistrate Agent
```

### Responsibilities

- Read Omnistrate deployment specifications.
- Validate service definitions.
- Prepare deployment changes.
- Inspect deployment status.
- Track environments.
- Coordinate upgrades.
- Coordinate rollback procedures.
- Review tenant deployment health.
- Collect operational evidence.
- Report deployment failures.
- Coordinate with DevOps Agent.
- Coordinate with Security Agent.
- Coordinate with FinOps/Cost Governor.
- Coordinate with OpenClaw Orchestrator.

### Forbidden actions

The Omnistrate Agent must NOT:

- Expose cloud credentials.
- Circumvent approval gates.
- Delete production environments autonomously.
- Change financial pricing without approval.
- Disable security controls to make deployment succeed.
- Replicate sensitive data without authorization.
- Perform unauthorized external testing.
- Modify customer infrastructure outside the approved deployment boundary.

---

# 47. OMNISTRATE DEPLOYMENT LIFECYCLE

Standard STA workflow:

```text
GitHub
 ↓
CI
 ↓
Build
 ↓
Container / Helm / IaC artifact
 ↓
Security scan
 ↓
Omnistrate specification
 ↓
Validation
 ↓
Development deployment
 ↓
Integration tests
 ↓
Staging deployment
 ↓
Smoke tests
 ↓
Human approval
 ↓
Production deployment
 ↓
Observability
 ↓
Drift detection
 ↓
Upgrade / rollback
```

Omnistrate documents versioned rollouts, health checks, rollback support, drift detection and day-2 operational automation as part of its platform capabilities. citeturn0view0

---

# 48. OMNISTRATE ENVIRONMENT MODEL

STA should define explicit environments:

```text
STA-LOCAL
STA-DEV
STA-TEST
STA-STAGING
STA-PRODUCTION
STA-DR
```

For each environment maintain:

```text
Environment ID
Cloud Provider
Region
Network
Services
Database
Storage
Secrets Reference
Deployment Version
Owner
Cost Centre
Health
Last Deployment
Last Backup
Last Security Scan
```

Do not allow an agent to infer production merely from a hostname or repository branch. Environment identity must be explicit.

---

# 49. MULTI-CLOUD CONTROL STRATEGY

Target:

```text
                  Omnistrate
                       │
       ┌───────────────┼────────────────┐
       │               │                │
      AWS             GCP             Azure
       │               │                │
       └───────────────┼────────────────┘
                       │
              Regional Expansion
                       │
        ┌──────────────┼──────────────┐
        │              │              │
      Africa         Europe        Global
```

Possible future deployment classes:

- Public SaaS.
- Dedicated enterprise SaaS.
- Customer VPC/BYOC.
- Private/on-prem.
- Air-gapped.
- Regional sovereign deployments.

Omnistrate's documentation specifically describes SaaS, BYOC, on-premises, air-gapped and multi-cloud distribution models. citeturn0search2turn0search6

---

# 50. OMNISTRATE + STA SUBSCRIPTIONS

For STA products, separate:

```text
Commercial Subscription
        ↓
Plan / Entitlement
        ↓
Customer Environment
        ↓
Omnistrate Deployment
        ↓
Usage / Metering
        ↓
Application Billing
        ↓
Finance Ledger
```

Examples:

```text
Mwarokin
 ├── Starter
 ├── Professional
 ├── Enterprise
 └── Managed 5% Commission

Mali Access Union
 ├── Member
 ├── Organization
 └── Enterprise

SylloPay
 ├── Merchant
 ├── Business
 └── Enterprise
```

**Important:** Omnistrate's platform billing/metering capabilities should complement, not replace, STA's authoritative financial ledger and payment reconciliation system. citeturn0view0

---

# 51. OMNISTRATE + FINOPS

Connect the STA AI Cost Governor to the Omnistrate management layer:

```text
Infrastructure
 ↓
Usage
 ↓
Metering
 ↓
Cost
 ↓
FinOps
 ↓
AI Cost Governor
 ↓
Forecast
 ↓
Anomaly
 ↓
CEO Alert
```

Track:

- Per customer.
- Per tenant.
- Per application.
- Per environment.
- Per cloud.
- Per region.
- Per service.
- Per AI workload.

Do not automatically terminate a production service solely because an AI cost threshold is exceeded. Escalate according to policy.

---

# 52. OMNISTRATE + OBSERVABILITY

Target:

```text
Applications
     │
     ├── Logs
     ├── Metrics
     ├── Traces
     └── Health
             │
        Omnistrate
             │
     ┌───────┴────────┐
     │                │
 Operations       FinOps
     │                │
 Prometheus       Cost Analysis
 Datadog          Usage
 Alerts           Forecasts
```

Omnistrate states that its operations capabilities include fleet-wide visibility, metrics, dashboards, logs, traces, OpenTelemetry integrations, health monitoring, backups and alerting. citeturn0view0

---

# 53. OMNISTRATE + SECURITY GOVERNANCE

Required boundary:

```text
Identity
 ↓
RBAC
 ↓
Least Privilege
 ↓
Network Policy
 ↓
Secrets
 ↓
Audit
 ↓
Deployment Policy
 ↓
Runtime Monitoring
```

Omnistrate describes controls including least-privilege permissions, encryption, zero-inbound-access patterns, egress allowlists, private connectivity and governance. These should be evaluated against STA's own security requirements before production adoption. citeturn0view0

---

# 54. OMNISTRATE + GITHUB ACTIONS

Recommended pipeline:

```text
GitHub Push
 ↓
GitHub Actions
 ↓
Lint
 ↓
Tests
 ↓
Security Scan
 ↓
Build
 ↓
Artifact
 ↓
Omnistrate Deployment Validation
 ↓
Dev
 ↓
Test
 ↓
Staging
 ↓
CEO Approval
 ↓
Production
```

The Omnistrate CLI (`omnistrate-ctl`) is documented as a command-line tool for building SaaS products, managing plans and operating instance deployments. citeturn0search7

---

# 55. OMNISTRATE + CONTAINER STANDARD

STA should standardize deployable services around:

```text
Source Code
 ↓
Dockerfile / Containerfile
 ↓
Image
 ↓
Registry
 ↓
Omnistrate
 ↓
Environment
```

Where appropriate, existing:

- Podman.
- Docker-compatible images.
- Docker Compose.
- Helm.
- Kubernetes.
- Terraform/OpenTofu.

can remain part of the underlying deployment toolchain.

Omnistrate documents support for Docker Compose, containers, Helm, Kubernetes, Terraform/OpenTofu and related infrastructure definitions. citeturn0search2turn0search7

---

# 56. OMNISTRATE + DECENTRALIZED STA

Do not interpret decentralization as uncontrolled infrastructure duplication.

Use:

```text
STA Control Plane
        │
        ├── Nairobi
        ├── Regional Africa
        ├── International Cloud
        ├── Customer Cloud
        ├── On-Prem
        └── DR
```

Each node must have:

```text
Identity
Owner
Region
Trust Boundary
Data Classification
Encryption
Connectivity
Version
Health
Backup
Recovery Plan
```

The control plane should know where deployments exist without automatically granting every agent unrestricted access to every environment.

---

# 57. OMNISTRATE TASK QUEUE FOR OPENCLAW

Create these OpenClaw task types:

```text
OMNI_DISCOVER
OMNI_VALIDATE
OMNI_BUILD
OMNI_DEPLOY_DEV
OMNI_DEPLOY_TEST
OMNI_DEPLOY_STAGING
OMNI_REQUEST_PRODUCTION_APPROVAL
OMNI_DEPLOY_PRODUCTION
OMNI_HEALTH_CHECK
OMNI_UPGRADE
OMNI_ROLLBACK
OMNI_DRIFT_CHECK
OMNI_COST_CHECK
OMNI_BACKUP_CHECK
OMNI_SECURITY_CHECK
OMNI_TENANT_CHECK
OMNI_REPORT
```

Every task must record:

```yaml
omnistrate:
  environment:
  product:
  service:
  deployment:
  version:
  tenant:
  cloud:
  region:
  requested_action:
  risk:
  approval_required:
  rollback:
  evidence:
```

---

# 58. OMNISTRATE ROLLBACK POLICY

For every upgrade:

```text
Current Version
 ↓
Backup / Snapshot Verification
 ↓
Deploy New Version
 ↓
Health Checks
 ↓
Regression Checks
 ↓
Accept
```

If failure:

```text
Failure
 ↓
Stop rollout
 ↓
Capture evidence
 ↓
Rollback
 ↓
Health check
 ↓
Incident report
 ↓
Root cause
 ↓
Fix
 ↓
Retry
```

Never allow an LLM to repeatedly retry a failed production rollout without a bounded policy and human escalation.

---

# 59. OMNISTRATE 17–31 AUGUST INTEGRATION PLAN

## 17 Aug

- Add Omnistrate to STA architecture inventory.
- Create `Omnistrate-Agent`.
- Define control-plane boundaries.

## 18 Aug

- Map Supabase/API services to deployment units.
- Identify containerizable services.

## 19 Aug

- Map Mwarokin and Mali Access environments.
- Define tenancy model.

## 20 Aug

- Map payment services.
- Keep payment gateways in sandbox.

## 21 Aug

- Map financial services and FinOps boundaries.

## 22 Aug

- Connect OpenClaw deployment planning to Omnistrate workflows.

## 23 Aug

- Map Podman/Nginx/VPS services.

## 24 Aug

- Design multi-cloud/CDN/distribution strategy.

## 25 Aug

- Security and governance review.

## 26 Aug

- Compliance and audit requirements.

## 27 Aug

- AI services and agentic workloads.

## 28 Aug

- Multi-device/customer deployment validation.

## 29 Aug

- Authorized cyber-range deployment.

## 30 Aug

- Mwarokin/agriculture/logistics deployment architecture.

## 31 Aug

- Control-plane readiness review.

---

# 60. OMNISTRATE ACCEPTANCE GATE

Before adopting Omnistrate for a production STA workload:

```text
[ ] Cloud account boundary understood
[ ] Permissions reviewed
[ ] Pricing reviewed
[ ] Data residency reviewed
[ ] Security model reviewed
[ ] IAM/RBAC reviewed
[ ] Network model reviewed
[ ] Audit logging verified
[ ] Backup strategy verified
[ ] Rollback tested
[ ] Tenant isolation tested
[ ] Cost model understood
[ ] CI/CD integration tested
[ ] Staging deployment successful
[ ] Disaster recovery tested
[ ] CEO approval obtained
```

Omnistrate's current pricing page states a first-month free offering for new users and shows a $999 monthly minimum in its pricing calculator; verify the applicable commercial plan, usage costs, contract terms and current pricing before procurement. citeturn0search5

---

# 61. FINAL STA CONTROL-PLANE MODEL

The long-term architecture becomes:

```text
                         CEO
                          │
                    Governance
                          │
                    OpenClaw AI
                          │
                 Agent Orchestration
                          │
             ┌────────────┴────────────┐
             │                         │
       Engineering Plane          Control Plane
             │                         │
      GitHub / CI/CD             Omnistrate
      LLMs / Python             Deployments
      Tests / Security           Tenants
             │                   Lifecycle
             │                   Governance
             │                   FinOps
             │                   Operations
             └────────────┬────────────┘
                          │
                    Infrastructure
                          │
       ┌──────────┬──────┼──────┬──────────┐
       │          │      │      │          │
      AWS        GCP   Azure   On-Prem    BYOC
       │          │      │      │          │
       └──────────┴──────┼──────┴──────────┘
                          │
                    STA Applications
                          │
        Mwarokin / Mali Access / SylloPay
        SAICOS / Noesis / Future STA Apps
                          │
                    Core Data Layer
                          │
          Supabase / PostgreSQL / S3
                          │
                    Observability
                          │
               Prometheus / Datadog
```

## Strategic rule

**OpenClaw = intelligent execution.**

**Omnistrate = deployment/control-plane management.**

**GitHub = source-of-truth engineering workflow.**

**Supabase/PostgreSQL = application data platform.**

**S3/object storage = durable file/object layer.**

**Podman/Kubernetes/cloud infrastructure = runtime layer.**

**CDN/WAF/network = edge and security layer.**

**Prometheus/Datadog = observability layer.**

**CEO/Governance = final authority.**

This separation prevents STA from turning OpenClaw into an unrestricted infrastructure administrator while still allowing agentic automation to operate the platform at scale.
