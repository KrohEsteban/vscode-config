# AGENTS.md — Base Skill (All Projects)

## Project Structure
This workspace may contain various project types. Identify by inspecting the directory structure:
- **Java/Spring Boot**: `build.gradle`, `pom.xml`, `src/main/java`
- **Go/Gin**: `go.mod`, `internal/` package structure
- **JavaScript/Next.js**: `package.json`, `next.config.js`
- **TypeScript/Astro**: `astro.config.mjs`, `package.json`
- **SQL/DB2**: `.sql` files, database schema definitions

## Execution Rules
**CRITICAL**: Do NOT use native build tools or package managers (like `mvn`, `gradle`, `npm`, `go`, `pip`, etc.) directly on the host machine.

**MANDATORY**: Execute all commands through the Docker `cli` service:

```bash
docker compose -f .docker/compose.yaml run --rm cli <command>
```

### Examples
- **Instead of**: `npm install` → `docker compose -f .docker/compose.yaml run --rm cli npm install`
- **Instead of**: `./gradlew build` → `docker compose -f .docker/compose.yaml run --rm cli gradle build`
- **Instead of**: `go build ./...` → `docker compose -f .docker/compose.yaml run --rm cli go build ./...`

## Architecture
- **Clean architecture**: Always respect the layer separation — controllers → services → repositories.
- **Dependency injection**: Constructor-based. No global state, no service locators.
- **No ORM**: Raw SQL with parameterized queries. Explicit scanning to structs/POJOs.
- **Repository pattern**: One file per entity, one struct/class per repository.

## Quality & Error Handling
**CRITICAL POLICY**:
1. **NEVER suppress linter or test errors.** Do not use `@SuppressWarnings`, `// eslint-disable`, `# noqa`, or similar.
2. **Fix the Root Cause**: If a check fails, fix the code causing the failure, not the check.
3. **Manual Review**: If you believe suppression is the only option, stop and ask the user.

## Coding Standards

### Language
- **English**: Code, comments, and documentation MUST be in English.
- **Exception**: Client-facing UI strings and domain terms MAY be in Spanish (e.g., "turno", "comercio", "mora").

### Naming (all languages)
- `camelCase` for variables, functions, and methods.
- `snake_case` for configuration parameters and SQL columns.
- `SCREAMING_SNAKE_CASE` for constants.
- `PascalCase` for types, classes, and components.
- **No unexpanded acronyms**: Use `Api`, `Http`, `Db` — not `API`, `HTTP`, `DB`.

### Safety
- **Yoda Conditions**: Place constants on the left side of comparisons where applicable.
  - Java: `if (null == variable)` / `"constant".equals(variable)`
  - Go/TS: standard equality is fine, but prefer non-null-punning style.
- **Explicit access**: Always use `this.` (Java/JS) or the receiver (Go) to access struct/class members.

### Security
- **No Raw Secrets**: Never store passwords, secrets, or PII in the repository.
- **Secrets via config tree or environment variables** — mounted at runtime, not baked in.
- **Encryption**: Use AES-256 for symmetric encryption if needed.

## Docker Patterns
- All projects use **multi-stage Dockerfiles**: `base` → `cli-dev` → `dev` → `prod`.
- Development: source code mounted as volume; services support hot-reload.
- Production: minimal runtime image (Alpine JRE / Alpine Go binary / Node standalone).
- Secrets mounted as Docker secrets or config tree — never as environment variables in prod.
- Health checks on all stateful services (db, cache).

## REST API Conventions
- **Plural nouns** for resources: `/resources`, `/appointments`, `/businesses`.
- **Nested routes** max 2–3 levels: `/businesses/:id/resources`.
- **HTTP verbs**: GET (read), POST (create), PUT (full update), PATCH (partial), DELETE.
- **Error response**: `{ "error": "Human-readable message" }`.
- **Auth**: JWT Bearer token or HTTP Basic. Headers: `Authorization: Bearer <token>`.

## Database
- Raw SQL only — no ORM (JDBC in Java, pgx in Go).
- Parameterized queries always (`?` / `$1`, `$2`).
- Context-based execution.
- Explicit column listing — no `SELECT *`.
- `CASCADE` deletes when a parent entity owns children.

## Testing
- Tests must run against real dependencies (real DB in Docker), not mocks of external infrastructure.
- Unit tests mock only internal interfaces, not the database.
- Test file location mirrors source structure.
