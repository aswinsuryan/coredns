# CoreDNS Rebase Report: v1.13.1 → v1.14.7

## Section 1: Overview

- **Current CoreDNS version**: v1.13.1
- **Target rebase version**: v1.14.7
- **Upstream commits between versions**: 631 (216 of those land between v1.14.4 and v1.14.7)
- **Merge helper strategy**: `git merge --no-ff --strategy=ours upstream/main` — establishes ancestry from `upstream/main` (37aaba896) so the PR diffs cleanly. File content comes from v1.14.7; carries are cherry-picked on top.

This supersedes the earlier v1.14.4 rebase (PR #197). That branch was hard-reset and this rebase redone directly against v1.14.7 so the fork picks up v1.14.5–v1.14.7 in the same pass, rather than rebasing twice.

## Section 2: Carry Audit & Consolidation Plan

### Commits on upstream/main since v1.13.1

| Commit | Subject | Classification | Action |
|--------|---------|---------------|--------|
| fdb17cd00 | Add aswinsuryan to OWNERS | **Still needed** | Squashed with f523fe565 into single OWNERS carry |
| f523fe565 | Update OWNERS | **Still needed** | Squashed with fdb17cd00 |
| b06f0e0cb | add ocp_dnsnameresolver plugin | **Still needed** | Reapplied with same module version (01fb3d1, k8s v0.36.2) |
| 7a4db4ba4, 8eab9cb1d, 6b897ee50 | Old ocp_dnsnameresolver carries | **Obsoleted** | Folded into b06f0e0cb on an earlier rebase |
| 520270037 | Bump gRPC to v1.79.3 (CVE-2026-33186) | **Already upstream** | Dropped — v1.14.7 ships grpc v1.83.0 |
| b3960579c | Bump golang.org/x/net to v0.53.0 (GO-2026-4918) | **Already upstream** | Dropped — v1.14.7 ships x/net v0.57.0 |
| 33fcf0c60 | Bump expr to v1.17.7 (GO-2025-4245) | **Already upstream** | Dropped — v1.14.7 ships expr v1.17.8 |
| c3b27d53f, ae729982a | ART image sync commits | **Skip** | Let ART bot resubmit after merge |
| 486112b6c | fix(tls): use Go TLS defaults | **Already upstream** | Dropped — landed upstream as bc4343b08 (#8227), included in v1.14.7 |
| 62c0e7e7b | Align Go version files to -1.26 | **Still needed** | Reapplied against v1.14.7's own `.go-version` (1.26.6) |

### Carries reapplied (order of application)

1. `UPSTREAM: <carry>: openshift: Update OWNERS`
2. `UPSTREAM: <carry>: openshift: Disable dependabot` — resolved a modify/delete conflict by keeping the deletion
3. `UPSTREAM: <carry>: openshift: Track vendor directory in git`
4. `UPSTREAM: <carry>: openshift: Add make test target and set GOTOOLCHAIN=local`
5. `UPSTREAM: <carry>: openshift: Align Go version files to 1.26 builder images` — go.mod → 1.26.6, plus 3 vet fixes (`%q`→`%d` on int args) in `plugin/dns64/dns64_test.go`, `plugin/file/secondary_test.go`, `plugin/test/helpers.go`
6. `UPSTREAM: <carry>: openshift: add ocp_dnsnameresolver plugin`
7. `UPSTREAM: <carry>: openshift: update vendor`

**Dropped relative to the v1.14.4 attempt**: the TLS-defaults cherry-pick (`UPSTREAM: 8227:`) is no longer needed — v1.14.7 already ships that fix upstream (`bc4343b08`, PR #8227).

## Section 3: Execution Log

### Preparation

- `git fetch upstream --tags` / `git fetch coredns-upstream --tags` — confirmed `v1.14.7` is the latest tag and `upstream/main` (openshift/coredns) is unchanged at `37aaba896` since the v1.14.4 attempt.
- Hard-reset `NE-2790-rebase-coredns-v1.14.4` to `main`, discarding the prior v1.14.4-based commits, then reset to the `v1.14.7` tag as the new base.
- `git merge --no-ff --strategy=ours upstream/main` — verified empty diff against parent 1 (v1.14.7 tree preserved) and a large diff against parent 2 (correct `-s ours` behavior).

### Conflicts Resolved

| Commit | File | Type | Resolution | Details |
|--------|------|------|------------|---------|
| Disable dependabot carry | `.github/dependabot.yml` | modify/delete | resolved | Upstream modified the file between v1.14.4 and v1.14.7; carry intent is deletion, so the delete was kept. |
| ocp_dnsnameresolver carry | `go.mod` | content | resolved | Upstream had already moved several deps (x/crypto, x/sys, grpc, api, protobuf) past the versions pinned in the old v1.14.4 carry. Kept v1.14.7's newer versions, added the k8s v0.35.4→v0.36.2 bump and the new module requirement, then ran `go mod tidy` to reconcile (it further adjusted `google.golang.org/protobuf` to a newer pseudo-version and dropped an unneeded `mailru/easyjson` indirect entry). |
| ocp_dnsnameresolver carry | `plugin.cfg`, `core/dnsserver/zdirectives.go` | content | resolved | Upstream reordered `plugin.cfg` since v1.14.4: `cache`/`autopath` swapped relative to `acl`, and `tls` moved from near the top of the chain (next to `proxyproto`/`quic`) down to just after `dnssec`, with a new comment — "Keep tls here so dnssec can sign ACME challenge records before authoritative backends run." (`header` was already present in the chain at v1.14.4; it did not move.) Inserted `ocp_dnsnameresolver` immediately before the (relocated) `cache` entry; `go generate coredns.go` confirmed the manual resolution matched the generated output exactly. |

### Skipped Commits

| Commit | Subject | Reason |
|--------|---------|--------|
| 486112b6c | fix(tls): use Go TLS defaults | Already upstream in v1.14.7 as `bc4343b08` (#8227) |
| 520270037 | Bump gRPC to v1.79.3 (CVE-2026-33186) | Already upstream — v1.14.7 ships grpc v1.83.0 |
| b3960579c | Bump golang.org/x/net to v0.53.0 | Already upstream — v1.14.7 ships x/net v0.57.0 |
| 33fcf0c60 | Bump expr to v1.17.7 | Already upstream — v1.14.7 ships expr v1.17.8 |
| c3b27d53f, ae729982a | ART image sync commits | ART bot will resubmit after merge |
| 7a4db4ba4, 8eab9cb1d, 6b897ee50 | Old ocp_dnsnameresolver carries | Already consolidated into a single carry on an earlier rebase |

### Squashed Commits

| Into | Squashed | Reason |
|------|----------|--------|
| `UPSTREAM: <carry>: openshift: Update OWNERS` | f523fe565 + fdb17cd00 | Both modify OWNERS; combined into a single carry |

### User Feedback

- User asked to redo this rebase targeting v1.14.7 instead of v1.14.4, since PR #197 (v1.14.4) hadn't merged yet — "skip 1.14.4, move straight to 1.14.7."
- User wants the result in the same commit shape/order as PR #197 so the diff is easy to review, and will force-push this branch over PR #197 themselves (branch name mismatch is fine).
- User asked for a genuinely fresh redo (hard reset + re-run of `/rebase`) rather than patching the existing draft branch, to avoid trusting unverified intermediate work. Carries were re-sourced from the already-reviewed PR #197 commits (cherry-picked and adapted) rather than from any draft.
- No known blockers or special carry instructions beyond "standard carries, drop TLS-defaults since already upstream" (confirmed via direct question before executing).

## Section 4: Risk Assessment

### Upstream changes (v1.14.4 → v1.14.7)

v1.14.5–v1.14.7 (216 commits) add: `source_address` for forward, secondary catalog member zones, ACME DNS-01 certificate management in `plugin/tls`, `prefer_positive`/configurable stale-TTL cache policies, a new `shed` plugin for UDP overload protection, DoH support in forward, DoQ/DoH3 connection-level concurrency limits, and numerous `kubernetes`/`file`/`rewrite`/`cache` correctness fixes. Go itself moved to 1.26.6 upstream (`.go-version`), though `go.mod`'s minimum stayed at 1.25.0 until this carry aligned it.

### Breaking changes

None explicit. Continued tightening of config validation (unknown block options rejected in several plugins) carries forward from v1.14.4.

### Dependency updates

| Dependency | v1.13.1 | v1.14.7 | Final (after carries) |
|------------|---------|---------|----------------------|
| k8s.io/api, apimachinery, client-go | v0.31.4 | v0.35.4 | v0.36.2 (MVS from ocp_dnsnameresolver) |
| github.com/miekg/dns | v1.1.68 | v1.1.72 | v1.1.72 |
| google.golang.org/grpc | v1.68.0 | v1.83.0 | v1.83.0 |
| golang.org/x/net | v0.33.0 | v0.57.0 | v0.57.0 |
| Go minimum version (go.mod) | 1.24.0 | 1.25.0 | 1.26.6 (Go alignment carry, matches upstream `.go-version`) |

### Toolchain changes

- `go.mod`'s `go` directive bumped to 1.26.6 to match v1.14.7's own `.go-version` pin.
- **Flag for CI verification**: confirm the ci-operator builder image has Go ≥1.26.6 available before merging — `GOTOOLCHAIN=local` (the downstream carry policy) will fail the build otherwise. This machine had 1.26.6 cached locally (used for all validation below) but not as its default `go` binary, which is a useful reminder this is worth double-checking against the actual builder image rather than assuming.

### Testing hotspots

- `ocp_dnsnameresolver` compatibility with k8s v0.36.2
- `plugin/tls` (new ACME DNS-01 support landed upstream since v1.14.4)
- `plugin/cache` (stale-policy and TTL changes across v1.14.5–v1.14.7)
- `plugin/forward` (DoH support, source_address, cap on default connect attempts)

### Build/test results

- **Build**: ✅ `CGO_ENABLED=0 GOFLAGS=-mod=vendor go build` succeeded.
- **Vet**: ✅ `GOFLAGS=-mod=vendor go vet ./...` clean (no `%q`-on-int findings after the alignment carry).
- **Tests**: ✅ `GOFLAGS=-mod=vendor go test -count=1 ./...` — all packages pass except two pre-existing, environment-only failures unrelated to any carry: `test.TestCacheACLAuthorization` (fails locally because this machine can't bind the `127.0.0.2` loopback alias the test expects) and `test.TestPrometheusImports` (skipped — `faillint` binary not installed locally). Neither originates in the OpenShift carries.

See [Stakeholder Review](rebase_v1.14.7_stakeholder_review.md) for detailed upstream analysis.
