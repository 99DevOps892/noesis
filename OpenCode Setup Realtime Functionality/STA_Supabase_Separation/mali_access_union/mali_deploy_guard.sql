-- ============================================================================
-- MALI ACCESS UNION — Deploy guard (READ-ONLY checks, safe to run anywhere)
-- Project: vfkqjapegrhdsrlmmiih (Mali app ONLY)
-- Purpose: verify STA Core / Shared deps exist BEFORE deploying
--   "Mali Access Union Schema.sql" (workspace root, 1150 lines, left untouched).
-- This file creates NOTHING. It only SELECTs. No DROPs. No RLS changes.
-- Run order:
--   1. Deploy ../sta_core_organization/sta_core_organization_schema.sql
--      to NEW project under org iyngtxvchqpeayvsuvph.
--   2. Run THIS guard against vfkqjapegrhdsrlmmiih to confirm deps.
--   3. Only then deploy Mali SQL to vfkqjapegrhdsrlmmiih.
-- ============================================================================

-- Check 1: required dependency tables exist (STA Core + Shared)
SELECT table_name AS check_missing_deps
FROM (VALUES ('organizations'), ('bank_accounts'), ('profiles')) AS req(table_name)
WHERE NOT EXISTS (
  SELECT 1 FROM information_schema.tables
  WHERE table_schema = 'public' AND tables.table_name = req.table_name
);
-- Expected: 0 rows before Mali deploy is safe. If any row returns,
-- deploy STA Core + Shared first. Do NOT deploy Mali SQL yet.

-- Check 2: confirm Mali tables are / are not already present (idempotency)
SELECT tablename AS existing_mali_tables
FROM pg_tables
WHERE schemaname = 'public'
  AND tablename IN (
    'union_groups','union_members','union_contributions',
    'union_loans','union_group_loans','union_loan_repayments',
    'credit_scores','credit_score_history','risk_assessments',
    'group_banks','group_bank_transactions',
    'union_share_trading','union_dividends',
    'union_savings_accounts','union_savings_transactions',
    'union_penalty_rules','union_penalties',
    'union_meetings','union_resolutions',
    'union_chart_of_accounts','union_journal_entries','union_journal_items',
    'union_report_definitions','union_reports',
    'union_audit_trail','union_compliance',
    'union_notifications','union_member_applications',
    'union_integrations','union_webhook_events',
    'union_system_config','union_system_logs'
  )
ORDER BY 1;
-- Expected: 0 rows on fresh project (safe to deploy Mali SQL).
-- If rows exist, Mali is already deployed — do NOT re-run blindly; diff first.

-- Check 3: confirm NON-MAU tables are absent from Mali project (contamination check)
SELECT tablename AS non_mau_tables_that_must_not_be_here
FROM pg_tables
WHERE schemaname = 'public'
  AND tablename IN (
    'properties','tenants','leases','payments',
    'maintenance_requests','documents','property_views',
    'property_price_localization','user_behavior',
    'organization_members','organization_settings','applications',
    'billing_plans','subscriptions','sta_audit_events'
  )
ORDER BY 1;
-- Expected: 0 rows in vfkqjapegrhdsrlmmiih. Any hit = wrong file pushed here.
-- Remedy: do NOT drop; document, freeze, get approval, plan migration.
