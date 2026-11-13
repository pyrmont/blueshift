# Changelog

Each release lists what changed since the release before it. The changes made
since the most recent release are under Unreleased.

## Unreleased

- Initial release. `blues` fetches a user's Bluesky posts, converts them to
  Markdown files with YAML frontmatter and uploads them to a GitHub
  repository. It skips replies, posts beginning with '@' and, unless the
  configuration includes them, reposts and quote posts. The configuration is
  an EDN file, `config.edn` by default, which records when posts were last
  fetched so that each run uploads only new posts.
- Pre-built executables are available for macOS (aarch64) and Linux (aarch64
  and x86-64), and through a Homebrew formula. They include the Wattle runtime
  and need no other programs.
