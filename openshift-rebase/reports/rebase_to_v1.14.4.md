# CoreDNS Rebase to v1.14.4

## Overview

| | Current | Target |
|---|---|---|
| CoreDNS version | v1.13.1 | **v1.14.4** |
| Kubernetes client libs (`k8s.io/api`, `apimachinery`, `client-go`) | v0.34.1 | **v0.36.2** (pulled up by `ocp_dnsnameresolver` plugin) |
| Go module directive (`go.mod`) | go1.25.0 | **go1.26.0** |
| Upstream `.go-version` | 1.24.6 | 1.26.3 (downstream uses `GOTOOLCHAIN=local`) |
| `k8s.io/klog/v2` | v2.130.1 | v2.140.0 |
| `sigs.k8s.io/mcs-api` | v0.3.0 | v0.5.0 |

**Divergence:** `main` was 205 commits ahead and 415 commits behind `v1.14.4` relative to merge-base `1db4568df`.

**Merge helper strategy:** Branch from `v1.14.4`, create `git merge --no-ff --strategy=ours origin/main` commit, then reapply carries after the merge helper.

## Carry Audit & Consolidation Plan

7 non-merge downstream commits since the v1.13.1 rebase (merge helper `7486e9e43`):

| Commit | Message | Classification | Action |
|---|---|---|---|
| `c89ce0134` | ART image metadata sync for 4.22 | still needed | Skip — let ART bot resubmit against rebased branch |
| `f523fe565` | Add team members to OWNERS | still needed | Squash with `fdb17cd00` into one commit |
| `ae729982a` | ART image metadata sync for 4.22 | still needed | Skip — let ART bot resubmit against rebased branch |
| `520270037` | Bump gRPC to v1.79.3 (CVE-2026-33186) | already upstream | Drop — v1.14.4 ships gRPC v1.81.1 |
| `33fcf0c60` | Bump expr-lang/expr to v1.17.7 | already upstream | Drop — v1.14.4 ships v1.17.8 |
| `b3960579c` | Bump golang.org/x/net to v0.53.0 | already upstream | Drop — v1.14.4 ships v0.55.0 |
| `fdb17cd00` | Add aswinsuryan to OWNERS | still needed | Squash with `f523fe565` |

**Standing carries reapplied:**
- OWNERS file (squashed)
- Dependabot disablement (delete `.github/dependabot.yml`)
- `.gitignore` vendor tracking (remove `vendor/` ignore line)
- `make test` target + `GOTOOLCHAIN=local`
- `ocp_dnsnameresolver` plugin in `plugin.cfg` before `cache` (pinned to `@01fb3d1`)
- Format verb fixes in test helpers (`%q` → `%d` for numeric types)
- Vendor tree regeneration

## Execution Log

**Conflicts Resolved:** None — clean rebase with no conflicts.

**Skipped Commits:**
- `c89ce0134` — ART image sync: let bot resubmit against rebased branch
- `ae729982a` — ART image sync: let bot resubmit against rebased branch
- `520270037` — gRPC v1.79.3 bump: superseded by v1.81.1 in upstream v1.14.4
- `33fcf0c60` — expr-lang v1.17.7 bump: superseded by v1.17.8 in upstream v1.14.4
- `b3960579c` — golang.org/x/net v0.53.0 bump: superseded by v0.55.0 in upstream v1.14.4

**Squashed Commits:**
- `f523fe565` + `fdb17cd00` → single `UPSTREAM: <carry>: openshift: Update OWNERS`

**User Feedback:**
- User confirmed target version v1.14.4 (v1.14.5/v1.14.6 available but Jira specifies v1.14.4)
- User accepted k8s v0.36.2 pull-up from `ocp_dnsnameresolver` plugin (no v0.35.x release exists for the plugin)
- Pre-existing upstream test format verb bugs (`%q` on numeric types) found in 3 files; user confirmed fix

## Risk Assessment

- **k8s v0.36.2 pull-up:** The `ocp_dnsnameresolver` plugin uses k8s v0.36.2 while upstream CoreDNS v1.14.4 targets v0.35.4. Go MVS pulls k8s up to v0.36.2 in the final binary. Build and all tests pass. Upstream CoreDNS has not officially adopted k8s 1.36 yet (PR #8087 still draft).
- **Go module directive bump:** `go 1.25.0` → `go 1.26.0`. Verify ART builder images support Go 1.26.
- **plugin/cache TTL cap removal:** Cache TTLs can now exceed 3600s. Confirm this doesn't change effective behavior for the default in-cluster Corefile.
- **plugin/dnssec re-signing:** Signs each RRset with its owning zone instead of the query zone. Low risk — DNSSEC signing not used in default OpenShift DNS config.
- **Toolchain drift:** Upstream `.go-version` is 1.26.3. Downstream enforces `GOTOOLCHAIN=local`.
