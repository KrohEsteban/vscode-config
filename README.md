# vscode-config

Personal configuration repository for development tools.

## Structure

```
vscode-config/
├── vscode/
│   └── settings.json           # Cursor/VSCode settings (Neovim integration)
├── claude/
│   └── skills/
│       ├── AGENTS.md           # Base skill: rules for all projects
│       ├── skill-java-spring.md  # Java 17 / Spring Boot conventions
│       ├── skill-go-gin.md     # Go / Gin conventions
│       └── skill-frontend.md   # Next.js / Astro / TypeScript conventions
└── scripts/                    # Setup/install scripts
```

## Skills Usage

Copy the relevant skill files to the root of a project as `CLAUDE.md` or `AGENTS.md`:

- **All projects**: always include `AGENTS.md` (base rules)
- **Java/Spring projects**: add `skill-java-spring.md`
- **Go/Gin projects**: add `skill-go-gin.md`
- **Frontend projects**: add `skill-frontend.md`

## Setup

### VSCode / Cursor settings
Copy `vscode/settings.json` to:
- Linux: `~/.vscode/settings.json` or `~/.config/Cursor/User/settings.json`
