# Blueshift

[![Latest Release](https://img.shields.io/github/v/release/pyrmont/blueshift)](https://github.com/pyrmont/blueshift/releases/latest)
[![Test Status](https://github.com/pyrmont/blueshift/workflows/test/badge.svg)](https://github.com/pyrmont/blueshift/actions?query=workflow%3Atest)

Blueshift provides `blues`, a command-line utility to archive your Bluesky
posts to a GitHub repository as Markdown files.

```
Usage: blues [--config <path>] [--echo] [--ignore <text>] [--limit <number>]
             [--quiet] [--since <date>] [--update]

Archive Bluesky posts to a GitHub repository as Markdown files.

Options:

 -c, --config <path>     EDN config file. (Default: config.edn)
 -e, --echo              Print generated Markdown.
 -i, --ignore <text>     Ignore posts containing text.
 -l, --limit <number>    Maximum posts to fetch.
 -q, --quiet             Suppress progress output.
 -s, --since <date>      Fetch posts after date.
 -u, --update            Set last-fetch to the current time.
 -v, --version           Show version information.

 -h, --help              Show this help message.
```

## Installing

### Homebrew

The latest release of `blues` is available via Homebrew for macOS (Apple
Silicon) and Linux (x86-64 and aarch64):

```
$ brew tap pyrmont/blueshift https://github.com/pyrmont/blueshift
$ brew install blues
```

### Pre-Built

Pre-built binaries of `blues` are available as tarballs via the
[Releases][github-releases] section on GitHub for:

- Linux (x86-64 and aarch64)
- macOS (aarch64)

[github-releases]: https://github.com/pyrmont/blueshift/releases

```shell
$ curl -LO https://github.com/pyrmont/blueshift/releases/latest/download/blueshift-v<version>-<platform>-<arch>.tar.gz
$ tar -xzf blueshift-v<version>-<platform>-<arch>.tar.gz
$ cd blueshift-v<version>
# use sudo or doas depending on the permissions of the target directories
$ sudo cp blues /usr/local/bin/ # or somewhere else on your PATH
$ sudo cp blues.1 /usr/local/share/man/man1/ # or somewhere else on your MANPATH
```

### From Source

Blueshift is written in [Wattle][]. To build the `blues` binary from source,
you need Zig 0.17.1 and Wattle, installed with its `<prefix>/share/wattle`
package (for example, by running `zig build -p ~/.local` in a Wattle checkout).
`-p` gives the Wattle install prefix, or set `WATTLE_PREFIX` instead:

[Wattle]: https://github.com/pyrmont/wattle

```shell
$ git clone https://github.com/pyrmont/blueshift
$ cd blueshift
$ git tag --sort=creatordate
$ git checkout <version> # check out the latest tagged version
$ wattle -p ~/.local build exe --release fast
```

The executable is `zig-out/bin/blues`. It includes the Wattle runtime and does
not require Wattle or any other program at runtime.

## Configuring

Blueshift looks for your credentials for Bluesky and GitHub in the
configuration file. By default, this is `config.edn` in the current working
directory. Copy `config.example.edn` to `config.edn` and replace the example
values:

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

## Using

Run `blues --help` for usage information. The command-line arguments and the
configuration file are explained in more detail in the [man page][].

[man page]: https://github.com/pyrmont/blueshift/blob/master/man/man1/blues.1

To check the configuration and output without calling either service:

```shell
$ blues -c config.example.edn --no-bluesky --no-github
```

## Testing

Build the executable and the native HTTP module, then run the tests from the
project root:

```shell
$ wattle build exe
$ wattle build lib
$ wattle test
```

The argument parser and the test framework are vendored from Wattle's Gum
library in `deps/gum/`, with their licences.

## Versioning

Blueshift uses the label `DEVEL` during development. When a new version is
released, a tag is created for that version in the repository. The changes in
each release are listed in [CHANGELOG.md][changelog].

[changelog]: https://github.com/pyrmont/blueshift/blob/master/CHANGELOG.md

## Bugs

Found a bug? I'd love to know about it. The best way is to report your bug in
the [Issues][] section on GitHub.

[Issues]: https://github.com/pyrmont/blueshift/issues

## Licence

Blueshift is licensed under the MIT Licence. See [LICENSE][] for more details.

[LICENSE]: https://github.com/pyrmont/blueshift/blob/master/LICENSE
