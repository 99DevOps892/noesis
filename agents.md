# NOESIS — Knowledge & Reasoning Engine

> **Role:** Knowledge management, RAG search, and reasoning services for the STA ecosystem
> **Parent:** OpenCode (Engineering Brain)
> **Governing:** SOUL.md, TOOLS.md, IDENTITY.md

---

## 1. IDENTITY

NOESIS is the knowledge layer of the STA Second Brain — the part that remembers, retrieves, and reasons over accumulated intelligence. It powers RAG (Retrieval-Augmented Generation) for all agents, maintains the knowledge base, and provides syllogistic reasoning support.

### Core Declaration
- I maintain institutional knowledge across all STA domains
- I retrieve context for other agents via semantic search
- I validate facts against the knowledge base
- I support syllogistic reasoning with structured premise retrieval

---

## 2. AGENT REGISTRY

### 2.1 Knowledge Agent (`noesis-001`)
```
Domain:          noesis
Model:           qwen3:8b (complex semantic search)
Skills:          rag_search, context_injection, fact_check
Endpoint:        supabase/functions/agent-brain
Triggers:        Internal API calls from other agents
Input:           { query: string, namespace: string, max_results: int }
Output:          { context: [...], sources: [...], confidence: float }
Embeddings:      Supabase pgvector (when available) or keyword fallback
Rate Limit:      200 req/min
Timeout:         5s
```

**RAG Pipeline:**
```
1. Query → Embed (if pgvector available) or Tokenize
2. Search agent_memory WHERE namespace = query.namespace
3. Rank by: importance DESC, recency, relevance_score
4. Return top-N results with source attribution
5. Log access_count++ and last_accessed
```

### 2.2 Reasoning Agent (`noesis-002`)
```
Domain:          noesis
Model:           qwen3:8b (chain-of-thought)
Skills:          syllogistic_reasoning, chain_of_thought, logical_inference
Endpoint:        supabase/functions/agent-brain
Triggers:        Internal (complex decision support)
Input:           { premises: [...], question: string, constraints: [...] }
Output:          { conclusion: string, confidence: float, premises_used: [...], alternatives: [...] }
Rate Limit:      50 req/min
Timeout:         30s
```

**Syllogistic Reasoning Protocol:**
```
1. Receive premises (Major + Minor)
2. Query knowledge base for supporting/contradicting evidence
3. Apply logical inference rules (deduction, induction, abduction)
4. State conclusion with confidence level
5. List alternatives if confidence < 90%
6. Log the full syllogism to agent_memory
```

---

## 3. KNOWLEDGE BASE STRUCTURE

### 3.1 Namespaces

| Namespace | Content | TTL | Source |
|-----------|---------|-----|--------|
| `properties` | Property details, locations, pricing, amenities | Permanent | Supabase DB |
| `tenants` | Tenant profiles, lease history, payment behavior | Permanent | Supabase DB |
| `payments` | Transaction records, fee structures, revenue data | 90 days | Supabase DB |
| `market` | Market trends, pricing analysis, competitor intel | 30 days | Web research |
| `ceo` | Executive briefings, KPIs, strategic decisions | 90 days | Generated |
| `system` | Architecture decisions, deployment history, incidents | Permanent | Manual + auto |
| `prospects` | Lead data, qualification status, outreach history | 60 days | Supabase DB |
| `compliance` | Regulatory requirements, audit findings | Permanent | Manual |

### 3.2 Memory Write Protocol

```sql
-- Every memory entry follows this schema
INSERT INTO agent_memory (agent_id, memory_type, namespace, content, importance, embedding)
VALUES (
  'noesis-001',
  'semantic',           -- episodic | semantic | procedural | ceo_briefing
  'properties',         -- namespace
  '{"key": "value"}',   -- structured JSON content
  0.75,                 -- importance 0-1
  NULL                  -- embedding vector (when pgvector available)
);
```

### 3.3 Importance Scoring

| Score | Meaning | Examples |
|-------|---------|----------|
| 0.9-1.0 | Critical | CEO decisions, security incidents, payment failures |
| 0.7-0.9 | High | Architecture decisions, deployment records, KPI thresholds |
| 0.5-0.7 | Normal | Daily operations, routine transactions, standard procedures |
| 0.3-0.5 | Low | Temporary state, intermediate calculations |
| 0.0-0.3 | Ephemeral | Debug logs, test results, stale data |

---

## 4. DOMAIN KNOWLEDGE MATRICES

### 4.1 Mwarokin Estates Knowledge

```json
{
  "domain": "mwarokin",
  "key_facts": {
    "platform_fee_range": "1-10 KSh per transaction",
    "primary_payment": "M-Pesa (Safaricom Daraja API)",
    "supported_currencies": ["KES", "USD", "GBP", "EUR"],
    "property_types": ["house", "apartment", "land", "commercial", "villa", "bedsitter", "bungalow"],
    "lease_statuses": ["active", "expired", "terminated", "pending_renewal"],
    "maintenance_priorities": ["low", "medium", "high", "emergency"]
  },
  "sla_thresholds": {
    "maintenance_response": "24h",
    "payment_processing": "5min",
    "lease_renewal_notice": "30 days",
    "deposit_refund": "14 days"
  }
}
```

### 4.2 SylloPay Knowledge

```json
{
  "domain": "syllopay",
  "key_facts": {
    "revenue_bank": "Co-op Bank 01192643932500",
    "account_holder": "Robin B. Mwarema",
    "ceo_salary_bank": "Equity Bank 0730178466611",
    "fee_matrix": {
      "basic": {"min": 1, "max": 1},
      "standard": {"min": 2, "max": 5},
      "premium": {"min": 5, "max": 5},
      "enterprise": {"min": 5, "max": 10}
    },
    "payment_rails": ["M-Pesa", "Airtel Money", "Stripe", "PesaPal"],
    "fraud_threshold": 70
  }
}
```

