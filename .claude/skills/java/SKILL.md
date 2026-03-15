---
name: java
description: Java 17 / Spring Boot conventions: POJO, JDBC, Checkstyle, Gradle
---

## Stack
- Java 17, Spring Boot 3.x, Spring Web MVC, Spring Security
- Gradle (with dependency locking — `gradle.lockfile`)
- MySQL via JDBC (no JPA/Hibernate)
- JUnit 5 + Mockito for testing
- SLF4J + LoggerFactory for logging

## Project Structure
```
src/
├── main/java/com/app/
│   ├── configuration/    # @Configuration beans, DataSource, Security
│   ├── controllers/      # @RestController — HTTP layer only
│   ├── services/         # @Service — business logic
│   ├── repositories/     # @Repository — JDBC queries
│   ├── models/           # POJOs — no Lombok, no Records
│   ├── exceptions/       # Custom exception hierarchy
│   └── httpclient/       # External HTTP/SOAP integrations
└── test/java/com/app/    # mirrors main structure
```

## Coding Conventions

### Classes & Fields
- Manual POJOs: private fields + getters/setters. No `@Data`, no Lombok, no Records.
- Always use `this.` to access fields and call methods.
- Logger declaration — **match whatever the project already uses**:
  ```java
  // option A: static final (SLF4J standard, preferred for new projects)
  private static final Logger logger = LoggerFactory.getLogger(MyClass.class);

  // option B: instance field (if the existing codebase uses this, keep it)
  private Logger logger;
  public MyService(...) {
      this.logger = LoggerFactory.getLogger(MyService.class);
  }
  ```
- Conditional logging:
  ```java
  if (this.logger.isInfoEnabled()) {
      this.logger.info("...");
  }
  ```

### Constructors & Injection
- Constructor injection only — no `@Autowired` on fields.
- `@Value` for property injection.

### Formatting
- Line length max: **140 characters**.
- 4 spaces indentation (no tabs).
- Opening brace: newline for class/method declarations, end-of-line for control flow.
- One statement per line.
- One variable declaration per line.
- Empty blocks forbidden — including empty catch blocks.
- Checkstyle enforced — do not bypass.

### File Header
Every Java file must include the required license/copyright header. Checkstyle validates this — files without the header will fail the build.

### Imports
- No wildcard imports (`import java.util.*` is forbidden).
- No unused imports.
- No redundant imports.
- Import order enforced by Checkstyle — use IDE auto-sort or `gradle checkstyleMain` to verify.
- Package and import statements must be single-line (no line wrapping).

### Code Complexity
- Cyclomatic complexity is enforced by Checkstyle — keep methods simple and well-decomposed.
- Declaration order enforced: static fields → instance fields → constructors → methods.
- Overloaded methods must be declared consecutively.

### Null & Safety
- Yoda conditions:
  ```java
  if (null == user || user.trim().isEmpty()) { ... }
  "constant".equals(variable)
  ```
- Ternary for null-coalescing:
  ```java
  return null == this.data ? this.data = new Data() : this.data;
  ```

### Internationalization (i18n)
- All user-facing strings must be defined in `src/main/resources/messages.properties`.
- Inject via Spring's `MessageSource` — never hardcode text in Java classes.
  ```java
  private final MessageSource messageSource;

  public MyService(MessageSource messageSource) {
      this.messageSource = messageSource;
  }

  // usage
  this.messageSource.getMessage("appointment.not_available", null, locale);
  ```
- Key naming: `snake_case` namespaced by domain, matching the convention in the `base` skill.

### String Formatting
- Prefer `.formatted()` (Java 15+):
  ```java
  "Rows affected: %d.".formatted(rowsAffected)
  ```

### Exceptions
- Custom exception hierarchy with `@ResponseStatus` annotations.
- Exception signatures — **match what the project already uses**: prefer specific types (`throws IOException, InterruptedException`); use `throws Exception` only if the existing codebase does so consistently.
- Try-with-resources for all closeable resources.

## Spring Annotations
```java
@SpringBootApplication      // Entry point
@RestController             // HTTP endpoints
@Service                    // Business logic
@Repository                 // Data access
@Configuration              // Bean definitions
@ResponseStatus             // Custom HTTP codes on exceptions
@RequestMapping / @GetMapping / @PostMapping
@RequestHeader / @PathVariable / @RequestBody
```

## JDBC Pattern
```java
try (PreparedStatement stmt = connection.prepareStatement(SQL);
     ResultSet rs = stmt.executeQuery()) {
    while (rs.next()) {
        MyModel obj = new MyModel();
        obj.setField(rs.getString("COLUMN_NAME"));
        results.add(obj);
    }
}
```

## Testing Pattern

Unit tests (no Spring context needed):
```java
@ExtendWith(MockitoExtension.class)
class MyServiceTest {
    @Mock
    private MyRepository repository;

    @InjectMocks
    private MyService service;

    @Test
    void shouldReturnEmptyWhenNoResults() {
        // given
        // when
        // then
        Assertions.assertEquals("expected", actual, "message".formatted(value));
    }
}
```

Integration tests (full Spring context required):
```java
@SpringBootTest
class MyServiceIntegrationTest {
    // use only when testing wiring, DB, or HTTP layer end-to-end
}
```

## Test Coverage
- Minimum coverage threshold: **50%** (enforced by JaCoCo in CI — `java-test.yaml`).
- Coverage report: `build/reports/jacoco/test/html/index.html`.
- If the report file is missing, CI reports an error.
- Run locally to verify: `docker compose -f .docker/compose.yaml run --rm cli gradle test jacocoTestReport`

## CLI (via Docker)
```bash
docker compose -f .docker/compose.yaml run --rm cli gradle build
docker compose -f .docker/compose.yaml run --rm cli gradle test
docker compose -f .docker/compose.yaml run --rm cli gradle checkstyleMain
```
