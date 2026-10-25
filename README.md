# Life Rebuild — Field Notes (ADR-003 Lab)

**Current source baseline:** v0.5 — iPhone safe-area fix (October 25, 2026).  
**Project status:** Fictional-data proof of concept. **Not production approved.**  
**Architecture:** Static PWA on Cloudflare Pages (Direct Upload), Supabase Auth/PostgreSQL.

The app is designed to explore a low-friction, iPhone-first approach for recording proposals, owner decisions, and an audit trail. It does **not** authenticate native ChatGPT specialist conversations and must never treat a claimed origin or supplied advisory review as independent proof of source identity.

## Repository layout

- `site/` — exact static site files from the verified v0.5 deployable ZIP. No compilation required.
- `database/reference/` — **historical bootstrap schema for a disposable fictional test**, **not a migration to run on the existing database**.
- `database/README.md` — deployed migration history and caution about schema drift.
- `docs/` — ADR-003 release-gate assessments; historical governance documents may predate later testing authorization.
- `tests/TESTING.md` — observed tests, limitations, and next security verification.
- `DEPLOYMENT.md` — manual Cloudflare deployment instructions.

## Safety and data boundaries

- Use **fictional records only**. Do not store personal health, finances, family, relationship, children's information, or other real Life Rebuild details.
- Do not commit Supabase passwords, service-role/secret API keys, session tokens, database connection strings with passwords, local-storage exports, backups, or any real personal data.
- Publishable keys are intended for browser clients but there is no reason to hard-code the project's public configuration in this proof-of-concept repository.
- Local browser connection settings and Supabase Auth sessions are not stored in Git.
- No new paid resources, external integrations, autonomous agents, or full RPG are authorized by this repository.
- All consequential application decisions must ultimately be attributed to the **authenticated human owner**; specialist labels and Executive review text are unverified advisory metadata.

## Running locally

In a terminal from the repository folder, run `python -m http.server 8000 -d site` and open `http://localhost:8000`. The app defaults to **LOCAL DEMO** with only fictional in-memory data. A local demo is not a substitute for database permission testing.

## Development priorities

The accepted ADR-003 framework prioritizes G1 (authorization semantics), G2 (cross-user access control), and G4 (backup and restore). The v0.5 mobile display issue is fixed per user testing. Before production consideration, complete the documented release gates and explicitly authorize any expansion beyond fictional test data.
