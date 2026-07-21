# Contributing

## Adding a plugin

1. Create a directory under `plugins/` with a kebab-case name
2. Add a `plugin.json` manifest with at least `name` and `description`
3. Add your components (skills, commands, agents, MCP servers)
4. Add a `README.md` and `CHANGELOG.md`
5. Run `bash scripts/generate.sh` to regenerate marketplace files
6. Run `bash scripts/validate.sh` to verify
7. Open a PR

## Plugin name rules

- Lowercase ASCII letters, digits, and hyphens only
- 1 to 64 characters
- Must not start or end with a hyphen

## Manifest fields

Required:
- `name` — kebab-case identifier

Optional:
- `version` — semver string
- `description` — what the plugin does
- `author` — `{ "name": "...", "email": "...", "url": "..." }`
- `skills`, `commands`, `agents` — path or array of paths
- `hooks`, `mcpServers`, `lspServers` — path or inline JSON

## Component conventions

| Type | Location | Key file |
|------|----------|----------|
| Skills | `skills/<name>/` | `SKILL.md` |
| Commands | `commands/` | Any `.md` file |
| Agents | `agents/` | Any `.md` file |
| Hooks | `hooks/` | `hooks.json` |
| MCP | plugin root | `.mcp.json` |

## SKILL.md format

```yaml
---
name: my-skill
description: What it does
when-to-use: When the user asks for X
allowed-tools:
  - Bash
  - Read
---

# Instructions

Your markdown body goes here.
```

## Testing locally

```bash
mull plugins add /path/to/plugins
```

## Code style

- No emojis in plugin content
- Keep descriptions under 120 characters
- Use kebab-case for all names
- Validate your manifest before submitting
