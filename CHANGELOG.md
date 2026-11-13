# Changelog

Each release lists what changed since the release before it. The changes made
since the most recent release are under Unreleased.

## Unreleased

- Port Blueshift from Janet to Wattle. Blueshift is built from source with Zig
  and Wattle, and the executable includes the runtime. Requests are made by a
  native HTTP module, so `curl` is no longer needed.
- Read the configuration from an EDN file, `config.edn` by default, instead of
  a TOML file. `:last-fetch` is stored as an ISO 8601 string. Updating it
  rewrites the file, so comments are not preserved.
- Add `--version` (`-v`), which prints the version and exits.
- Add release builds for macOS (aarch64) and Linux (aarch64 and x86-64), and a
  Homebrew formula.
- Add this changelog. The notes of each GitHub release are its section of
  `CHANGELOG.md`, and the archives of a release include the file.
