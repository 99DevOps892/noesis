# Risk Register
R-01 HIGH: Pushing STA Core SQL to wrong project (spnerrqumefbuuscumhw) would re-merge domains. Mitigation: new project under iyngtxvchqpeayvsuvph only.
R-02 HIGH: Running Mali SQL standalone fails (missing FK targets). Mitigation: deploy core first.
R-03 HIGH: Adding organization_id/application_id to live tables locks/requires backfill. Mitigation: nullable cols + backfill + validate + RLS after approval.
R-04 MEDIUM: No migration history - remote may diverge. Mitigation: supabase db pull before any push.
R-05 MEDIUM: profiles.role change breaks app auth. Mitigation: add new role system alongside, don't alter enum yet.
R-06 LOW: File duplication confusion. Mitigation: originals untouched, derived files only in STA_Supabase_Separation/.
