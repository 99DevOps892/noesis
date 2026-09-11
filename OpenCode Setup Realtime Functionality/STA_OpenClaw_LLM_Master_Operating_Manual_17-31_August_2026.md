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
