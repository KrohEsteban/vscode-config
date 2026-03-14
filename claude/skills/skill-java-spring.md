# Skill: Java / Spring Boot

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
- Logger as instance field, initialized in constructor:
  ```java
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
- Checkstyle enforced — do not bypass.

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

### String Formatting
- Prefer `.formatted()` (Java 15+):
  ```java
  "Rows affected: %d.".formatted(rowsAffected)
  ```

### Exceptions
- Custom exception hierarchy with `@ResponseStatus` annotations.
- Broad exception signatures where needed: `throws IOException, InterruptedException, Exception`.
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
```java
@SpringBootTest
class MyServiceTest {
    @Mock
    private DataSource dataSource;

    @Test
    void shouldReturnEmptyWhenNoResults() {
        // given
        // when
        // then
        Assertions.assertEquals("expected", actual, "message".formatted(value));
    }
}
```

## CLI (via Docker)
```bash
docker compose -f .docker/compose.yaml run --rm cli gradle build
docker compose -f .docker/compose.yaml run --rm cli gradle test
docker compose -f .docker/compose.yaml run --rm cli gradle checkstyleMain
```
