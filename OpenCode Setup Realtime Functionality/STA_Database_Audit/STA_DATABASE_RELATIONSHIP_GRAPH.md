# Relationship Graph (actual FKs)
profiles(id) <- properties.agent_id, tenants.user_id, leases.landlord_id, payments.landlord_id, documents.uploaded_by, comm_profiles.user_id, message_queue.*, notifications.user_id, outreach_campaigns.created_by, user_behavior.user_id.
properties(id) <- leases.property_id, payments.property_id, maintenance.property_id, documents.property_id, price_localization.property_id, user_behavior.property_id, property_views.property_id.
tenants(id) <- leases.tenant_id, payments.tenant_id, maintenance.tenant_id, documents.tenant_id.
leases(id) <- payments.lease_id, documents.lease_id.
Mali: union_groups(id) <- all union_*; union_members(id) <- loans/repayments/scores; profiles/organizations/bank_accounts referenced but undefined = dangling.
No organization_id/application_id edges anywhere = no multi-tenancy.
