# Contamination Audit
C-01 HIGH: Global identity uses property roles (profiles.role). Evidence Schema.db:8. Impact: STA admin forced into tenant/landlord. Fix: separate STA roles table (done in sta_core), migrate later.
C-02 HIGH: Mali dangling FKs to organizations/bank_accounts. Evidence Mali :19,46. Impact: cannot deploy standalone. Fix: STA Core SQL now defines them.
C-03 MEDIUM: platform_fee inside rent payments. Evidence Schema.db:109-110. Impact: STA revenue tied to lease. Fix: keep rent table, add subscriptions table in core.
C-04 MEDIUM: Shared notify/audit have no org/app scope. Impact: cross-app leak risk. Fix: add columns only after approval + RLS.
C-05 LOW: Naming - tenants means property tenants, collides with SaaS tenant. Fix: document, don't rename yet.
