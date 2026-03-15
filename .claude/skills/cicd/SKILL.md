---
name: cicd
description: CI/CD from scratch for personal projects: GitHub Actions setup without external dependencies
---

## Context

This is a personal project — no shared CI templates to extend from. All workflow logic lives directly in this repository under `.github/workflows/`.

Use the tool configurations and patterns from [nubity/dev-kit](https://github.com/nubity/dev-kit) as reference for how to configure each tool, but run them directly instead of delegating via `uses:`.

---

## Recommended Workflow Structure

```
.github/
└── workflows/
    ├── qa.yaml          # Code quality checks on every PR
    ├── test.yaml        # Tests on every PR
    └── release.yaml     # Create release on merge to main
```

---

## `qa.yaml` — Quality Assurance

Runs on every pull request. Configure the tools relevant to your stack.

```yaml
name: 'Quality Assurance'

on:
    pull_request: null

jobs:
    lint:
        name: 'Lint'
        runs-on: ubuntu-latest
        steps:
            - uses: actions/checkout@v4

            # --- YAML ---
            - name: 'Lint YAML'
              uses: ibiqlik/action-yamllint@v3
              with:
                  config_file: .yamllint.yaml

            # --- Spelling ---
            - name: 'Spell check'
              uses: streetsidesoftware/cspell-action@v6
              with:
                  config: .cspell/cspell.yaml

            # --- Dockerfile (if project has Docker) ---
            - name: 'Lint Dockerfiles'
              uses: hadolint/hadolint-action@v3.1.0
              with:
                  recursive: true
                  config: .docker/.hadolint.yaml
```

### Java — add to `qa.yaml`
```yaml
            # --- Checkstyle ---
            - name: 'Set up JDK'
              uses: actions/setup-java@v4
              with:
                  java-version: '17'
                  distribution: 'temurin'

            - name: 'Checkstyle'
              run: docker compose -f .docker/compose.yaml run --rm cli gradle checkstyleMain checkstyleTest
```

### Go — add to `qa.yaml`
```yaml
            - name: 'Set up Go'
              uses: actions/setup-go@v5
              with:
                  go-version: '1.23'

            - name: 'Lint'
              uses: golangci/golangci-lint-action@v6
```

### JavaScript / TypeScript — add to `qa.yaml`
```yaml
            - name: 'Install dependencies'
              run: docker compose -f .docker/compose.yaml run --rm cli npm ci

            - name: 'Prettier'
              run: docker compose -f .docker/compose.yaml run --rm cli npx prettier --check .

            - name: 'ESLint'
              run: docker compose -f .docker/compose.yaml run --rm cli npm run lint
```

---

## `test.yaml` — Tests

```yaml
name: 'Test'

on:
    pull_request: null

jobs:
    test:
        name: 'Test'
        runs-on: ubuntu-latest
        steps:
            - uses: actions/checkout@v4

            # Java
            - name: 'Run tests'
              run: docker compose -f .docker/compose.yaml run --rm cli gradle test

            # Go
            # - run: docker compose -f .docker/compose.yaml run --rm cli go test ./...

            # JS/TS
            # - run: docker compose -f .docker/compose.yaml run --rm cli npm test -- --watchAll=false
```

---

## `release.yaml` — Release

Creates a GitHub release from a tag when a PR is merged to `main`.

```yaml
name: 'Release'

on:
    push:
        tags:
            - 'v*.*.*'

jobs:
    release:
        name: 'Release'
        runs-on: ubuntu-latest
        steps:
            - uses: actions/checkout@v4

            - name: 'Create GitHub Release'
              uses: softprops/action-gh-release@v2
              with:
                  generate_release_notes: true
```

---

## Useful Reusable Actions

| Action | Purpose |
|--------|---------|
| `actions/checkout@v4` | Checkout code |
| `actions/setup-java@v4` | Set up JDK |
| `actions/setup-go@v5` | Set up Go |
| `actions/setup-node@v4` | Set up Node.js |
| `actions/cache@v4` | Cache dependencies |
| `hadolint/hadolint-action@v3` | Lint Dockerfiles |
| `golangci/golangci-lint-action@v6` | Go linting |
| `ibiqlik/action-yamllint@v3` | YAML linting |
| `streetsidesoftware/cspell-action@v6` | Spell checking |
| `softprops/action-gh-release@v2` | Create GitHub releases |
| `aquasecurity/trivy-action@v0` | CVE scanning |

---

## Recommended Config Files

These config files should exist in the repo and be referenced by the workflows:

| File | Purpose |
|------|---------|
| `.yamllint.yaml` | YAMLlint rules |
| `.cspell/cspell.yaml` | Spell-check config + custom dictionaries |
| `.docker/.hadolint.yaml` | Hadolint rules |
| `.editorconfig` | Editor formatting: LF, 4 spaces, 120 chars |

Use the configurations from [nubity/dev-kit](https://github.com/nubity/dev-kit) as a starting point.
