# Life Rebuild — ADR-003 Readiness Framework v2

**Prepared by:** 07 — Systems & Automation Architect  
**For:** 00 — Executive Life Coach  
**Date:** October 24, 2026 (America/Chicago)  
**Architecture decision:** B+E Lite (Supabase/PostgreSQL + Cloudflare Pages + iPhone-first PWA) provisionally selected.  
**Authority:** Research, specification, and test design only. **No production release, real personal records, additional accounts, code/database/deployment changes, paid services, privileged integrations, autonomous actions, or full RPG work authorized.**

## 1. Incorporation of 00's refinements

1. **Practical authority:** Do **not** claim native ChatGPT specialist or 00 conversation identities have been independently authenticated. For an initial release, the **authenticated human owner** is the authoritative actor for decisions. Text attributed to 00 is **advisory context supplied by the user**, not an authenticated 00 approval. Specialist labels are **claimed origin/routing metadata**, never authorization credentials.
2. **Proportionate release:** Keep essential security, integrity, recoverability, and usability controls for even a small low-sensitivity release; add stronger requirements only when data sensitivity, external privileges, or autonomous consequences justify them. Life Rebuild health, mental-health, finances, family, marriage, and children's information should be presumed sensitive unless explicitly assessed otherwise.
3. **Status wording:** G1 is no longer blocked *on the idea of authenticating 00*; its **trust model is resolved in principle** but implementation, end-to-end verification, and labels are **not yet passed**. G2 and G4 remain unproven beyond the earlier bounded results.

## 2. Initial authority model (G1)

| Item / actor | What the app can verify | What it must **not** infer | Appropriate treatment |
|---|---|---|---|
| Signed-in human owner | Valid Supabase Auth session; server derives `auth.uid()`; authorization checks tied to that owner | That a particular human physically clicked, or that 00 supplied the recommendation | Sole baseline authority to accept, reject, or defer a proposed personal decision. Explicit, deliberate confirmation in UI; log the authenticated user ID, outcome, version, and time. |
| 00 — Executive Life Coach | No independent native conversation identity proof within current prototype | `origin_claimed='00'`, pasted text, or a checkbox proves 00 reviewed anything | Advisory context only, labeled **“00 review as supplied by owner — origin not independently verified.”** |
| Specialist conversation (e.g., 04, 05) | A string such as `origin_claimed='04'` | It is a verified message from that specialist | Treat as **claimed source** or suggested recipient, not as permission to write, approve, or act. |
| Anonymous / another account | Supabase Auth absence or a different validated user ID | Access to another owner's records | Deny other-owner access and all privileged changes. |
| Administrative database role | The operator controls trusted database privileges | Normal user action or immutable, cryptographically sealed history | Restrict and audit separately; recognize that privileged operators can modify records unless further controls exist. |

**Decision semantics:** A saved finding is a proposal. **Owner accepted**, **owner rejected**, and **owner deferred** are authoritative *application dispositions*; they do not mean “00 authenticated approval.” An accepted suggestion is **not automatically** a new real-life commitment, paid purchase, calendar change, or external action. Those require the applicable separate user authorization.

**Design adjustments to evaluate (not implement yet):** Rename the UI/field concept `executive_assessment` to **“Advisory review (user-provided)”**; visually separate claimed origin, advisory source, and authenticated decision maker; ensure API derives the owner identity from the verified session rather than accepting arbitrary `owner_id`; audit `decision_actor_user_id`, prior version, outcome, and timestamp; avoid privileged authorization from user-editable JWT metadata. The current `p_owner_confirmed` boolean is evidence of a submitted assertion, not cryptographic proof of informed consent. Stronger confirmation or recent reauthentication should be considered only for meaningfully consequential operations.

**G1 acceptance — all baseline checks must pass:**
- G1.1 Every material status change has a currently authenticated, server-verified owner, and every updated finding belongs to that owner.
- G1.2 Forged 00 or specialist labels and forged advisory text **do not** grant decision or cross-user permissions; the app never describes them as authenticated identities.
- G1.3 Anonymous and other-user decision calls fail; missing or false owner-confirmation flags fail; all failures leave data unchanged.
- G1.4 Owner-authorized accept/reject/defer records the owner as decision maker and the 00 text only as unverified advisory context. UI wording and audit exports remain accurate.
- G1.5 No workflow silently converts owner acceptance into an actual household commitment or external action.

