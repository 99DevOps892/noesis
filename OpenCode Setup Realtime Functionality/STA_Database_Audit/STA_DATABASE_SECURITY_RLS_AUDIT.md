# RLS Audit (local: NO active policies found, only commented examples Mali:1109-1150)
Finding: Schema.db has zero RLS statements. Mali RLS is commented out.
Risk: HIGH - if remote has no RLS, tenant cross-access likely.
Proposed matrix (DO NOT implement without approval):
STA Admin | org scope | approved apps | role-based
Mwarokin Admin | org | Mwarokin | assigned resources
Landlord | org | Mwarokin | owned properties
Tenant | org | Mwarokin | own tenancy only
Public | none | public endpoints | restricted
Required: enable RLS + policies per table + test with auth.uid(), organization_members, application_memberships.
