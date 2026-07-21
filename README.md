# Palmshed Plugins

Official plugin marketplace for [Mull](https://github.com/palmshed/mull).

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

## Plugin structure

```
plugins/
  my-plugin/
    plugin.json              # or at .mull-plugin/plugin.json
    skills/
      my-skill/
        SKILL.md
    commands/
      deploy.md              # any .md file (name = filename stem)
    agents/
      reviewer.md            # any .md file (name = filename stem)
    hooks/
      hooks.json
    .mcp.json
```

- **Plugin name**: `[a-z0-9-]`, 1–64 chars, no leading/trailing hyphens
- **SKILL.md**: YAML frontmatter (`name`, `description`, `when-to-use`, `allowed-tools`, `paths`, etc.) + markdown body
- **Commands/agents**: Any `.md` file in the respective directory
- **Manifest fields**: `name` (required), `version`, `description`, `author`, `skills`, `commands`, `agents`, `hooks`, `mcpServers`, `lspServers` (all optional, camelCase)

## Resources

- [Mull docs](https://github.com/palmshed/mull)
- [Plugin manifest spec](https://github.com/palmshed/mull/tree/main/crates/codegen/mull-agent/src/plugins)
- [Marketplace index spec](https://github.com/palmshed/mull/tree/main/crates/codegen/mull-plugin-marketplace/src/index.rs)
- [Contributing](./CONTRIBUTING.md)
- [License](./LICENSE)
