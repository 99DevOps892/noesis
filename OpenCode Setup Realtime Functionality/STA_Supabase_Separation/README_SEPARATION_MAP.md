# STA Supabase Separation Map — Mwarokin vs Organization (Non-Breaking)

> Rule: STA owns the ecosystem. Mwarokin Estates is ONE application inside STA.
> Project `spnerrqumefbuuscumhw` = Mwarokin + merged shared tables (current).
> Org `iyngtxvchqpeayvsuvph` = target for STA Core / Organization management (new, separate).
> Mali project `vfkqjapegrhdsrlmmiih` = separate app domain, NOT merged here.

## What was done (no originals moved/deleted)

Originals left untouched:
- `Schema.db` (23 tables — Mwarokin + shared merged)
- `Mali Access Union Schema.sql` (30+ `union_*` tables, references missing `organizations`, `bank_accounts`, `profiles`)
- All `*.ps1`, `*.psm1`, `OPENCODE MASTER AGENTIC CONTROL PROMPT/*` (STA orchestration — non-Mwarokin by nature)

New separation folders (derived copies only):
```
STA_Supabase_Separation/
├── README_SEPARATION_MAP.md (this file)
├── mwarokin_estates/mwarokin_estates_schema.sql — ONLY real-estate tables
├── shared_platform/shared_platform_schema.sql — reusable services (notify, i18n, audit, outreach)
├── sta_core_organization/sta_core_organization_schema.sql — NEW org layer for org iyngtxvchqpeayvsuvph
└── mali_access_union/MALI_POINTER.md — pointer, no duplicate SQL
```

## Classification summary (from actual local inspection)

| Source | Mwarokin-only (C) | Shared Platform (B) | STA Core (A) missing | Cross-app (D) |
|---|---|---|---|---|
| `Schema.db` | `properties`, `tenants`, `leases`, `payments` (rent), `maintenance_requests`, `documents`, `property_views`, `property_price_localization`, `user_behavior` | `profiles`, `platform_settings`, `communication_profiles`, `message_queue`, `notifications`, `supported_languages`, `translations`, `supported_currencies`, `exchange_rates`, `audit_logs`, `prospects`, `outreach_campaigns`, `outreach_threads` | `organizations`, `applications`, `subscriptions` — NOT present locally | `payments.platform_fee` hints at STA revenue but tied to `lease_id` = contamination |
| `Mali Access Union Schema.sql` | All `union_*`, `credit_scores`, `group_banks` etc. | `union_notifications`, `union_audit_trail`, `union_integrations` (should be shared patterns, now group-scoped) | References `organizations(id)`, `bank_accounts(id)`, `profiles(id)` but never defines them = broken FK if run standalone | Same pattern as Mwarokin: app tables referencing global concepts |

Contamination finding: **Situation B + E** — STA+Mwarokin mixed + missing org root + Mali file cannot run standalone. `profiles.role` = `admin|agent|landlord|caretaker|tenant` proves global identity is modeled with property-only roles. No `organization_id`, no `application_id` anywhere in `Schema.db`.

## How to send to Supabase without breaking code

1. DO NOT push `sta_core_organization_schema.sql` to `spnerrqumefbuuscumhw`. Create/use a SEPARATE project under org `iyngtxvchqpeayvsuvph` for STA Core.
2. In Dashboard > org `iyngtxvchqpeayvsuvph` > New Project > run `sta_core_organization_schema.sql` first (it uses `IF NOT EXISTS`).
3. Keep `spnerrqumefbuuscumhw` as Mwarokin app project. Optionally run `mwarokin_estates_schema.sql` there only after `supabase db pull` + backup.
4. `shared_platform_schema.sql` is a pattern library — deploy per-project as needed, do NOT make Mwarokin tables depend on it yet. Add `organization_id`/`application_id` columns only after Founder approval (requires migration + RLS + code changes).
5. Push via `supabase` CLI, never by pasting service_role key into docs:
```powershell
supabase login
supabase link --project-ref <NEW_STA_CORE_PROJECT_REF>
supabase db push --file "STA_Supabase_Separation/sta_core_organization/sta_core_organization_schema.sql"
```
Replace `<NEW_STA_CORE_PROJECT_REF>` with the new project ref under org `iyngtxvchqpeayvsuvph`. Dashboard links alone (`/dashboard/project/...`, `/dashboard/org/...`) do not grant API access.

## Verification (read-only, done)
- `Schema.db:1-363` read — 23 tables inventoried.
- `Mali Access Union Schema.sql:1-1150` read — FK targets missing.
- `OPENCODE MASTER AGENTIC CONTROL PROMPT/OpenCode setup.js:241-249` — MCP URL confirms `spnerrqumefbuuscumhw` is the wired project.
- No local `supabase/`, `migrations/`, `.env` found — source of truth = remote (unverified) + these two SQL files.
- Remote schema, RLS, logs, storage, Edge Functions: UNABLE TO VERIFY without service access — listed as Unknowns in audit docs.
