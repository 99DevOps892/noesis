# A. Executive Finding
Architecture is PARTIALLY CONTAMINATED (Situation B+E): STA+Mwarokin mixed, no org root, Mali file has dangling FKs. Not heavily Mwarokin-centric yet because no remote evidence that global tables depend on property tables - but local identity IS property-scoped.
# B. Discovery Summary (verified)
- Schema.db:1-363 read: 23 tables.
- Mali Access Union Schema.sql:1-1150 read: 30+ tables, refs organizations/bank_accounts/profiles undefined.
- OpenCode setup.js:241-249: MCP wired to spnerrqumefbuuscumhw.
- No supabase/, migrations/, .env locally.
# C. Unknowns
Remote schema, RLS, logs, storage, Edge Functions, cron, realtime, row counts, auth config - cannot verify from dashboard links alone. Need supabase link + db pull.
# D. Current Domain Map (actual)
Mwarokin(C): properties, tenants, leases, payments, maintenance_requests, documents, property_views, property_price_localization, user_behavior.
Shared(B): profiles, platform_settings, communication_profiles, message_queue, notifications, supported_languages, translations, supported_currencies, exchange_rates, audit_logs, prospects, outreach_campaigns, outreach_threads.
Mali(C-app): all union_*, credit_scores, group_banks, etc.
Missing(A): organizations, applications, subscriptions.
# E. Risk Assessment
HIGH: profiles.role property-only; payments.platform_fee tied to lease; Mali FKs fail standalone; no organization_id/application_id; no RLS verified; no migration history.
# F. Target
STA org -> applications (Mwarokin, Mali, SylloPay...) -> shared platform -> app modules. See TARGET_ARCHITECTURE doc.
# G. Migration Strategy
Inventory done. Freeze unplanned changes. supabase db pull to baseline. Deploy STA Core to NEW org project iyngtxvchqpeayvsuvph. Keep spnerrqumefbuuscumhw as Mwarokin. Add tenancy cols only after approval. Deprecate, don't drop.
# H. Approval Required
Any DROP/rename, RLS change, FK change, financial table change, auth change, prod push, Mali FK wiring, adding organization_id/application_id.
