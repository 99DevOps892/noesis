# Mali Access Union Project — Non-MAU Separation Map (vfkqjapegrhdsrlmmiih perspective)

> Rule: Mali Access Union is ONE application inside STA. Project `vfkqjapegrhdsrlmmiih` = Mali app ONLY.
> Org `iyngtxvchqpeayvsuvph` = target for STA Core / Organization management (separate project).
> No originals moved/deleted. All separation is derived copies + pointers. No code broken.

## 1. What was CHECKED (read-only, local evidence)

- `Mali Access Union Schema.sql:1-1150` — 31 tables, all `union_*` / `credit_*` / `group_bank*` / `risk_*`. Pure MAU domain.
  Dangling FKs (blocking if run standalone): `organizations(id)` ref at line 19,
  `bank_accounts(id)` refs at lines 46-47, `profiles(id)` refs throughout. None defined in-file.
- `Schema.db:1-363` — 23 tables, ZERO `union_*` tables. All Mwarokin (`properties`, `tenants`,
  `leases`, `payments`, `maintenance_requests`, `documents`, `property_views`,
  `property_price_localization`, `user_behavior`) + shared (`profiles`, `platform_settings`,
  `message_queue`, `notifications`, `languages/translations`, `currencies/rates`, `audit_logs`,
  `prospects`, `outreach_*`). = NON-MAU. Must NEVER be pushed to `vfkqjapegrhdsrlmmiih`.
- `*.ps1` + `*.psm1` (22 files: `Deploy-*.ps1`, `Start-*.ps1`, `STA_Ecosystem_*.psm1`,
  `SyllogismAgentEngine*.psm1`, `STA_Page3_*`, `OpenClawServer*.ps1`, etc.) — grep for
  `union_|Mali|credit_score|contribution|loan` = ZERO hits in ps1/psm1. = STA orchestration,
  NON-MAU. Must NOT go to Mali project.
- `OPENCODE MASTER AGENTIC CONTROL PROMPT/*` (13 files) + `STA_OpenClaw_*Manual*.md` +
  `SyllogismTechnologyAfrica-Architecture-*.md` + `SyllogismCyberControl.md` — ecosystem docs
  covering Mwarokin + Mali + SylloPay + SAICOS. = STA-level, NON-MAU as deployables.
  Only mentions of Mali are as one app among many (e.g. Manual:763,781,1134).
- Remote Supabase (dashboard links only): UNABLE TO VERIFY. Dashboard URLs do not grant API
  access. No local `supabase/`, `migrations/`, `.env`. Remote schema, RLS, row counts,
  storage, Edge Functions, realtime, logs = Unknowns. Need `supabase link --project-ref
  vfkqjapegrhdsrlmmiih` + `supabase db pull` with access keys to confirm.

## 2. Classification — MAU Core (KEEP in vfkqjapegrhdsrlmmiih)

Managing groups, credit score, members, financial borrowing:

| Table | Domain | Evidence |
|---|---|---|
| `union_groups` | groups | Mali .sql:11-61 |
| `union_members` | members | Mali .sql:64-105 |
| `union_contributions` | group finance | Mali .sql:112-140 |
| `union_loans`, `union_group_loans`, `union_loan_repayments` | borrowing | Mali .sql:143-261 |
| `credit_scores`, `credit_score_history`, `risk_assessments` | credit score | Mali .sql:267-368 |
| `group_banks`, `group_bank_transactions` | group banking | Mali .sql:375-453 |
| `union_share_trading`, `union_dividends` | shares | Mali .sql:460-518 |
| `union_savings_accounts`, `union_savings_transactions` | savings | Mali .sql:525-574 |
| `union_penalty_rules`, `union_penalties` | penalties/fees | Mali .sql:581-629 |
| `union_meetings`, `union_resolutions`, `union_member_applications` | group governance/onboarding | Mali .sql:635-958 |
| `union_chart_of_accounts`, `union_journal_entries`, `union_journal_items` | group accounting (NOT STA global ledger) | Mali .sql:707-771 |
| `union_report_definitions`, `union_reports`, `union_compliance` | group reports/compliance | Mali .sql:778-883 |
| `union_notifications`, `union_audit_trail`, `union_integrations`, `union_webhook_events`, `union_system_config`, `union_system_logs` | group-scoped platform patterns (keep scoped; do NOT promote to global without migration) | Mali .sql:890-1062 |

