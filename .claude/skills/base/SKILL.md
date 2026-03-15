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

## Architecture

- **Clean architecture**: enforce layer separation — controllers → services → repositories.
- **Dependency injection**: constructor-based only. No global state, no service locators.
- **No ORM**: raw SQL with parameterized queries. Explicit column mapping to data objects.
- **Repository pattern**: one file per entity, one class/struct per repository.

## Golden Rule

**Imitate the existing code.** The current codebase's style takes precedence over any external guide, including this skill. Before writing new code, read the surrounding code and match its patterns — naming, structure, error handling, and formatting.

## Code Quality

1. **NEVER suppress linter or test errors** — no `@SuppressWarnings`, `// eslint-disable`, `# noqa`, or similar.
2. **Fix the root cause** — if a check fails, fix the code, not the check.
3. If suppression is the only option, stop and ask the user before proceeding.
4. **Fail loud** — if a function cannot fulfill its responsibility, throw an exception. Never fail silently or return a default value masking an error.
5. **Lowest cyclomatic complexity** — minimize decision branches. Break execution as early as possible (guard clauses first).
6. **Strict typing** — always declare explicit types. Avoid type coercion, casting, or juggling.
7. **Visibility as closed as possible** — default to `private`, then `protected`, only `public` when necessary.
8. **`@todo` comments** for deferred work — must be explicit about what needs to change and include a `@see` pointing to the issue tracker:
   ```
   // @todo: Add pagination support to this query.
   // @see: https://github.com/org/repo/issues/123
   ```

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
- **No Hungarian notation**: `users` not `userArray`, `items` not `itemList`.
- **Plural form for collections**: `users`, `appointments`; or append `List`/`Collection` when plural is ambiguous.
- **Model classes use singular**: `User` not `Users`, `Appointment` not `Appointments`.
- **Methods start with a verb**: `getUser()`, `addItem()`, `removeAppointment()` — never a noun alone.
- **Classes/interfaces use nouns only** — no verbs in class names.

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
- Max line length: **120 characters**.
- No trailing whitespace.
- No tabs — use spaces (except Makefile).
- Files must end with a single newline.
- File permissions: **0644 only**.
- Filenames: alphanumeric + `_/-+.` only.
- Indentation: 4 spaces. 2 spaces for Markdown and HTML.

## Safety Patterns

- **Yoda conditions**: place constants on the left side of comparisons.
- **Explicit member access**: always use `this.` or the named receiver to access fields and methods.

## Security

- **No secrets in code**: never commit passwords, tokens, API keys, or PII.
- **Runtime injection only**: secrets via environment variables or Docker secrets — never baked into images.
- **Symmetric encryption**: AES-256.
- **Asymmetric encryption / signatures**: Ed25519 (SSH keys, digital signatures).
- **Password hashing**: Bcrypt (recommended — adjustable work factor, widely supported).
- **Parameterized queries always** — no string concatenation in SQL.
- **Only the credential itself is sensitive** — usernames, hostnames, ports are NOT sensitive; only passwords and API secrets are.

## REST API Conventions

- Plural nouns for resources: `/resources`, `/appointments`, `/businesses`.
- Nested routes max 2–3 levels: `/businesses/:id/resources`.
- HTTP verbs: GET (read), POST (create), PUT (full update), PATCH (partial), DELETE.
- Error response shape: `{ "error": "Human-readable message" }`.
- Auth: JWT Bearer token. Header: `Authorization: Bearer <token>`.

## Database

- Raw SQL only — no ORM.
- Always use driver-level parameterized queries — no string concatenation.
- Explicit column listing — no `SELECT *`.
- `CASCADE` deletes only when a parent entity truly owns its children.

## Testing

- Tests run against real dependencies (real DB in Docker) — **prefer not mocking the database**.
- Mock the database only when strictly necessary and there is no viable alternative.
- Test file location mirrors source structure.

## Docker

- Multi-stage Dockerfiles: `base` → `dev` → `prod`.
- Development: source code mounted as volume with hot-reload.
- Production: minimal Alpine image — only the runtime binary and CA certs.
- Health checks required on all stateful services (db, cache, broker).
- Secrets mounted at runtime — never as `ENV` in Dockerfile.