## 3. Prioritized negative-test specification (G2)

**Test environment:** Disposable fictional records with **two distinct authenticated fictional users A/B and one anonymous client**, or an isolated local test harness that accurately executes Supabase Auth/JWT/RLS context. Create no new account or environment until explicitly authorized. Test through the same API surfaces used by the PWA, not SQL administrator sessions alone. Collect redacted API status/error, before/after row counts, versions, audit events, snapshots, and reproducible test steps. Failed operations must have **zero lasting side effects**.

| ID | Test | Expected result |
|---|---|---|
| G2-01 | A reads A's findings, approved snapshots, audit rows | Only A-owned rows returned; legitimate reads work. |
| G2-02 | B attempts to read A's rows by list query and known record ID | Zero A-owned rows; no cross-user contents disclosed. |
| G2-03 | Anonymous client attempts to read all three tables and invoke both RPCs | No contents disclosed; RPC calls denied. |
| G2-04 | A/B attempt direct INSERT, UPDATE and DELETE in all three tables | Denied, or zero effective rows changed; test must assert persisted state, not only UI “PASS.” |
| G2-05 | B calls `lr03_decide` with A's finding ID; B guesses or supplies other-owner IDs | Denied; A's finding, audit, and snapshot unchanged. |
| G2-06 | A calls `lr03_decide` on pending A record with `p_outcome='system_approved'` | Rejected; remains pending, same version, no new approved/audit rows. **Closes previously skipped diagnostic.** |
| G2-07 | A calls `lr03_decide` with `p_owner_confirmed=false` and with absent confirmation | Rejected; no side effects. |
| G2-08 | A submits duplicate `external_id` within A account | Rejected; one A record and one submission event only. |
| G2-09 | B submits the same `external_id` as A for B's own separate fictional finding | Permitted by current owner-scoped uniqueness; neither user can access the other's row. |
| G2-10 | A retries a valid decision using stale `p_expected_version`; A attempts second approval | Rejected; at most one snapshot and one owner-decision audit for the original decision. |
| G2-11 | Concurrent double approval of one pending finding with the same version | Exactly one wins; no duplicated approval/audit events, no partial transaction. |
| G2-12 | Forged `origin_claimed='00'`, fake Executive prose, altered browser UI / direct RPC call | Text may remain metadata, but cannot grant extra authority. Any UI and export labels must call it unverified. |
| G2-13 | RPC rejection due to oversized/malformed data, invalid specialist code, or missing session | Rejected without partial finding/audit writes; predictable user-facing error. |
| G2-14 | Expired session, sign-out, and session revocation scenarios | No fresh protected operations without acceptable authentication; document refresh/revocation latency and residual token risk. |

**Evaluation nuance:** 00's review authenticity is deliberately **not** the pass/fail criterion. The relevant criterion is **owner authority and honest attribution**. Passing SQL-level GRANT/RLS inspection is **not** sufficient to claim cross-user runtime isolation. `SECURITY DEFINER` RPCs bypass ordinary table RLS, so their ownership and input checks must be independently exercised. The advisor warning on the two exposed RPCs requires focused review, successful tests, and explicit acceptance or redesign before release.

**Existing evidence:** RLS is enabled on all 3 tables; policies use `owner_id = auth.uid()` for authenticated SELECT; direct browser writes lack table privileges. One-owner positive submission/approval passed; direct UPDATE denial and duplicate-ID rejection passed; invalid-outcome check skipped; two-user, anonymous-RPC, concurrency, and session-revocation tests remain unperformed. Current live fictional snapshot: one approved finding (version 2), one approved record, two audit events. **Do not mutate this baseline merely to mark tests complete.**

## 4. Backup, restoration and failure test design (G4)

