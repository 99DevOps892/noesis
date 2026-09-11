# Push Runbook — Mali (vfkqjapegrhdsrlmmiih) + STA Core Org (iyngtxvchqpeayvsuvph)

> Non-breaking. No DROPs. No renames. No RLS changes. `IF NOT EXISTS` SQL only.
> Secrets: use env-var names only. Never paste service_role keys into docs/chat.

## A. What goes where (no-break rule)

| SQL file | Push to | Never push to |
|---|---|---|
| `STA_Supabase_Separation/sta_core_organization/sta_core_organization_schema.sql` (10 tables: organizations, roles, members, settings, applications, memberships, billing_plans, subscriptions, sta_audit_events, bank_accounts) | NEW project under org `iyngtxvchqpeayvsuvph` (create first in Dashboard > org > New Project) | `vfkqjapegrhdsrlmmiih` (Mali) or Mwarokin project |
| `Mali Access Union Schema.sql` (workspace root original, 31 MAU tables) | `vfkqjapegrhdsrlmmiih` ONLY, after guard passes | org-level new project, Mwarokin project |
| `STA_Supabase_Separation/shared_platform/shared_platform_schema.sql` | pattern library — deploy per-project only as needed, after approval | do not auto-merge into Mali prod |
| `STA_Supabase_Separation/mwarokin_estates/mwarokin_estates_schema.sql` + `Schema.db` | Mwarokin project ONLY | `vfkqjapegrhdsrlmmiih` — NEVER (non-MAU extras) |
| `mali_deploy_guard.sql` (this folder) | run as READ-ONLY check on `vfkqjapegrhdsrlmmiih` before any Mali push | nowhere as schema change |
| All `*.ps1` / `*.psm1` / docs | NO DB push — platform tooling + governance docs | any Supabase project as SQL |

## B. Prerequisites

1. Supabase CLI installed. `supabase login` done (browser, no keys in repo).
2. You have access to org `iyngtxvchqpeayvsuvph` (can see it in Dashboard).
   Dashboard links alone do not grant CLI access — login identity must have access.
3. Backup: in Dashboard for `vfkqjapegrhdsrlmmiih` > Database > Backups, confirm
   PITR/snapshot before any push. Record backup timestamp for approvals log.
4. Freeze: pause unplanned schema edits while pushing (see audit docs).

## C. Step 1 — Create + seed STA Core org project (Organizations management)

Dashboard: open `https://supabase.com/dashboard/org/iyngtxvchqpeayvsuvph` >
New Project (note new project ref, e.g. `<NEW_STA_CORE_REF>`).

```powershell
# Link to the NEW org-level project (NOT Mali)
supabase link --project-ref <NEW_STA_CORE_REF>

# Dry-check SQL parses (local, no push)
# Open sta_core_organization_schema.sql and confirm header says org project.

# Push STA Core (idempotent, IF NOT EXISTS)
supabase db push --file "STA_Supabase_Separation/sta_core_organization/sta_core_organization_schema.sql"
```

Verify in Dashboard > new project > Table Editor: `organizations`, `applications`,
`subscriptions`, `bank_accounts`, `sta_audit_events` exist. Then insert ONE STA root
org + app registry rows via Dashboard (manual, audited — not in SQL file to avoid
duplicate seeds):

```sql
-- Run ONCE in new org project SQL editor, then record IDs for approvals log
INSERT INTO public.organizations (slug, name, org_type)
VALUES ('sta-root','Syllogism Technology Africa','sta_root')
ON CONFLICT (slug) DO NOTHING;

INSERT INTO public.applications (slug, name, description, status)
VALUES ('mali-access-union','Mali Access Union','Group/cooperative/member-management','active')
ON CONFLICT (slug) DO NOTHING;
```

## D. Step 2 — Guard-check Mali project (read-only, safe)

```powershell
supabase link --project-ref vfkqjapegrhdsrlmmiih
# Run mali_deploy_guard.sql in Dashboard > vfkqjapegrhdsrlmmiih > SQL editor
# (paste file contents, Run). Do NOT use service_role key locally.
```

- Check 1 returns rows → STOP. Deploy STA Core/Shared deps first; Mali FKs will fail otherwise.
- Check 2 returns 31 rows → Mali already deployed; diff before anything.
- Check 3 returns rows → contamination (non-MAU tables in Mali). STOP, log, get approval.

## E. Step 3 — Deploy Mali SQL to vfkqjapegrhdsrlmmiih (only after guard passes)

```powershell
supabase link --project-ref vfkqjapegrhdsrlmmiih
supabase db push --file "Mali Access Union Schema.sql"
# If CLI rejects raw CREATE TABLE without IF NOT EXISTS on existing DB:
# use Dashboard SQL editor in small batches (sections 1-15) and record results.
```

Post-check: re-run `mali_deploy_guard.sql` Check 2 — expect 31 rows. Record in
`STA_Database_Audit/STA_DATABASE_CHANGE_APPROVALS.md`.

## F. Rollback / no-break guarantees

- This batch adds tables only (`IF NOT EXISTS` in STA Core/Shared; Mali file run once).
  No `DROP`, `ALTER .. RENAME`, `TRUNCATE`, RLS, or data UPDATE included.
- If a push fails halfway: do NOT retry blindly. Capture error, keep backup timestamp,
  restore from Dashboard backup if data affected, and log in approvals file.
- Adding `organization_id` / `application_id` to Mali tables, RLS changes, FK repointing,
  and financial-ledger changes are EXPLICITLY OUT OF SCOPE here — require separate
  Founder-approved migration with tests (see `STA_Database_Audit/STA_DATABASE_MIGRATION_PLAN.md`).

## G. What to tell Founder (approval gate)

Needs approval BEFORE proceeding beyond guards: any production push, any RLS/policy edit,
any FK change, any `organization_id` backfill, any financial-table write, any cross-project
data copy. This runbook alone authorizes only: create new org project, push STA Core SQL
there, run read-only guards on Mali, and (if guard green + backup done + written approval)
push Mali SQL to `vfkqjapegrhdsrlmmiih`.
