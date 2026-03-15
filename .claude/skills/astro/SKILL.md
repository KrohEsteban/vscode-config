---
name: astro
description: Astro 5+ SSR conventions: Server Actions, middleware, DaisyUI, TypeScript, OpenAPI types
---

## Stack
- Astro 5+, TypeScript, Tailwind CSS 3, DaisyUI
- Output mode: `server` (SSR — not static)
- Adapter: Node.js standalone for production
- Types auto-generated from OpenAPI/Swagger spec via `openapi-typescript`
- Icons: Lucide (`@lucide/astro`)

## Project Structure
```
src/
├── actions/       # Server Actions (astro:actions)
├── components/    # Astro components (.astro)
├── layouts/       # Shared layouts
├── pages/         # File-based routing
├── middleware.ts  # Auth, redirects
├── lib/
│   ├── api.ts     # API client
│   └── permissions.ts
└── types/
    └── generated/
        └── api.schema.ts  # Auto-generated — never edit manually
```

## Naming
- Components: `PascalCase` files (`EventModal.astro`, `ResourceForm.astro`).
- Pages/routes: `kebab-case` files (`dashboard.astro`, `[id].astro`).
- Functions: `camelCase`.
- CSS: Tailwind + DaisyUI utility classes — no custom CSS unless unavoidable.

## Types
- Always import from the generated schema:
  ```typescript
  import type { components } from '../types/generated/api.schema';
  type Business = components['schemas']['Business'];
  ```
- Use `Required<>` and `Omit<>` to derive variants — don't duplicate types.
- Never edit files inside `types/generated/` manually.

## Server Actions
```typescript
import { defineAction, ActionError } from 'astro:actions';

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

## Middleware
```typescript
import { defineMiddleware } from 'astro:middleware';

export const onRequest = defineMiddleware(async (context, next) => {
    // validate token, check permissions, redirect if unauthorized
    return next();
});
```

## API Client Pattern
```typescript
async function apiFetch<T>(endpoint: string, options: ApiOptions = {}): Promise<T> {
    const token = context.cookies.get('token')?.value;
    const res = await fetch(`${API_BASE_URL}${endpoint}`, {
        headers: { Authorization: `Bearer ${token}` },
        ...options,
    });
    if (!res.ok) throw new Error(await res.text());
    return res.json() as T;
}
```

## i18n
Use Astro's built-in i18n with locale JSON files. Messages in Spanish by default (`es.json`).
Keys follow `snake_case` namespaced by domain — see `base` skill.

## UI
- DaisyUI classes: `btn`, `modal`, `badge`, `alert`, `card`, etc.
- Lucide icons: `import Icon from '@lucide/astro/icons/icon-name'`.

## Type Generation Workflow
```bash
# Regenerate types after API changes
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
