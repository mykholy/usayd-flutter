# Branch and release flow

| Branch | Flavor | Purpose |
| --- | --- | --- |
| dev | dev | Daily integration |
| staging | staging | QA and acceptance |
| main | prod | Release source |

Create one ticket-scoped feature branch from dev. Open a PR to dev, run quality, review and build checks, then promote through dev → staging → main using PRs. Do not squash promotion PRs: preserve ancestry. Do not push directly to permanent branches. For an emergency hotfix use a main-based ticket branch and back-merge the fix through staging and dev.

`AGENTS.md` and existing quality gates remain authoritative. The branch-flow workflow is an additional check; repository admin must configure it as required in rulesets for all three branches, require passing quality/build checks and prevent direct pushes. Do not disable current protection.

The Android debug matrix produces QA artifacts only. It does not publish releases. Main is production source, not a deployed environment. Firebase project provisioning, production signing, Apple team/profiles and deployment credentials are separate prerequisites. Keep secrets out of Git.

SDK: use the version in `.fvmrc` consistently. Upgrade Flutter and native toolchains together in a separate tested PR.
