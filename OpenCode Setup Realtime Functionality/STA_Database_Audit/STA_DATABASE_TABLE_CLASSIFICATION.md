# Table Classification (evidence-based, local only)
| Table | Purpose | Proposed Domain | Evidence | Risk | Action |
| profiles | identity but role=tenant/landlord only | B (fix roles) | Schema.db:8 | high | split STA roles vs property roles |
| properties/tenants/leases/payments/maintenance/documents | real estate | C Mwarokin | Schema.db:22-168 | low | keep in spnerrqumefbuuscumhw |
| platform_settings/message_queue/notifications/comm_profiles | messaging/settings | B shared | Schema.db:90-221 | medium | extract to shared lib |
| languages/translations/currencies/rates/price_localization | i18n | B shared | Schema.db:222-274 | low | shared |
| audit_logs/user_behavior/property_views/prospects/outreach_* | audit/crm | B shared | Schema.db:275-363 | medium | shared, add org/app id later |
| union_* (30+) | SACCO/chama | C Mali | Mali .sql | medium | keep in vfkqjapegrhdsrlmmiih, wire FKs |
| organizations/bank_accounts (missing) | org root | A STA Core | Mali refs :19,46-47, undefined | high | created in sta_core SQL |
