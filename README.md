# Palmshed Plugins

Official plugin marketplace for [Mull](https://github.com/palmshed/mull).

## Adding a plugin

1. Create a directory under `plugins/` with a kebab-case name
2. Add a `plugin.json` manifest and your plugin content (skills, commands, agents, etc.)
3. Register it in `.mull-plugin/marketplace.json`
4. Open a PR

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
