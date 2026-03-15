---
name: go
description: Go / Gin conventions: pgx, JWT, Swaggo, Air, clean architecture
---

## Stack
- Go 1.23+, Gin v1.10+
- PostgreSQL 16 via pgx/v5 (no ORM)
- JWT (golang-jwt/jwt v5) for authentication
- Viper for configuration
- Testify for testing
- Swaggo for OpenAPI documentation
- Air for hot-reload in development

## Project Structure
```
internal/
├── app/          # App struct — wires all dependencies, registers routes
├── config/       # Viper-based config loader
├── db/           # pgx pool wrapper
├── models/       # Structs with JSON tags
├── repository/   # One file per entity — raw SQL queries
├── service/      # Business logic
├── controllers/  # Gin handlers — one Handler struct per domain
├── auth/         # JWT utilities
├── logger/       # Logging abstraction
├── usecase/      # Complex business flows (availability, booking)
└── webhook/      # External provider interfaces
```

## Coding Conventions

### Naming
- Packages: lowercase, short, single word (`repository`, `service`, `auth`).
- Types: PascalCase (`BusinessRepository`, `ChatService`).
- Interfaces: suffix with "er" or use descriptive noun (`IaProvider`, `Provider`).
- Constants: `SCREAMING_SNAKE_CASE` for exported, `camelCase` for unexported.
- JSON tags: `snake_case` for all model fields.

### Error Handling
- Always return explicit errors as second return value.
- Wrap with context: `return nil, fmt.Errorf("GetByID: %w", err)`
- Define domain errors as named variables in `internal/errors/errors.go` — never use ad-hoc `errors.New("string")` inline:
  ```go
  var (
      ErrNotFound    = errors.New("not found")
      ErrAccessDenied = errors.New("access denied")
      ErrInvalidInput = errors.New("invalid input")
  )
  ```
- HTTP layer translates domain errors to status codes via a centralized error middleware — never hardcode `http.Status*` responses scattered across handlers.
- Always `return` after responding in a handler.

### Authorization
- Authorization logic must live in middleware or a dedicated `internal/auth/` package — never inside handlers.
- Handlers extract identity from context; they do not make authorization decisions.

### Dependency Injection
- Constructor functions: `NewXxxService(deps...) *XxxService`.
- No global variables. No init() side effects.
- App struct holds all dependencies:
  ```go
  type App struct {
      db         *db.Database
      businessRepo *repository.BusinessRepository
      // ...
  }
  ```

### Repository Pattern
```go
type BusinessRepository struct {
    db *db.Database
}

func NewBusinessRepository(database *db.Database) *BusinessRepository {
    return &BusinessRepository{db: database}
}

func (r *BusinessRepository) GetByID(ctx context.Context, id int64) (*models.Business, error) {
    query := `SELECT id, name FROM businesses WHERE id = $1`
    var b models.Business
    err := r.db.Pool.QueryRow(ctx, query, id).Scan(&b.ID, &b.Name)
    if err != nil {
        return nil, fmt.Errorf("GetByID: %w", err)
    }
    return &b, nil
}
```

### Models
```go
type Business struct {
    ID        int64     `json:"id"`
    Name      string    `json:"name"`
    CreatedAt time.Time `json:"created_at"`
}
```

### Middleware
```go
protected := router.Group("/v1")
protected.Use(handler.AuthMiddleware())
protected.Use(handler.DemoRestrictionMiddleware())
```

## PostgreSQL Patterns
- Parameterized queries: `$1`, `$2`, etc.
- Connection pool via `pgxpool.New()`.
- Context on every query.
- Scan directly into struct fields.
- ENUM types for status fields.
- `TIMESTAMP WITH TIME ZONE` for all timestamps.

## Testing Pattern
```go
func TestGetByID(t *testing.T) {
    mockRepo := new(MockBusinessRepository)
    mockRepo.On("GetByID", mock.Anything, int64(1)).Return(&models.Business{ID: 1}, nil)

    svc := NewBusinessService(mockRepo)
    result, err := svc.GetByID(context.Background(), 1)

    assert.NoError(t, err)
    assert.Equal(t, int64(1), result.ID)
    mockRepo.AssertExpectations(t)
}
```

## Configuration
- All config via environment variables, loaded by Viper.
- `.env.example` documents all required variables.
- Never hardcode secrets — use `config.Get("DB_PASSWORD")`.

## Swagger
- Annotations on handler functions.
- Generate: `docker compose -f .docker/compose.yaml run --rm cli swag init -g internal/app/app.go`
- Frontend types regenerated from swagger.json via openapi-typescript.

## Spell Checking
- CSpell runs on all files in CI (`qa-spellcheck` job).
- If a technical term, package name, or abbreviation is not recognized, the job fails.
- Add unrecognized valid terms to `.cspell/project-terms.txt` — don't rename code to avoid spellcheck.

## CLI (via Docker)
```bash
docker compose -f .docker/compose.yaml run --rm cli go build ./...
docker compose -f .docker/compose.yaml run --rm cli go test ./...
docker compose -f .docker/compose.yaml run --rm cli swag init -g internal/app/app.go
```
