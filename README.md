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
    plugin.json
    skills/
      skill-name/
        SKILL.md
    commands/
      command-name/
        COMMAND.md
    agents/
      agent-name/
    hooks/
      hooks.json
    .mcp.json
```

## Resources

- [Mull docs](https://github.com/palmshed/mull)
- [Plugin manifest spec](https://github.com/palmshed/mull/tree/main/crates/codegen/mull-agent/src/plugins)