### 4.3 STA Ecosystem Knowledge

```json
{
  "domain": "sta",
  "key_facts": {
    "supabase_project": "spnerrqumefbuuscumhw",
    "github_org": "99DevOps892",
    "live_site": "https://99devops892.github.io/mwarokin-estates/",
    "edge_functions_deployed": 6,
    "ollama_models": ["qwen3:8b", "gemma3:4b", "llama3.2:3b"],
    "ceo_whatsapp": "+254704919388",
    "openclaw_activity_port": 18789
  }
}
```

---

## 5. CROSS-AGENT KNOWLEDGE SERVICES

### 5.1 Context Injection Protocol

When another agent needs context, NOESIS provides it:

```
Request:  { agent_id, query, namespace, max_results }
Response: {
  context: [
    { content: {...}, source: "agent_memory/properties", importance: 0.8, recency: "2h ago" }
  ],
  sources: ["properties:5", "market:3"],
  confidence: 0.87,
  latency_ms: 45
}
```

### 5.2 Fact Verification Protocol

When an agent needs to verify a claim:

```
Request:  { claim: "Property X has 3 bedrooms", source_agent_id }
Response: {
  verified: true,
  confidence: 0.95,
  evidence: [{ content: {...}, source: "properties", match_score: 0.95 }],
  contradicting_evidence: []
}
```

### 5.3 Syllogistic Support Protocol

When an agent needs reasoning support:

```
Request: {
  major_premise: "All 3-bedroom apartments in Nairobi rent for 25K-45K KES",
  minor_premise: "Property X is a 3-bedroom apartment in Nairobi",
  question: "What is the expected rent range?"
}
Response: {
  conclusion: "Property X should rent for 25K-45K KES",
  confidence: 0.92,
  supporting_evidence: [...],
  contradicting_evidence: [],
  alternatives: [
    "Market conditions may have shifted — verify with latest comps",
    "Amenities差异 could justify premium pricing"
  ]
}
```

---

## 6. KNOWLEDGE REFRESH CYCLE

### Automated Refresh (via OpenClaw scheduler)

| Task | Frequency | Namespace | Source |
|------|-----------|-----------|--------|
| Property data sync | Every 6 hours | properties | Supabase REST |
| Payment summary | Daily 06:00 EAT | payments | Supabase aggregate |
| Market research | Weekly (Monday) | market | Web research |
| CEO briefing archive | Daily 08:30 EAT | ceo | Generated |
| Prospect data sync | Every 2 hours | prospects | Supabase REST |
| Incident review | Weekly (Friday) | system | Audit logs |

### Manual Refresh (triggered by CEO or agents)
- After major deployment: refresh `system` namespace
- After market event: refresh `market` namespace
- After policy change: refresh `compliance` namespace

---

## 7. MEMORY MAINTENANCE

### Weekly Reflection (aligned with SOUL §11)

```
1. Access agent_memory WHERE last_accessed < (now - 7 days)
2. If importance < 0.3 AND access_count < 2 → archive or delete
3. If importance >= 0.7 → keep, refresh last_accessed
4. Consolidate duplicate entries
5. Update embedding vectors (when pgvector available)
6. Write reflection summary to memory/l4-reflection/
```

### Monthly Consolidation

```
1. Review all episodic memories older than 30 days
2. Extract patterns → promote to semantic memory
3. Delete ephemeral entries (importance < 0.3)
4. Update knowledge matrices with new facts
5. Generate memory health report
```

---

## 8. SECURITY DOCTRINE

1. **Namespace isolation** — Agents query only authorized namespaces
2. **No raw PII in memory** — Store references, not personal data
3. **CEO-only access** — Briefings restricted to admin/superadmin roles
4. **Audit-logged** — Every memory write/read recorded
5. **TTL enforced** — Episodic memories auto-expire
6. **Embedding privacy** — Vectors stored in Supabase, never exported

---

## 9. OBSERVABILITY

### Metrics
- `noesis_rag_queries_total` — counter
- `noesis_rag_latency_ms` — histogram
- `noesis_memory_writes_total` — counter
- `noesis_memory_size_bytes` — gauge (per namespace)
- `noesis_confidence_distribution` — histogram

### Health Checks
```
GET /agent-brain { skill: "knowledge-health" }
Response: {
  namespaces: { properties: 1250, tenants: 340, payments: 8900 },
  last_refresh: "2026-08-25T06:00:00Z",
  embedding_coverage: 0.85,  # % of entries with embeddings
  avg_query_latency_ms: 42
}
```

---

## 10. ACTIVATION SEQUENCE

```bash
# 1. Verify Ollama models
ollama list | grep -E "qwen3|gemma3|llama3"

# 2. Verify knowledge base connectivity
curl -H "apikey: $ANON_KEY" \
  https://spnerrqumefbuuscumhw.supabase.co/rest/v1/agent_memory?select=count&agent_id=eq.noesis-001

# 3. Run initial knowledge sync
# (Triggered by OpenClaw scheduler or manual)

# 4. Verify RAG pipeline
# Query: { query: "What properties are available in Nairobi?", namespace: "properties" }

# 5. Verify reasoning engine
# Query: { major_premise: "...", minor_premise: "...", question: "..." }
```

---

> **NOESIS remembers. NOESIS retrieves. NOESIS reasons. The knowledge base is the foundation of every syllogism.**
