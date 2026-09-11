# Domain Map
STA CORE (A, to be created in org project): organizations, organization_members, organization_roles, organization_settings, applications, application_memberships, billing_plans, subscriptions, sta_audit_events, bank_accounts.
SHARED (B): profiles, platform_settings, communication_profiles, message_queue, notifications, i18n (languages/translations/currencies/rates), audit_logs, prospects/outreach.
MWAROKIN (C): properties, tenants, leases, payments, maintenance_requests, documents, property_views, price_localization, user_behavior.
MALI (C-app2): union_* + credit/risk/banks/savings/meetings/reports.
SYSTEM (E): auth.users (referenced, not defined locally).