Action: deploy ONLY this file's tables to `vfkqjapegrhdsrlmmiih`, AFTER STA Core deps exist.
See `mali_deploy_guard.sql` for safe order check. Original `Mali Access Union Schema.sql`
left untouched at workspace root.

## 3. Upgrade Extras — NON-MAU (DO NOT push to vfkqjapegrhdsrlmmiih)

These were merged in workspace but belong to STA Core / Shared / other apps.
They live in separation folders as derived copies. Send to NEW project under
org `iyngtxvchqpeayvsuvph` per runbook `ORG_PUSH_RUNBOOK.md`.

| Workspace source | Count | Target folder | Target Supabase |
|---|---|---|---|
| `Schema.db` Mwarokin-only tables (`properties`, `tenants`, `leases`, `payments`, `maintenance_requests`, `documents`, `property_views`, `property_price_localization`, `user_behavior`) | 9 | `../mwarokin_estates/mwarokin_estates_schema.sql` (already extracted) | Mwarokin project ONLY, never Mali |
| `Schema.db` shared tables (`profiles`, `platform_settings`, `communication_profiles`, `message_queue`, `notifications`, `supported_languages`, `translations`, `supported_currencies`, `exchange_rates`, `audit_logs`, `prospects`, `outreach_campaigns`, `outreach_threads`) | 14 | `../shared_platform/shared_platform_schema.sql` (already extracted) | pattern library, deploy per-project as needed |
| NEW STA Core (`organizations`, `organization_roles`, `organization_members`, `organization_settings`, `applications`, `application_memberships`, `billing_plans`, `subscriptions`, `sta_audit_events`, `bank_accounts`) | 10 | `../sta_core_organization/sta_core_organization_schema.sql` (already created) | NEW project under org `iyngtxvchqpeayvsuvph` FIRST |
| All `*.ps1` / `*.psm1` STA orchestration (22 files, zero MAU refs) | 22 | NOT SQL — leave in place, never push as SQL; register in `STA_APPLICATION_REGISTRY.md` as platform tooling | no DB push |
| `OPENCODE MASTER AGENTIC CONTROL PROMPT/*` + STA manuals + architecture docs | ~18 | docs only — governance reference for org project | no DB push |

## 4. Contamination findings (Mali perspective)

- F-01 HIGH: Mali SQL cannot run standalone (dangling `organizations`, `bank_accounts`, `profiles`).
  Fix already staged: STA Core SQL defines `organizations` + `bank_accounts`; Shared SQL defines
  `profiles`. Deploy order in `mali_deploy_guard.sql` + `ORG_PUSH_RUNBOOK.md`. No FK edits made yet
  (requires Founder approval + RLS + code updates).
- F-02 MEDIUM: `union_notifications` / `union_audit_trail` / `union_integrations` duplicate shared
  patterns but group-scoped. Do NOT merge into global tables yet — would collapse
  Group ≠ Organization ≠ Member ≠ User. Keep scoped; STA Core has separate
  `sta_audit_events` / `subscriptions` / `applications`.
- F-03 MEDIUM: Group accounting (`union_chart_of_accounts`, `union_journal_*`) is NOT STA global
  accounting. Do NOT point STA finance at these. STA Core has no global ledger yet — intentional
  gap, needs approved design (see audit docs).
- F-04 LOW: No evidence of Mwarokin tables inside Mali SQL (zero `properties/tenants/leases`
  refs). Contamination risk is workspace-level (pushing wrong file to wrong project), not
  schema-level. Mitigated by this map + runbook.

## 5. How to send without breaking code

1. NOTHING original moved, renamed, or deleted. Only new files added under
   `STA_Supabase_Separation/mali_access_union/`.
2. Push STA Core SQL to a NEW project under org `iyngtxvchqpeayvsuvph` first.
3. Then verify Mali deps via `mali_deploy_guard.sql` against `vfkqjapegrhdsrlmmiih`.
4. Then deploy Mali SQL to `vfkqjapegrhdsrlmmiih` only (never Schema.db, never STA Core).
5. Full steps: see `ORG_PUSH_RUNBOOK.md`. All pushes via `supabase` CLI with
   `IF NOT EXISTS` SQL — no DROPs, no renames, no RLS changes in this batch.
6. Founder approval required before: any DROP/rename, FK repointing, RLS change,
   adding `organization_id`/`application_id` to Mali tables, financial writes, prod pushes.
