# Contributing

## Adding a plugin

1. Scaffold a new plugin:
   ```bash
   bash scripts/scaffold.sh my-plugin
   ```
2. Edit `plugins/my-plugin/plugin.json` with description and author
3. Edit `plugins/my-plugin/skills/my-plugin-review/SKILL.md` with review instructions
4. Add examples to `plugins/my-plugin/examples/`
5. Add evaluation cases to `eval/cases/my-plugin-review/`
6. Run `bash scripts/validate.sh` to verify
7. Run `bash scripts/generate.sh` to regenerate marketplace files
8. Open a PR

See the [Plugin Author Guide](./docs/plugin-author-guide.md) for detailed instructions.

## Plugin name rules

- Lowercase ASCII letters, digits, and hyphens only
- 1 to 64 characters
- Must not start or end with a hyphen

## Manifest fields

Required:
- `name` ~ kebab-case identifier

Optional:
- `version` ~ semver string
- `description` ~ what the plugin does
- `author` ~ `{ "name": "...", "email": "...", "url": "..." }`
- `skills`, `commands`, `agents` ~ path or array of paths
- `hooks`, `mcpServers`, `lspServers` ~ path or inline JSON

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