**Scope:** A backup plan is only credible once a complete **restore has succeeded**. Supabase Free documentation recommends regular CLI logical exports plus off-site backup; do not assume automatic plan backups or point-in-time recovery. A logical export may not recreate Auth users, Supabase project settings, API credentials, or Storage objects; each dependency must be inventoried and verified rather than assumed.

**Proposed baseline test sequence (nothing to execute yet):**
1. Inventory required recoverable assets: database schema/migrations, fictional findings and approved snapshots, audit events, user-ownership mappings, authentication dependencies, PWA deployment artifact and configuration, and any future storage attachments. Mark which items the chosen export omits.
2. Establish a documented, least-privilege logical export method; encrypt a copy and store it **outside the Supabase project**. Confirm backup can be found and decrypted by the authorized owner; avoid storing plaintext credentials in the archive or checklist. Retain a checksum and timestamp.
3. Restore into an **isolated disposable environment** or compatible local Postgres instance. Never restore over the current live prototype. Recreate or remap fictional Auth identities deliberately; verify foreign keys, `owner_id`, schema policies, function grants, and safe test access.
4. Compare source and restored schema version, counts, `external_id`, finding status/version, approved snapshot content, audit event ordering and detail, owner isolation, and post-restore ability to sign in and read the recovered records (or use an authorized equivalent for identities if login cannot be transplanted).
5. Re-run the essential G2 access-denial tests against the restored environment. Verify no accidental public access, leaked tokens, or altered RPC privileges.
6. Simulate network interruption **before** a submission, **after the server commits but before the client receives a response**, and during a rejected decision. Verify UI detects uncertain outcomes, refreshes from canonical database, and retries using a stable idempotency approach without double actions.
7. Measure elapsed restoration time, maximum source-to-backup age, recovery instructions accuracy, and whether a second person can follow the runbook from an encrypted backup without depending on undocumented steps.

**Proposed baseline recovery objectives, subject to later explicit adoption:** Recovery point objective (RPO) **≤24 hours of possible data loss** and recovery time objective (RTO) **≤48 hours** for low-risk records. For sensitive/consequential use, revise targets based on actual harm and prove an appropriately stronger mechanism (rather than silently assuming the free plan meets it).

**G4 acceptance — all baseline checks must pass:**
- One documented backup+restore exercise succeeds on fictional data with integrity and ownership verified; backup exists away from the source project and is access-controlled/encrypted.
- Failure/retry tests produce **no duplicate approvals**, phantom commitments, or mismatched audit/snapshot states.
- Owner can locate recovery instructions and encryption/decryption means without exposing secrets in application code; retention and deletion policy is stated.
- Audits are append-only to routine app roles and distinguish `actor`, action, status/version, and time. Explicitly state that privileged database administrators can alter history; don't claim cryptographic immutability.
- Measured rehearsal meets the **agreed** RPO/RTO and recovery runbook. If it doesn't, G4 stays open.

## 5. Risk-proportionate release scope (refinement 2)

| Scope class | Examples / trigger | Required controls before that scope is used |
|---|---|---|
| **Fictional lab (current)** | Invented ADR-003 findings, no real personal material | Maintain test isolation, project security hygiene, and clear fictional labeling. No release claim. |
| **Baseline low-sensitivity records** | Deliberately minimal, non-sensitive workflow metadata, no health/family/finance detail, no external action | G1, G2, G4 tests **pass**. Also baseline G3: no secret exposure, safe session/storage, clear retention/deletion; G5: reliable sign-in, onboarding and understandable errors; G6: explicit unverified specialist handoff and manual fallback; G7: cost/owner/rollback documented. User and 00 explicitly approve **this limited scope**. |
| **Sensitive personal records** | Health, mental wellbeing, finance, marriage, family, child-related data, revealing habit logs, free-form journal content | All baseline gates **plus** explicit consent and minimization, sensitive-data threat model, encryption/key and backup access, retention/erasure/export, stronger account recovery/session protection, incident response, and privacy review. Separate explicit owner/00 authorization before any real data. |
| **Privileged integrations** | Email/calendar modification, financial service access, third-party account tokens, broad Drive scopes | Above applicable data controls **plus** scoped integration permissions, credential custody/rotation, confirmation for consequential writes, independent revocation and integration-specific tests, incident/rollback plan. Separate explicit authorization for each integration. |
| **Autonomous/consequential actions** | Agent-created tasks or decisions, unattended purchases, automated messages, real commitments | **Out of scope**. Requires a new separately approved authority and safety design; no implicit authorization from this ADR. |

