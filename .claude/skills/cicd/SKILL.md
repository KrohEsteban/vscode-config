---
name: cicd
description: CI/CD tools inventory (dev-kit), pipeline structure, commit format, dependency and Docker standards
---

## Dev-Kit Overview

All Nubity projects consume reusable CI templates from `nubity/dev-kit`.
Source: `/home/esteban-work/project/dev-kit`

### Including templates (GitLab)
```yaml
include:
  - project: nubity/development/dev-kit
    ref: main
    file: templates/gitlab/ci/qa.gitlab-ci.yml
  - project: nubity/development/dev-kit
    ref: main
    file: templates/gitlab/ci/java.gitlab-ci.yml
```

### Including workflows (GitHub)
```yaml
jobs:
  qa:
    uses: nubity/dev-kit/.github/workflows/java-qa.yaml@main
    with:
      project-key: BLP
```

---

## Pipeline Stage Order (GitLab)

```
build-images → deps → build → qa → test → release → cleanup
```

GitHub runs QA jobs in parallel: general QA, Docker QA, Markdown, Spelling, XML, YAML.

---

## Commit Message Format

```
[PROJECT-KEY-###] Description without trailing period
```

**Merge request commits:**
```
[release-type] ![MR-number] [PROJECT-KEY-###] Description
```

Release types: `documentation`, `major`, `minor`, `patch`, `refactor`, `security`, `tests`

Special cases:
- Merge commits: `Merge branch 'X' into Y`
- Reverts: `Revert "..."`
- Changelog: `Add|Update CHANGELOG.md for X.Y.Z`

Rules:
- No trailing period
- One commit per merge request (`qa-single-commit` enforces this)
- PR title must match commit subject exactly
- Branch naming: `feature/`, `bugfix/`, `hotfix/`, `release/`, `actions/changelog/`

---

## Tools Inventory by Language

### Universal (all projects)
| Tool | Purpose | Config |
|------|---------|--------|
| **CSpell** | Spell-checking | `.cspell/cspell.yaml` + custom dictionaries |
| **YAMLlint** | YAML validation | `.yamllint.yaml` |
| **Markdownlint** | Markdown validation | `.markdownlint.yaml` |
| **XMLlint** | XML formatting | `make lint-xml` |
| **Hadolint** | Dockerfile linting | `.docker/.hadolint.yaml` |
| **Trivy** | CVE scanning (OS packages) | `.docker/.trivy.yaml` — CRITICAL+HIGH only |

### Java
| Tool | Purpose |
|------|---------|
| **Checkstyle 11+** | Code style (line length 140, 4-space indent) |
| **PMD 7+** | Static analysis / code smells |
| **SpotBugs 4+** | Bug detection |
| **OWASP Dependency Check** | CVE scanning for dependencies |
| **JaCoCo** | Code coverage |
| **JUnit** | Test runner — XML output required |

### JavaScript / TypeScript
| Tool | Purpose |
|------|---------|
| **Prettier** | Code formatting |
| **ESLint** | Static analysis |
| **Yarn** | Package manager — `--immutable` lock file required |
| **Jest** | Tests — `--watchAll=false`, JUnit + Clover XML output |
| **license-checker** | License allowlist: Apache-2.0, BSD, ISC, MIT, Public Domain |

### PHP
| Tool | Purpose |
|------|---------|
| **PHP-CS-Fixer** | Code style |
| **Rector** | Modernization / refactor checker |
| **PHPStan** | Static analysis |
| **PHPMD** | Mess detection |
| **PHP_CodeSniffer** | PSR standards |
| **composer-require-checker** | Detect implicit dependencies |
| **composer-normalize** | composer.json formatting |
| **composer audit** | CVE scanning |
| **PHPUnit** | Tests — JUnit + Clover XML output |
| **license-checker** | Allowlist: Apache-2.0, BSD-2/3, MIT |

### Python
| Tool | Purpose |
|------|---------|
| **autopep8** | Formatting (aggressive mode) |
| **isort** | Import sorting |
| **pylint** | Static analysis |
| **mypy** | Type checking (`--namespace-packages`) |
| **Radon** | Cyclomatic complexity (min grade B) |
| **pydocstyle** | Docstring validation |
| **PDM** | Package manager — lock file required |

### Terraform
| Tool | Purpose |
|------|---------|
| **tfsec** | Security scanning |
| **tflint** | Linting |
| **terraform fmt** | Format validation |

---

## Docker CI Standards

- **Semantic versioning pinned** for all base images — no `latest` tags.
- **OCI labels required** on every Dockerfile:
  ```dockerfile
  LABEL org.opencontainers.image.source="..."
  LABEL org.opencontainers.image.version="..."
  ```
- Trusted registry: `public.ecr.aws` (no Docker Hub in CI).
- Docker socket mounted read-only only: `/var/run/docker.sock:ro`.
- Hadolint failure threshold: style-level (no bypass allowed).
- Trivy: OS packages only, CRITICAL + HIGH, unfixed ignored, 5min timeout.

---

## Dependency Management

- Lock files **required** for every language: `gradle.lockfile`, `yarn.lock`, `composer.lock`, `pdm.lock`.
- CVE scans run on schedule (daily) — failures create issues automatically.
- License checking with allowlist — fail build on unlisted licenses.
- Outdated dependency checks: advisory only (`allow_failure: true`).

---

## Makefile Targets (dev-kit local)

```bash
make lint              # Run all linting (YAML + XML)
make lint-yaml         # YAMLlint
make lint-xml          # XMLlint formatting check
make cs-fix-xml        # Auto-fix XML formatting
make spellcheck        # CSpell validation
make lint-spellcheck-dictionaries  # Validate CSpell dictionaries
```
