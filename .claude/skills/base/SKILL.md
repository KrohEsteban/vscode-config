---
name: base
description: Universal code writing standards: execution, architecture, naming, formatting, security — language-agnostic
---

## Execution Rules

**CRITICAL**: Do NOT run build tools or package managers directly on the host machine.

**MANDATORY**: Execute all commands through the Docker `cli` service:

```bash
docker compose -f .docker/compose.yaml run --rm cli <command>
```

Examples:
- `npm install` → `docker compose -f .docker/compose.yaml run --rm cli npm install`
- `./gradlew build` → `docker compose -f .docker/compose.yaml run --rm cli gradle build`
- `go build ./...` → `docker compose -f .docker/compose.yaml run --rm cli go build ./...`

## Architecture

- **Clean architecture**: enforce layer separation — controllers → services → repositories.
- **Dependency injection**: constructor-based only. No global state, no service locators.
- **No ORM**: raw SQL with parameterized queries. Explicit column mapping to structs/POJOs.
- **Repository pattern**: one file per entity, one class/struct per repository.

## Code Quality

1. **NEVER suppress linter or test errors** — no `@SuppressWarnings`, `// eslint-disable`, `# noqa`, or similar.
2. **Fix the root cause** — if a check fails, fix the code, not the check.
3. If suppression is the only option, stop and ask the user before proceeding.

## Language

- **English**: all code, comments, variable names, and internal documentation must be in English.
- **Exception**: client-facing UI strings and domain terms may be in Spanish (e.g., "turno", "comercio", "mora").

## Naming Conventions

| Scope | Convention |
|-------|-----------|
| Variables, functions, methods | `camelCase` |
| Types, classes, components | `PascalCase` |
| Constants | `SCREAMING_SNAKE_CASE` |
| Config params, SQL columns | `snake_case` |
| File names | `kebab-case` or `snake_case` depending on language |

- **No unexpanded acronyms**: write `Api`, `Http`, `Db` — never `API`, `HTTP`, `DB`.

## Internationalization (i18n)

**NEVER hardcode user-facing strings directly in code.** All text shown to clients must live in a centralized messages file, separate from the logic.

- Client-facing messages are in **Spanish** by default.
- Keeping them isolated makes them easy to maintain and allows adding other languages later.
- Reference messages by key from code — never inline the string itself.
- Message keys use `snake_case` namespaced by domain: `appointment.not_available`, `auth.invalid_token`.
- The messages file is the single source of truth — no duplicated strings across the codebase.

```
// ❌ hardcoded
return error("El turno no está disponible")

// ✅ centralized
return error(messages["appointment.not_available"])
```

Each language-specific skill defines which mechanism to use (properties file, JSON, YAML, etc.).

## Code Formatting

- Line endings: **LF only** (Unix). Never CRLF.
- Max line length: **120 characters** (Java: 140).
- No trailing whitespace.
- No tabs — use spaces (except Makefile).
- Files must end with a single newline.
- File permissions: **0644 only**.
- Filenames: alphanumeric + `_/-+.` only.
- Indentation: 4 spaces (XML, YAML, JSON, Java, Go); 2 spaces (Markdown, HTML).

## Safety Patterns

- **Yoda conditions**: place constants on the left side of comparisons.
  - Java: `if (null == variable)` / `"constant".equals(variable)`
  - Go/TS: prefer explicit null checks over implicit truthy/falsy.
- **Explicit member access**: always use `this.` (Java/JS/TS) or the named receiver (Go).

## Security

- **No secrets in code**: never commit passwords, tokens, API keys, or PII.
- **Runtime injection only**: secrets via environment variables or Docker secrets — never baked into images.
- **Encryption**: use AES-256 for symmetric encryption.
- **Parameterized queries always** — no string concatenation in SQL.

## REST API Conventions

- Plural nouns for resources: `/resources`, `/appointments`, `/businesses`.
- Nested routes max 2–3 levels: `/businesses/:id/resources`.
- HTTP verbs: GET (read), POST (create), PUT (full update), PATCH (partial), DELETE.
- Error response shape: `{ "error": "Human-readable message" }`.
- Auth: JWT Bearer token. Header: `Authorization: Bearer <token>`.

## Database

- Raw SQL only — no ORM.
- Parameterized queries (`?` / `$1`, `$2`).
- Explicit column listing — no `SELECT *`.
- `CASCADE` deletes only when a parent entity truly owns its children.

## Testing

- Tests run against real dependencies (real DB in Docker) — do not mock infrastructure.
- Unit tests may mock only internal interfaces, not databases or external services.
- Test file location mirrors source structure.
- Do not use `t.Skip()` or equivalent to silence failing tests.

## Docker

- Multi-stage Dockerfiles: `base` → `dev` → `prod`.
- Development: source code mounted as volume with hot-reload.
- Production: minimal Alpine image — only the runtime binary and CA certs.
- Health checks required on all stateful services (db, cache, broker).
- Secrets mounted at runtime — never as `ENV` in Dockerfile.
