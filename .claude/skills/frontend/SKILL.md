---
name: frontend
description: Frontend conventions: Next.js App Router, Astro SSR, TypeScript, OpenAPI types
---

## Stacks Used
- **Next.js 16+** with TypeScript, React 19, Tailwind CSS 4 (blpdev projects)
- **Astro 5+** with TypeScript, Tailwind CSS 3, DaisyUI (pampa-turnos)
- Types auto-generated from OpenAPI/Swagger spec via `openapi-typescript`

## General Conventions

### Naming
- Components: `PascalCase` files (EventModal.astro, ResourceForm.tsx).
- Pages/routes: `kebab-case` files (dashboard.astro, [id].astro).
- Functions: `camelCase` (upsertResource, deleteResource).
- Types/interfaces: `PascalCase` (Business, Resource, Appointment).
- CSS: Tailwind utility classes — no custom CSS unless unavoidable.

### Types
- Always import from auto-generated schema:
  ```typescript
  import type { components } from '../types/generated/api.schema';
  type Business = components['schemas']['Business'];
  ```
- Use `Required<>` and `Omit<>` utilities to derive variants — don't duplicate types.
- Keep `types/generated/` read-only — never edit generated files manually.

### API Client Pattern
```typescript
async function apiFetch<T>(endpoint: string, options: ApiOptions = {}): Promise<T> {
    const token = getTokenFromContext(); // SSR: cookies; browser: localStorage
    const res = await fetch(`${API_BASE_URL}${endpoint}`, {
        headers: { Authorization: `Bearer ${token}` },
        ...options,
    });
    if (!res.ok) throw new Error(await res.text());
    return res.json() as T;
}
```

### Authentication
- JWT stored in cookies (httpOnly preferred).
- Sent as `Authorization: Bearer <token>`.
- Route protection via middleware (Astro: `src/middleware.ts`, Next.js: middleware.ts).
- Profiles: `admin`, `business`, `demo` — check before rendering protected sections.

## Next.js Patterns
- **App Router** (not Pages Router).
- Server components for data fetching with `fetch` + Next.js caching (`revalidate`, `tags`).
- `'use client'` only when interactivity is required.
- Internationalization: `next-intl` with message files per locale.
- API calls propagate `X-Remote-User` header for reverse proxy auth.

## Astro Patterns
- Output mode: `server` (SSR, not static).
- Adapter: Node.js standalone for production.
- **Server Actions** (`astro:actions`) for form handling:
  ```typescript
  export const server = {
      upsertResource: defineAction({
          accept: 'form',
          handler: async (input, context) => {
              const token = context.cookies.get('token')?.value;
              if (!token) throw new ActionError({ code: 'UNAUTHORIZED' });
              // logic
          },
      }),
  };
  ```
- Middleware for auth and redirects:
  ```typescript
  export const onRequest = defineMiddleware(async (context, next) => {
      // validate token, redirect if unauthorized
      return next();
  });
  ```
- DaisyUI classes for UI: `btn`, `modal`, `badge`, `alert`, `card`, etc.
- Lucide icons: `import Icon from '@lucide/astro/icons/icon-name'`.

## Type Generation Workflow
```bash
# 1. After changing Go/Java API, regenerate swagger:
docker compose -f .docker/compose.yaml run --rm cli swag init -g internal/app/app.go

# 2. Regenerate frontend types:
docker compose -f .docker/compose.yaml run --rm cli-front \
  npx openapi-typescript ../api/doc/swagger/swagger.json \
  -o src/types/generated/api.schema.ts
```

## CLI (via Docker)
```bash
docker compose -f .docker/compose.yaml run --rm cli-front npm install
docker compose -f .docker/compose.yaml run --rm cli-front npm run build
docker compose -f .docker/compose.yaml run --rm cli-front npm run lint
```
