---
name: nextjs
description: Next.js 15+ App Router conventions: server components, next-intl, TypeScript, OpenAPI types
---

## Stack
- Next.js 15+, TypeScript, React 19, Tailwind CSS 4
- App Router (not Pages Router)
- Types auto-generated from OpenAPI/Swagger spec via `openapi-typescript`
- Internationalization: `next-intl`

## Project Structure
```
src/
├── app/
│   ├── [locale]/          # Locale-aware routing
│   │   ├── layout.tsx
│   │   └── page.tsx
│   └── api/               # Route handlers
├── components/            # Shared components
├── lib/
│   ├── api.ts             # API client
│   └── auth.ts
├── messages/
│   ├── es.json            # Spanish (default)
│   └── en.json
└── types/
    └── generated/
        └── api.schema.ts  # Auto-generated — never edit manually
```

## Naming
- Components: `PascalCase` files (`ResourceForm.tsx`, `EventModal.tsx`).
- Pages: `page.tsx` inside folder routes (`app/dashboard/page.tsx`).
- Functions: `camelCase`.
- CSS: Tailwind utility classes — no custom CSS unless unavoidable.

## Server vs Client Components
- Default to **server components** — fetch data directly, no `useEffect`.
- Add `'use client'` only when interactivity or browser APIs are required.
- Keep client components as small and leaf-level as possible.

## Data Fetching
```typescript
// Server component — fetch with Next.js caching
async function ResourceList() {
    const data = await fetch(`${API_URL}/resources`, {
        next: { revalidate: 60, tags: ['resources'] },
        headers: { Authorization: `Bearer ${token}` },
    });
    // ...
}
```

## Types
- Always import from the generated schema:
  ```typescript
  import type { components } from '@/types/generated/api.schema';
  type Resource = components['schemas']['Resource'];
  ```
- Use `Required<>` and `Omit<>` to derive variants — don't duplicate types.
- Never edit files inside `types/generated/` manually.

## API Client Pattern
```typescript
async function apiFetch<T>(endpoint: string, options: ApiOptions = {}): Promise<T> {
    const res = await fetch(`${process.env.API_BASE_URL}${endpoint}`, {
        headers: { Authorization: `Bearer ${token}` },
        ...options,
    });
    if (!res.ok) throw new Error(await res.text());
    return res.json() as T;
}
```

## Authentication
- JWT stored in cookies (httpOnly).
- Sent as `Authorization: Bearer <token>`.
- Route protection via `middleware.ts` at the project root.
- API calls propagate `X-Remote-User` header for reverse proxy auth.

## i18n
- Use `next-intl` with message files per locale under `src/messages/`.
- Spanish (`es.json`) is the default locale.
- Keys follow `snake_case` namespaced by domain — see `base` skill.
  ```typescript
  const t = useTranslations('appointment');
  return t('not_available'); // reads from messages/es.json
  ```

## Type Generation Workflow
```bash
# Regenerate types after API changes
docker compose -f .docker/compose.yaml run --rm cli-front \
  npx openapi-typescript ../api/doc/swagger/swagger.json \
  -o src/types/generated/api.schema.ts
```

## Formatting
- Prettier is the source of truth for code formatting — not manual rules.
- Never manually adjust spacing or indentation; run Prettier instead.
- CI fails if any file doesn't match Prettier's output: `npm run format:check` or `npx prettier --check .`

## Lock File
- Yarn `--immutable` is enforced in CI — `yarn.lock` must always be in sync with `package.json`.
- After adding or updating a dependency, commit the updated `yarn.lock`.
- Never delete or manually edit `yarn.lock`.

## Spell Checking
- CSpell runs on all files in CI (`qa-spellcheck` job).
- Add unrecognized valid terms to `.cspell/project-terms.txt` — don't rename code to avoid spellcheck.

## CLI (via Docker)
```bash
docker compose -f .docker/compose.yaml run --rm cli-front npm install
docker compose -f .docker/compose.yaml run --rm cli-front npm run build
docker compose -f .docker/compose.yaml run --rm cli-front npm run lint
```
