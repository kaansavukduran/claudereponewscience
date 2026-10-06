# ADR-IMPL-001 — TypeScript monorepo with one shared deterministic core

Status: ACCEPTED (v0.25 implementation bootstrap) · Supersedes nothing · Deviation from handoff preference recorded here as required by BUILD prompt V0.5.

## Context

The v0.24 handoff prefers Flutter/Dart for the client and leaves backend choice open. It also requires the Site Lab and the production app to share CORE_DERIVED semantics and golden vectors (FR-200, v0.17/v0.19 parity).

The execution environment for this bootstrap has Node 22, Python 3.13, PostgreSQL 16 binaries and Chromium. It has **no Flutter/Dart toolchain, no Android SDK, and Google Maven (dl.google.com) is blocked by the network policy**. No Xcode (Linux).

## Decision

- One pnpm workspace, TypeScript everywhere, so the **same compiled-free source** (`packages/domain`) runs in the Site Lab (browser), the production client (browser / Capacitor WebView) and the API (Node ≥22.18 native type stripping). One implementation instead of three ports is the strongest available parity guarantee.
- An independent Python port (`tools/verify_contracts.py`) re-executes the same golden vectors, so arithmetic is still cross-checked by a second implementation.
- Client: React 19 + Vite; native Android/iOS via Capacitor 8 shells over the same build.
- API: Node `node:http` + `node:sqlite` (zero runtime dependencies), append-only checksummed SQL migrations, owner authorization from server session, Idempotency-Key receipts, If-Match revisions, stable error envelope.
- Local client store: IndexedDB on web behind a `DocumentStore` interface; native release must swap in a SQLite-backed store (not done; see RELEASE_STATUS).

## Consequences

- Flutter preference is not followed. Product semantics remain normative (Reference Implementation precedence rule) and are enforced by vectors/tests, not by framework.
- Profiles persist body inputs as JSON (`inputs_json`) in the bootstrap kernel. Searchable canonical facts (labs) have real columns. Splitting body inputs into `health_facts` rows with corrections/history is a follow-up (FR-22/FR-26).
- `node:sqlite` is flagged experimental in Node 22; acceptable for bootstrap; production server should target PostgreSQL (`database_blueprints/postgres_reference.sql` semantics) with RLS — NOT_RUN.
- Dev-session auth is a placeholder and is disabled when `HHOS_ENV=production`.
