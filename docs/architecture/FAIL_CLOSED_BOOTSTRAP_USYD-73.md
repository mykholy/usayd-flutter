# USYD-73 / USYD-T0080 — Fail-closed app bootstrap

Draft follow-up to routing and account permissions. The app starts signed out unless a session notifier is explicitly supplied. The default app no longer manufactures an authenticated learner in any flavor. The visual test fixture lives under test/ only and is not imported by production code. The root disposes the router/notifier it owns, not injected dependencies.

This is not a real login implementation or token restoration. The existing login route remains a placeholder pending approved API integration; this deliberately avoids treating a fixture as a genuine session. Canonical source verification, Flutter CI and independent human approval are required before merge.
