# Releases and docs

Refines `~/.claude/rule-details/versioning-a-project.md` and `~/.claude/rule-details/writing-docs.md`.

- **REL1** The git tag is the version. A regenerated client from a new spec is a release of its own.
- **REL2** Every release prepends a `## vX.Y.Z, YYYY-MM-DD` section to `CHANGELOG.md`, naming the spec version and source when the client was regenerated. The annotated tag message is `vX.Y.Z`, a blank line, then that section.
- **REL3** `.agents/.codex-plugin/plugin.json` carries `version` and moves to the release version in the same commit. `.agents/.claude-plugin/plugin.json` has no `version`.
- **REL4** The agent skill in `.agents/skills/go-hubspot/` changes together with the generated method names it shows. After `make generate`, check every method and type it names still exists.
- **REL5** Commits, tags and pushes go through `git-update.sh` only. Tag pushes publish the skill to ClawHub through the `clawhub` job in `pipeline.yml`.
