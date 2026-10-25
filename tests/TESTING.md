# ADR-003 testing status

## Confirmed on live fictional test prototype

- Password authentication; user-confirmed connection from desktop, iPhone Safari, and installed Home Screen app.
- Fictional `ADR003-001` submitted, status became `pending`, then owner-attested decision yielded status `approved`, version 2.
- Approved snapshot created; audit had submission and owner-decision event.
- Duplicate finding ID rejected by database unique constraint.
- Browser diagnostic direct table UPDATE rejected.
- Browser diagnostic duplicate ID rejected; invalid status case was SKIPPED because no pending finding existed.
- Three tables have owner-scoped SELECT RLS policies and no direct table writes for normal authenticated clients, based on read-only database inspection.
- v0.5 PWA safe-area fix visually accepted on the owner's iPhone.

## Not proven / release gates

- Actual isolation between **two distinct authenticated users** (additional fictional account authorized by user, creation and testing still pending).
- Invalid-outcome RPC with a pending record and unchanged-data assertions.
- Forged origins, false confirmation, replay/concurrent decisions across users via API.
- Credential/session lifecycle, user-revocation handling and threat modeling.
- Encrypted off-project backup with tested isolated restore and audit verification.
- Trustworthy attribution: claimed `origin_claimed` is not authenticated, and `executive_assessment` is owner-provided text.
- Privacy, hardening, monitoring, and actual baseline operating-cost validation.

Consult `docs/ADR003_Readiness_Framework_v2.md` for the accepted G1/G2/G4 test definitions.

**All verification must use fictional data until explicit authorization says otherwise.**
