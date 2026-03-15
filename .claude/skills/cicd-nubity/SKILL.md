---
name: cicd-nubity
description: CI/CD for Nubity projects: workflows extend from nubity/dev-kit, pipeline structure, commit format, quality gates
---

## Context

This is a Nubity project. All CI/CD workflows extend reusable jobs from the shared dev-kit:
**https://github.com/nubity/dev-kit**

Never duplicate CI logic locally — always delegate to dev-kit workflows via `uses:`.

---

## GitHub Actions — Workflow Structure

Each workflow file in `.github/workflows/` delegates to dev-kit and adds a `check-*` aggregator job that fails the build if any job was cancelled or failed.

### Standard pattern for every workflow
```yaml
name: 'Workflow Name'

on:
    pull_request: null
    schedule:
        - cron: '0 6 * * *'   # daily at 6 AM UTC

jobs:
    job-name:
        name: 'Job Name'
        uses: 'nubity/dev-kit/.github/workflows/<workflow>.yaml@master'
        secrets: inherit
        with:
            project-key: 'PROJECT-KEY'   # Jira project key, if required

    check-job-name:
        name: 'Job Name'
        if: ${{ always() }}
        runs-on: ubuntu-latest
        needs: [job-name]
        steps:
            - name: 'Check failure'
              if: ${{ always() && contains(needs.*.result, 'failure') || contains(needs.*.result, 'cancelled') }}
              run: echo 'Failed.' && exit 1;
            - name: 'Check success'
              if: ${{ steps.check-failure.outcome == 'skipped' }}
              run: echo 'Success.' && exit 0;
```

---

## Standard Workflows for a Java Project

### `qa.yaml` — Quality Assurance (on every PR + daily)
```yaml
jobs:
    qa:
        uses: 'nubity/dev-kit/.github/workflows/qa.yaml@master'
        secrets: inherit
        with:
            project-key: 'MYPROJECT'

    qa-spelling:
        uses: 'nubity/dev-kit/.github/workflows/spelling-qa.yaml@master'
        secrets: inherit

    qa-java:
        uses: 'nubity/dev-kit/.github/workflows/java-qa.yaml@master'
        secrets: inherit
```

### `test.yaml` — Tests (on every PR + daily)
```yaml
jobs:
    test-java:
        uses: 'nubity/dev-kit/.github/workflows/java-test.yaml@master'
        secrets: inherit
```

### `qa-docker.yaml` — Docker QA (only when `.docker/**` changes)
```yaml
on:
    pull_request:
        paths: ['.docker/**', '.dockerignore']
    schedule:
        - cron: '0 6 * * *'

jobs:
    qa-docker:
        uses: 'nubity/dev-kit/.github/workflows/docker-qa.yaml@master'
        secrets: inherit
```

### `qa-pr.yaml` — Pull Request validation
```yaml
on:
    pull_request:
        types: [opened, reopened, edited, synchronize, converted_to_draft, ready_for_review]

jobs:
    qa-pull-request:
        uses: 'nubity/dev-kit/.github/workflows/pull-request-qa.yaml@master'
        secrets: inherit
        with:
            project-key: 'MYPROJECT'
```

### `release.yaml` — Release (on merged PR)
```yaml
on:
    pull_request:
        types: [closed]

jobs:
    release:
        uses: 'nubity/dev-kit/.github/workflows/release.yaml@master'
        secrets: inherit
```

---

## Available dev-kit Workflows

| Workflow | Purpose |
|----------|---------|
| `qa.yaml` | General QA: commit format, file conventions, spellcheck |
| `java-qa.yaml` | Java: Checkstyle, PMD, SpotBugs, OWASP, licenses |
| `java-test.yaml` | Java: JUnit + JaCoCo coverage |
| `java-build.yaml` | Java: Gradle build |
| `docker-qa.yaml` | Hadolint + Trivy scanning |
| `pull-request-qa.yaml` | PR title, description, branch naming, Jira link |
| `release.yaml` | Tag + GitHub release from CHANGELOG.md |
| `spelling-qa.yaml` | CSpell spell-checking |
| `changelog.yaml` | Changelog generation |
| `stale.yaml` | Mark stale issues/PRs |

---

## Commit Message Format

```
[PROJECT-KEY-###] Description without trailing period
```

Merge request commits:
```
[release-type] ![PR-number] [PROJECT-KEY-###] Description
```

Release types: `documentation`, `major`, `minor`, `patch`, `refactor`, `security`, `tests`

Rules:
- No trailing period
- One commit per PR (`qa-single-commit` enforces this)
- PR title must match commit subject exactly
- Branch naming: `feature/`, `bugfix/`, `hotfix/`, `release/`, `actions/changelog/`
