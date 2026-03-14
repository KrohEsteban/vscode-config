# Skill: CI/CD & Quality (Nubity Dev-Kit)

## Pipeline Architecture
All projects consume reusable templates from `nubity/dev-kit` repo.

### GitLab Stage Order
```
build-images → deps → build → qa → test → release → cleanup
```

### GitHub — Parallel QA Jobs
- QA (general), Docker QA, Markdown QA, Spelling QA, XML QA, YAML QA

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

**Special cases:**
- Merge commits: `Merge branch 'X' into Y`
- Reverts: `Revert "..."`
- Changelog updates: `Add|Update CHANGELOG.md for X.Y.Z`
- Dependabot: `[SK-4] ...`

**Rules:**
- No trailing period on description
- One commit per merge request (enforced by `qa-single-commit`)
- Author email must be `@nubity.com` or `@nbty.cloud`
- PR title must match commit subject exactly

---

## File & Formatting Conventions

| Rule | Value |
|------|-------|
| Line endings | LF (Unix) only |
| Trailing whitespace | Not allowed |
| Tabs | Not allowed (except Makefile) |
| EOF | Files must end with newline |
| Line length | Max 120 characters |
| File permissions | 0644 only |
| Filenames | Alphanumeric + `_/-+.` only |
| Indentation (XML/YAML/JSON) | 4 spaces |
| Indentation (Markdown) | 2 spaces |
| Quotes | Single quotes preferred |

---

## Quality Gates by Language

### All Projects (Universal)
- CSpell spell-checking (custom dictionaries in `.cspell/`)
- YAMLlint, Markdownlint, XMLlint
- Hadolint (Dockerfile linting)
- Trivy (OS-level CVE scanning — CRITICAL + HIGH only)
- No unfixed vulnerability failures

### Java
- Checkstyle 11+ (line length 140, 4-space indent)
- PMD 7+
- SpotBugs 4+
- OWASP Dependency Check
- JaCoCo coverage
- JUnit XML output required

### JavaScript / TypeScript
- Prettier (formatting)
- ESLint (static analysis)
- Yarn `--immutable` lock file check
- License allowlist: Apache-2.0, BSD, ISC, MIT, Public Domain
- Jest with `--watchAll=false`, JUnit + Clover XML output

### PHP
- PHP-CS-Fixer
- Rector
- PHPStan
- PHPMD
- PHP_CodeSniffer
- composer-require-checker
- composer-normalize
- License allowlist: Apache-2.0, BSD-2/3, MIT
- PHPUnit with JUnit + Clover XML output

### Python
- autopep8 (formatting)
- isort (import sorting)
- pylint
- mypy (type checking with `--namespace-packages`)
- Radon (cyclomatic complexity, min B)
- pydocstyle
- PDM with lock file validation

### Terraform
- tfsec (security)
- tflint
- terraform fmt

---

## Docker Standards
- **Semantic versioning pinned** for all base images — no `latest` tags.
- **OCI labels required** on every Dockerfile:
  ```dockerfile
  LABEL org.opencontainers.image.source="..."
  LABEL org.opencontainers.image.version="..."
  ```
- **Trusted registry:** `public.ecr.aws` only (no Docker Hub in CI).
- **Hadolint** enforced — no bypass.
- **Trivy** scans OS packages, CRITICAL + HIGH only, unfixed ignored.
- **Docker socket:** mount as read-only (`:ro`) only.
- Multi-stage Dockerfiles: `base` → `cli-dev` → `dev` → `prod`.
- Production stage: minimal Alpine + CA certs only.

---

## Dependency Management Rules
- Lock files **REQUIRED** for every language (gradle.lockfile, yarn.lock, composer.lock, pdm.lock).
- Dependency CVE scans run on schedule (daily) and create issues automatically.
- License checking with allowlist — fail on unlisted licenses.
- Outdated dependency checks run as advisory (allow_failure).

---

## CI Configuration Reference

### Including dev-kit templates (GitLab)
```yaml
include:
  - project: nubity/development/dev-kit
    ref: main
    file: templates/gitlab/ci/qa.gitlab-ci.yml
  - project: nubity/development/dev-kit
    ref: main
    file: templates/gitlab/ci/java.gitlab-ci.yml
```

### Including dev-kit workflows (GitHub)
```yaml
jobs:
  qa:
    uses: nubity/dev-kit/.github/workflows/java-qa.yaml@main
    with:
      project-key: BLP
```

---

## Pull Request Rules
- Title must match commit subject.
- Description must use table format with required fields.
- PR must be up-to-date with base branch before merge.
- Must reference a JIRA issue.
- Branch naming: `feature/`, `bugfix/`, `hotfix/`, `release/`, `actions/changelog/`
