---
id: "ADR-0003"
slug: "do-not-support-webkit"
status: "Accepted"
date: "2026-05-24"
---

# ADR-0003: Do Not Support WebKit

## Context

This repository currently runs Playwright E2E coverage across Chromium,
Firefox, and WebKit in CI. In practice, WebKit failures are harder to debug in
this project because the maintainers do not have a macOS environment available
for local reproduction and verification.

Maintaining official browser support requires a reasonable ability to reproduce,
investigate, and validate browser-specific failures. That bar is currently met
for Chromium and Firefox, but not for WebKit. Treating WebKit as a required
support target would create an ongoing maintenance obligation that the current
environment and contributor capacity do not support.

At the same time, browser compatibility improvements are still valuable when
they can be contributed without destabilizing the behaviors that already work in
the supported environments.

## Decision

This repository will not treat WebKit as a supported browser target.

WebKit E2E failures will not block the main CI result for this project. The
supported browser targets remain the browsers that can be reasonably developed
and debugged within the current maintainer environment.

Contributions that improve WebKit compatibility are welcome, provided they do
not break or regress existing functionality in the currently supported
environments. If maintainer capacity or local debugging capability changes in
the future, this decision can be revisited.

## Consequences

- Reduces maintenance burden by avoiding an official support commitment that the
  current maintainer environment cannot back up.
- Keeps CI signal focused on browsers that can be reproduced and debugged
  reliably.
- Allows experimental or community-driven WebKit compatibility work without
  promising ongoing support.
- Means WebKit-specific issues may remain unresolved for longer or be closed as
  unsupported.
- Requires contributors proposing WebKit fixes to preserve existing behavior in
  supported browsers.

## Alternatives Considered

- Continue supporting WebKit in CI as a required target: Not chosen because the
  project cannot currently reproduce and debug WebKit issues to a standard that
  justifies official support.
- Remove WebKit coverage entirely: Not chosen because non-blocking coverage
  still provides useful signal, and compatibility improvements are still
  welcome.
- Declare support for all Playwright browsers equally: Not chosen because the
  support policy would not match the maintainers' actual ability to investigate
  failures.

## Related ADRs

- [ADR-0002: Use Playwright JS for E2E Testing](./0002-use-playwright-js-for-e2e-testing.md)
