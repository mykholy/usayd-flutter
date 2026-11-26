# Agent execution policy — usayd-flutter

Read `gemini/GEMINI_MASTER_AUTONOMOUS_OPERATOR_PROMPT.md` from the handoff package, the ORIGINAL source specs and the exact `planning/tasks/<ID>.md` before each change.
This is one of THREE independent repositories; keep contracts versioned, do not move to monorepo.
Target component: `flutter`. Changes may reference shared contracts but never silently modify a different repository.
Scope one Jira ticket per branch/PR, verified tests, safety review, branch protection, no fabricated API, no unapproved product/legal/academic decisions, no bypass of CI.
For approved design implement original styles and accessibility; for API use MySQL 8.4 transactions and negative policy tests; for mobile distinguish fixtures from real integration.

## Branch integration
Create ticket branches from `dev` and target `dev` in feature PRs. Promote reviewed changes via `dev` → `staging` → `main` PRs using merge commits to preserve ancestry. See `docs/BRANCH_RELEASE_FLOW.md`. Existing required review, safety, and CI gates remain mandatory.
