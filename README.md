# Blueshift

[![Latest Release](https://img.shields.io/github/v/release/pyrmont/blueshift)](https://github.com/pyrmont/blueshift/releases/latest)
[![Test Status](https://github.com/pyrmont/blueshift/workflows/test/badge.svg)](https://github.com/pyrmont/blueshift/actions?query=workflow%3Atest)

Blueshift provides `blues`, a command-line utility to archive your Bluesky
posts to a GitHub repository as Markdown files.

## Requirements

Blueshift uses the `curl` command-line utility to communicate with the Bluesky
servers. It must be on the PATH of the user that runs `blues`.

## Installing

### Jeep

If you use Janet, you can install `blues` using [Jeep][]:

[Jeep]: https://github.com/pyrmont/jeep

```
$ jeep install https://github.com/pyrmont/blueshift
```

### From Source

To build the `blues` binary from source, you need [Janet][] installed on your
system. Then run:

[Janet]: https://janet-lang.org

```shell
$ git clone https://github.com/pyrmont/blueshift
$ cd blueshift
$ git tag --sort=creatordate
$ git checkout <version> # check out the latest tagged version
$ janet --install .
```

## Configuring

Blueshift looks for your credentials for Bluesky and GitHub in the
configuration file. By default, this is `config.toml` in the current working
directory and will look like this:

```toml
[bluesky]
handle = "your-bluesky-handle"
password = "your-app-password"

[github]
owner = "your-github-username"
token = "your-github-pat"
repo = "your-repo-name"
posts-dir = "src/_posts"
```

### Bluesky

Create an app password:

1. navigate to Bluesky's [App Passwords][ap] page
2. click or tap on 'Add App Password'
3. add the generated password to `config.toml`

[ap]: https://bsky.app/settings/app-passwords

### GitHub

Create a fine-grained personal access token:

1. log in to GitHub's [Personal Access Tokens][pat] page
2. click or tap on 'Generate new token'
3. ensure that read/write permissions for 'content' of the repository are selected
4. add the generated token to `config.toml`

[pat]: https://github.com/settings/personal-access-tokens

## Using

Run `blues --help` for usage information. The command-line arguments are
explained in more detail in the [man page][].

[man page]: man/man1/blues.1.predoc

## Bugs

Found a bug? I'd love to know about it. The best way is to report your bug in
the [Issues][] section on GitHub.

[Issues]: https://github.com/pyrmont/blueshift/issues

## Licence

Blueshift is licensed under the MIT Licence. See [LICENSE][] for more details.

[LICENSE]: https://github.com/pyrmont/blueshift/blob/master/LICENSE
