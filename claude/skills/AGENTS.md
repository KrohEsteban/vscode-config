# AGENTS.md

## Project Structure
This workspace contains various project types. Identify the type by inspecting the directory structure:
- **Java/Spring**: `build.gradle`, `pom.xml`, `src/main/java`
- **Python**: `requirements.txt`, `setup.py`, `pyproject.toml`
- **JavaScript/Next.js**: `package.json`, `next.config.js`
- **SQL/DB2**: `.sql` files, database schema definitions

## Execution Rules
**CRITICAL**: Do NOT use native build tools or package managers (like `mvn`, `gradle`, `npm`, `pip`, `java`, etc.) directly on the host machine.

**MANDATORY**: You MUST execute all commands through the Docker `cli` service using the following pattern:

```bash
docker compose -f .docker/compose.yaml run --rm cli <command>
```

### Examples
- **Instead of**: `npm install`
- **Use**: `docker compose -f .docker/compose.yaml run --rm cli npm install`

- **Instead of**: `./gradlew build`
- **Use**: `docker compose -f .docker/compose.yaml run --rm cli gradle build`

## Quality & Error Handling
**CRITICAL POLICY**:
1.  **NEVER suppress linter or test errors.** Do not use `@SuppressWarnings`, `// eslint-disable`, `# noqa`, or similar mechanisms to silence warnings unless it is the absolute last resort and you have verified no other solution exists.
2.  **Fix the Root Cause**: If a check fails, your task is to fix the code causing the failure, not to hide the failure.
3.  **Manual Review**: If you believe an error must be ignored, stop and ask the user for confirmation. Any suppression requires explicit user approval.

## Coding Standards
**Golden Rule**: Imitate the existing code. Verification of the current codebase style is more important than external style guides.

### Key Highlights (General)
- **Language**:
    - **English**: Code, comments, and documentation MUST be in English.
    - **Exception**: Client-facing documentation or UI strings MAY be in Spanish.
- **Naming**:
    - `camelCase` for variables, functions, and methods.
    - `snake_case` for configuration parameters.
    - `SCREAMING_SNAKE_CASE` for constants.
    - **No Acronyms**: Terms like "API", "HTTP", "DB" MUST be title-cased/camel-cased (e.g., `Api`, `Http`, `Db`).
- **Safety**:
    - **Yoda Conditions** / **Safe Comparisons**: Place constants on the left side of comparisons where applicable (e.g., `if (null == variable)` or `"constant".equals(variable)`).
- **Security**:
    - **No Raw Secrets**: Never store passwords, secrets, or PII in the repository.
    - **Encryption**: Use AES-256 for symmetric encryption if needed.
- **Explicit Access**:
    - Always use `this` (Java/JS) or `self` (Python) to access class members.

Refer to the Nubity technical documentation for specific standards:
[Coding Standards](http://nubity-20240712-docs-s3bucket-4kmuqepiiqer.s3-website-us-east-1.amazonaws.com/contributing/code/index.html)