Risk review may reclassify ostensibly “simple” habits or logs as sensitive if they reveal medical, emotional, relationship, financial or child-related details. The baseline is **not** a shortcut for loading real Life Rebuild history.

## 6. Seven-gate checklist — v2 status

| Gate | Baseline acceptance summary | Additional escalation | Status |
|---|---|---|---|
| **G1 Identity/authority** | Verified owner session and owner-only decision; claimed origin and 00 advisory context consistently labeled; no silent commitments | Step-up/independent authorization for consequential external actions | **Design direction accepted; tests pending** |
| **G2 Database/RLS/RPC** | Full fictional two-user/anon allow-deny suite, including invalid outcome, concurrency, cross-owner RPC and immutable state checks | Isolation for additional roles, tenants, connected services, and higher-risk data | **Partial evidence only** |
| **G3 Privacy/client** | No browser secrets, dependency pinning, session/storage review, minimization and basic retention/deletion | Sensitive-data audit, export/erasure, recovery, stronger privacy and threat modeling | **Not complete** |
| **G4 Backup/recovery/audit** | Encrypted off-project backup; successful isolated restore, owner mapping, audit validation, measured RPO/RTO | Stronger retention, encrypted access separation, recovery objectives and tamper-evidence as needed | **Plan specified; not tested** |
| **G5 iPhone UX** | One-time normal login, known configuration, accessible errors, correct sizing, fresh-install data consistency | Enhanced privacy in notifications/offline data and accessibility as relevant | **Positive UX; onboarding friction remains** |
| **G6 Specialist handoffs** | Unverified claims and manual fallback clearly documented; only authorized owner can adopt proposals | Authentic third-party service identity only if verified supported methods exist | **Connector boundary not proven** |
| **G7 Cost/ops/governance** | Cost estimate, ownership, update/rollback process, explicit limited-scope release approval | Integration/API volume, incident operations, paid tier and autonomous scope separately authorized | **Partial** |

**Initial release decision rule:** No real content until **every baseline control** applicable to the specifically proposed low-sensitivity scope has measured PASS evidence, and the owner and 00 explicitly authorize that scope. High-risk features do **not** need to be built for a low-risk release, but neither does approving a low-risk release permit sensitive or privileged use.

## 7. Decisions and permissions

**Resolved by 00:** B+E Lite provisional, the owner as authoritative decision maker for initial releases, 00 review advisory only, risk-tiered controls, fictional-only evaluation, G1/G2/G4 priority.

**No new executive decision currently needed:** The authority design direction is clear enough to specify tests; the documented test plans do not grant permission to perform them.

**Authorization required before execution:** Additional Supabase/Auth accounts or test environment, changes to deployed app/database, backup export or restore against a real service, paid services, real personal records, operational integrations. Request these only when the specific next test's necessity, safeguards, cost, and rollback are clear.

**Next work within existing delegation:** Review current schema and client against this model; develop self-contained test vectors and evidence templates; document recovery dependencies; minimize the future implementation package. Escalate only a meaningful design conflict, expenditure, authorization need, or unacceptable security risk.

## Documentation used (consulted October 24, 2026)

- [Supabase RLS](https://supabase.com/docs/guides/database/postgres/row-level-security)
- [Supabase database testing](https://supabase.com/docs/guides/database/testing)
- [Supabase platform backups](https://supabase.com/docs/guides/platform/backups)
- [Supabase database functions](https://supabase.com/docs/guides/database/functions)
- [Supabase CLI database dump](https://supabase.com/docs/reference/cli/supabase-db-dump)

**Evidence interpretation:** This is an updated specification and read-only review of the fictional prototype, not evidence that the new tests were run or that production is safe. The seven gates remain open to the degree shown above.
