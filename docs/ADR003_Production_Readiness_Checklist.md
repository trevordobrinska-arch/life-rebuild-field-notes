# Life Rebuild — ADR-003 Production-Readiness Checklist

**Owner:** 07 — Systems & Automation Architect  
**Reviewer:** 00 — Executive Life Coach  
**Date:** October 24, 2026 (America/Chicago)  
**Decision:** B+E Lite (Supabase/PostgreSQL + Cloudflare Pages + iPhone-first PWA) provisionally selected; **production use NOT authorized**.  
**Scope:** Fictional records only. No new spending, integrations, live personal information, or RPG implementation.

## Evidence baseline (verified; not a production security certification)

- Supabase's live project holds **one approved fictional finding, one approved snapshot, and two audit events**, with finding `ADR003-001` still `approved` at version 2 after diagnostics.
- RLS is enabled on all three tables. Current authenticated SELECT policies require `owner_id = auth.uid()`; anonymous table read privileges are absent, as are authenticated direct INSERT/UPDATE/DELETE privileges.
- User-reported browser tests: direct UPDATE denied (**PASS**), duplicate ID rejected (**PASS**), invalid decision status (**SKIPPED**, no pending finding).
- iPhone Home Screen app has been used successfully with live connected data; user described usability positively; horizontal-scroll bug fixed in v0.4.
- Supabase security advisor still warns that `lr03_submit` and `lr03_decide` are exposed `SECURITY DEFINER` RPCs callable by authenticated users. This is intentional for the fictional test, **not** proof of independent Executive/specialist authority. Advisor also flags disabled leaked-password protection.
- App v0.4 uses a CSP and browser-safe publishable key, but loads `@supabase/supabase-js@2` without an exact package version or SRI. Local configuration and browser sessions are per-installation.

## Mandatory release gates — explicit acceptance criteria

| ID | Gate | Acceptance criteria (all required) | Current status |
|---|---|---|---|
| **G1** | **Identity, roles and decision authority** | Document a threat model and role matrix for owner, Executive reviewer, specialist origin, and anonymous user. Every approved decision is authorized by a **server-verified** role or deliberate owner review *clearly labeled as owner review*; `origin_claimed`, UI checkboxes and user-editable JWT metadata can never confer authority. Untrusted callers cannot promote pending records or impersonate specialist identity. | **BLOCKED** — prototype permits owner self-attestation; verified 00 identity is not implemented. |
| **G2** | **RLS and RPC negative tests** | With at least two isolated **fictional** user accounts and an anonymous client, execute API-level allow/deny matrix: own-row read allowed, another user's row invisible, anon denied, direct writes denied, privileged RPC restricted to permitted owner/role, duplicate ID denied, invalid status denied, stale version denied, repeat approval denied. Verify no unintended data or audit mutations after failed calls. Save repeatable test results. | **PARTIAL** — one-user positive flow and two diagnostics passed; cross-user and invalid-status checks outstanding. |
| **G3** | **Sensitive information and client hardening** | Define data categories, retention/deletion rules, least-privilege permissions, access revocation, export, and incident response before any real health, family, financial or relationship content. No secrets or service-role keys in browser/app logs; verify session handling and token revocation tests. Pin third-party dependency versions (prefer self-hosted immutable bundles or SRI), review CSP and offline-cache behavior, check advisor warnings with documented remediation or explicit risk acceptance. | **NOT READY** — fictional-only handling; security review incomplete. |
| **G4** | **Backup, restore, audit and failure recovery** | Select a permitted, repeatable backup approach with off-project encrypted copies; conduct a **fictional** full restore into a clean test environment, verifying findings, approved snapshots, ownership, and audit ordering/content. Document who can alter audit records, how privileged changes are detected, and how audit retention is protected. Declare and meet recovery objectives (**proposed**: ≤24 h potential data loss and ≤24 h restoration time; Executive may revise). Test network outage, duplicate retries, and partially completed operations; record recovery steps and responsible owner. | **NOT TESTED** — Supabase Free lacks a supported automatic backup/restore entitlement. |
| **G5** | **iPhone onboarding and usability** | On a fresh Safari install and Home Screen installation, sign in without manual entry of backend URLs/keys, recover from sign-in failure, reliably load live records, and avoid horizontal scrolling at supported viewport widths. Zero real/sensitive test data. User completes each path without developer assistance; error messages are user-friendly. | **PARTIAL** — PWA appearance and cross-device visibility passed; manual per-install setup and raw database errors remain. |
| **G6** | **ChatGPT and specialist handoff integrity** | Document which ChatGPT plugin/connector actions actually work from 00 and specialists, and where automation or distinct actor identity is unavailable. Demonstrate fictional source → authenticated handoff → reviewer decision → destination retrieval, without assuming conversations share state or treating text labels as identity. Define a human-mediated fallback for unavailable connectors. | **PARTIAL** — Option A connector handoff worked; B+E database workflow worked; end-to-end authenticated multi-specialist path not proved. |
| **G7** | **Costs, maintenance, and release governance** | Document $0 prototype and realistic production scenarios with usage thresholds, email delivery limits, free-tier pausing, backup choices, ownership, deployment rollback, dependency update cadence and account recovery. Confirm any cost or external-service commitments explicitly with owner/00. Secure a signed-off go/no-go review after G1–G6 all pass; no real data before that. | **PARTIAL** — documented current service limits; operational ownership and recovery untested. |

## Cost/operations facts to carry forward (no purchase authorized)

- **Supabase Free**: $0 per month, 500 MB database, 5 GB egress, projects pause after a week of inactivity, and automatic backups are **not included**. Pro starts at **$25/month** and includes 7 days of daily backups; extra usage and features may cost more. A paid tier is **not** automatically required for further fictional testing.
- Supabase's built-in Auth email service is limited to **2 emails/hour per project**, and is described as non-production. Password sign-in resolved the immediate fictional multi-device test, not overall account recovery/email operations.
- **Cloudflare Pages** static asset requests are free and unlimited. Free Pages has service/build limits (e.g. 500 builds/month); any added Functions/Workers usage must be budgeted separately.
- **Source:** https://supabase.com/pricing ; https://supabase.com/docs/guides/platform/backups ; https://supabase.com/docs/guides/auth/rate-limits ; https://developers.cloudflare.com/pages/functions/pricing/ ; https://developers.cloudflare.com/pages/platform/limits/

## Next bounded evaluation sequence (research/test plan; not a deployment order)

1. **Highest priority: G1 authority model.** Write the trust-boundary/role matrix and explicitly choose how 00 review is authenticated. This is a strategic design question to escalate when options/tradeoffs are ready.
2. **Then G2 negative security tests.** Use a second fictional identity in a controlled test setup; complete the skipped invalid-outcome test and prove cross-user isolation plus RPC behavior.
3. **Then G4 recovery rehearsal design.** Specify backup storage, verification and restoration without incurring costs or changing live records.
4. Assess G3/G5/G6/G7 in parallel on paper, minimizing new UI/features. Present unresolved financial, privacy or integration choices to 00 only when materially necessary.

**Exit rule:** G1–G7 must each have reproducible PASS evidence and explicit 00/owner sign-off before the architecture stores actual personal data, creates real commitments, or enables autonomous operations.
