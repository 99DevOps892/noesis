# Mali Access Union — Pointer (no copy, no break)

Original file left untouched: `Mali Access Union Schema.sql` (1150 lines, 30+ tables).

Do NOT merge this into `spnerrqumefbuuscumhw` (Mwarokin project).
Target project: `vfkqjapegrhdsrlmmiih` (Mali app project).

Blocking issue found: file references but does NOT define:
- `organizations(id)` → now defined in `../sta_core_organization/sta_core_organization_schema.sql`
- `bank_accounts(id)` → now defined in `../sta_core_organization/sta_core_organization_schema.sql`
- `profiles(id)` → defined in `../shared_platform/shared_platform_schema.sql`

Fix path (requires approval):
1. Deploy STA Core SQL to org-level project first.
2. Then deploy Mali SQL to its app project with `organizations`/`bank_accounts` available via FK or via `organization_id` mapping.
3. Do NOT run Mali SQL standalone today — FKs will fail.

Table inventory (Mali app domain, group/cooperative):
`union_groups`, `union_members`, `union_contributions`, `union_loans`, `union_group_loans`,
`union_loan_repayments`, `credit_scores`, `credit_score_history`, `risk_assessments`,
`group_banks`, `group_bank_transactions`, `union_share_trading`, `union_dividends`,
`union_savings_accounts`, `union_savings_transactions`, `union_penalty_rules`, `union_penalties`,
`union_meetings`, `union_resolutions`, `union_chart_of_accounts`, `union_journal_entries`,
`union_journal_items`, `union_report_definitions`, `union_reports`, `union_audit_trail`,
`union_compliance`, `union_notifications`, `union_member_applications`, `union_integrations`,
`union_webhook_events`, `union_system_config`, `union_system_logs`
