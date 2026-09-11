# Target Architecture
STA (org iyngtxvchqpeayvsuvph project): organizations, members, roles, applications, subscriptions, sta_audit_events, bank_accounts.
Shared lib (per-project): profiles, notifications, message_queue, i18n, audit pattern.
Apps: Mwarokin (spnerrqumefbuuscumhw): properties/tenants/leases/payments/maintenance. Mali (vfkqjapegrhdsrlmmiih): union_*. Future: SylloPay, SylloVibe, SAICOS, Noesis.
Isolation: organization_id + application_id + RLS. Events via bus, not direct cross-DB FKs.
