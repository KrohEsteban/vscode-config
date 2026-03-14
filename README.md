# vscode-config

Personal configuration repository for development tools.

## Structure

```
vscode-config/
├── vscode/
│   └── settings.json           # Cursor/VSCode settings (Neovim integration)
├── .claude/
│   └── skills/
│       ├── base/SKILL.md       # Base rules for all projects
│       ├── java/SKILL.md       # Java 17 / Spring Boot
│       ├── go/SKILL.md         # Go / Gin
│       ├── frontend/SKILL.md   # Next.js / Astro / TypeScript
│       └── cicd/SKILL.md       # CI/CD, commit format, quality gates
└── scripts/
    └── setup-project.sh        # Interactive installer
```

Each skill is a `SKILL.md` with Claude Code frontmatter (`name`, `description`), ready to be
installed natively in Claude Code or adapted for Gemini/Kiro by the install script.

## Install skills into a project

```bash
./scripts/setup-project.sh
```

The script asks interactively:
1. **Project path** — where to install
2. **Target tool** — `.claude/` (Claude Code), `.gemini/` (Gemini CLI), `.kiro/` (Kiro)
3. **Skills to install** — numbered list, pick one or many (ENTER = all)

| Tool | Output |
|------|--------|
| Claude Code | `.claude/skills/<name>/SKILL.md` (native, invocable as `/<name>`) |
| Gemini CLI | `.gemini/GEMINI.md` (concatenated) |
| Kiro | `.kiro/steering/<name>.md` |

## Setup

### VSCode / Cursor settings
Copy `vscode/settings.json` to:
- Linux: `~/.vscode/settings.json` or `~/.config/Cursor/User/settings.json`
