# Database — fictional-only historical reference

This folder does **not** contain a complete, reconciled schema snapshot of the live Supabase project. **Do not apply `bootstrap_schema_v02_REFERENCE_ONLY.sql` to the existing project.** It is retained solely to preserve the initial design as a reference.

The live Supabase project previously received these two recorded migrations:

1. `20261025033454_adr003_fictional_test_schema_v02` — initial fictional tables, policies, and RPCs.
2. `20261025033515_adr003_restrict_auto_rls_trigger_execute` — revoked exposed execute privileges from the auto-RLS event-trigger helper.

The reference SQL describes the initial tables/RPCs but does **not** include the follow-up helper privilege fix or unrecorded platform-managed database configuration. Before building executable migrations or recovery automation, pull/reconcile the actual database schema under an explicitly authorized test plan, then validate on an isolated environment.

Never commit database passwords, auth tokens, service-role keys, or real records.
