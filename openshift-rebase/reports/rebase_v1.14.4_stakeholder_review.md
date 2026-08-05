# CoreDNS v1.14.4 Rebase — Stakeholder Review

**Rebase:** v1.13.1 → v1.14.4
**Release notes:** [v1.14.0](https://github.com/coredns/coredns/releases/tag/v1.14.0) | [v1.14.1](https://github.com/coredns/coredns/releases/tag/v1.14.1) | [v1.14.2](https://github.com/coredns/coredns/releases/tag/v1.14.2) | [v1.14.3](https://github.com/coredns/coredns/releases/tag/v1.14.3) | [v1.14.4](https://github.com/coredns/coredns/releases/tag/v1.14.4)

---

## Upstream Changes Analysis

**New features and enhancements:**
- **plugin/cache:** Cache TTLs can now exceed the previous 3600s default cap; optional verify timeout for `serve_stale`; prefers positive cache over `SERVFAIL` in negative-cache handling. This is the most impactful change for OpenShift — the TTL cap removal could change effective caching behavior. **Risk: Medium**
- **plugin/forward:** Hostname resolution support for `TO` endpoints; NODATA responses forwarded to `Next` handler instead of being treated as terminal. **Risk: Low** — OpenShift uses IP addresses for forward targets.
- **plugin/file:** Zones auto-reload based on file mtime; canonicalizes escape-form owner names. **Risk: Low**
- **plugin/dnstap:** Added incoming connection support. **Risk: Low**
- **plugin/secondary:** Added `fallthrough` support. **Risk: Low**
- **Transport/TLS:** DoH3 request header size bounded; TLS `ConnectionState` (SNI) exposed for DoQ; duplicate cipher suites removed. **Risk: Low** — OpenShift cluster DNS does not use DoH/DoQ.
- **loong64 architecture support** added. No OpenShift impact. **Risk: Low**

**Bug fixes:**
- Security hardening: regex length limit for resource-exhaustion; `gosec` G115 integer-overflow fixes; Kubernetes plugin rate-limits API server calls. **Risk: Low**
- Removed debug `fmt.Println` from multicluster zone validation. **Risk: Low**
- Configuration validation improvements across multiple plugins (any, local, chaos, ready, trace, dnstap, health, log). **Risk: Low**

**Breaking changes and deprecations:**
- **plugin/dnssec:** Signs each RRset with its owning zone instead of the query zone. **Risk: Low for OpenShift** — DNSSEC signing not part of default in-cluster DNS config.
- No formal backward-incompatible changes across v1.14.0–v1.14.4.

**Dependency updates:**
- Kubernetes client libs: v0.34.1 → **v0.36.2** (pulled up by `ocp_dnsnameresolver` plugin; upstream targets v0.35.4). **Risk: Medium** — binary ships k8s 1.36 libs that upstream CoreDNS hasn't officially adopted.
- Go module directive: `go 1.25.0` → **`go 1.26.0`**. **Risk: Medium** — ART builder images must support Go 1.26.
- `k8s.io/klog/v2` → v2.140.0, `sigs.k8s.io/mcs-api` → v0.5.0. **Risk: Low**

**OpenShift compatibility impact:**
All standing carries are compatible and reapplied without conflicts. The `ocp_dnsnameresolver` plugin slot in `plugin.cfg` (before `cache`) is unchanged by upstream ordering changes. Build and all tests pass.

---

## Downstream Changes

- **Carries:** 7 reapplied, 3 dropped (CVE bumps superseded upstream), 2 skipped (ART image-sync — bot will resubmit), 2 squashed into 1 (OWNERS)
- **External plugin:** `ocp_dnsnameresolver` pinned to `@01fb3d1` (k8s v0.36.2). No code changes needed.
- **Toolchain:** Upstream `.go-version` is 1.26.3. Downstream enforces `GOTOOLCHAIN=local`. ART builder images need Go ≥1.26.
- **Pre-existing upstream test bugs:** Fixed `%q` format verb on numeric types in 3 test files (plugin/test, plugin/dns64, plugin/file).

---

## Action Items

- [ ] **Decision:** Accept k8s v0.36.2 in the binary (pulled by `ocp_dnsnameresolver`), or create a plugin release pinned to k8s v0.35.4?
- [ ] **Decision:** Confirm ART builder images (`rhel-9-release-golang-*-openshift-*`) ship Go ≥1.26
- [ ] **Testing:** Verify `plugin/cache` TTL behavior with default in-cluster Corefile
- [ ] **Testing:** Run e2e DNS tests on rebased build
- [ ] **Owner:** _____________
- [ ] **Target merge date:** _____________

---

**Meeting notes:**

_(space for discussion notes)_
