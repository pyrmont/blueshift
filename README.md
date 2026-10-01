# Blueshift

[![Test Status](https://github.com/pyrmont/blueshift/workflows/test/badge.svg)](https://github.com/pyrmont/blueshift/actions?query=workflow%3Atest)

Blueshift provides `blues`, a Wattle command-line utility that archives Bluesky
posts to a GitHub repository as Markdown files.

## Build

Building requires Zig 0.16.0 and Wattle, installed with its `<prefix>/share/wattle`
package (for example, by running `zig build -p ~/.local` in a Wattle checkout).
The build is declared in `info.edn`, so no `build.zig` is needed. `-p` gives
the Wattle install prefix, or set `WATTLE_PREFIX` instead:

```sh
git clone https://github.com/pyrmont/blueshift.git
cd blueshift
wattle -p ~/.local build exe --release fast
```

The executable is `zig-out/bin/blues`. It includes the native HTTP transport
and does not require a separate Wattle installation at runtime.

## Configure

Copy `config.example.edn` to `config.edn` and replace the example Bluesky
app password and GitHub token. `config.edn` is ignored by Git.

```clojure
{:ignore ["#private" "#draft"]
 :repost? false
 :quote-posts? false
 :date-format "iso8601"
 :time-offset "+0900"

 :bluesky {:handle "your-bluesky-handle"
           :password "your-app-password"}

 :github {:owner "your-github-username"
          :token "your-github-pat"
          :repo "your-repo-name"
          :posts-dir "src/_posts"}}
```

After uploading posts, `blues` records the creation time of the newest one as
`:last-fetch` in the configuration file and fetches only later posts on the
next run. Saving rewrites the file, so any comments in it are lost.

The GitHub token needs permission to read and write repository contents.
Bluesky app passwords can be created in [Bluesky settings][app-passwords];
fine-grained GitHub tokens can be created in [GitHub settings][github-tokens].

[app-passwords]: https://bsky.app/settings/app-passwords
[github-tokens]: https://github.com/settings/personal-access-tokens

## Use

Run `zig-out/bin/blues --help` for options. By default, the command reads
`config.edn` in the current directory. Use `-c PATH` to select another file.

To check configuration and output without calling either service:

```sh
zig-out/bin/blues -c config.example.edn -B -G
```

The [man page](man/man1/blues.1) describes the options and configuration.

## Test

Run the Wattle test files with a local Wattle executable:

```sh
wattle test
```

Run the tests from the project root, since `test/config.wattle` reads
`config.example.edn`. The argument parser and the test framework are vendored from
Wattle's Gum library in `deps/gum/`, with their licenses. JSON support comes from Wattle
itself.

## Bugs

Report issues in [GitHub Issues](https://github.com/pyrmont/blueshift/issues).

## License

Blueshift is licensed under the MIT License. See [LICENSE](LICENSE).
