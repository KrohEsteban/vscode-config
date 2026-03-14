# vscode-config

Personal configuration repository for development tools.

## Structure

```
vscode-config/
├── vscode/
│   └── settings.json       # Cursor/VSCode settings (Neovim integration)
├── claude/
│   └── skills/
│       └── AGENTS.md       # Base skill: project standards & Docker execution rules
└── scripts/                # Setup/install scripts
```

## Setup

### VSCode / Cursor settings
Copy `vscode/settings.json` to:
- Linux: `~/.vscode/settings.json` or `~/.config/Cursor/User/settings.json`

### Claude skills
Copy `claude/skills/AGENTS.md` to the root of any project as `CLAUDE.md` or `AGENTS.md`.
