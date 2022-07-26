shoreman(1) ![CI](https://github.com/chrismytton/shoreman/workflows/CI/badge.svg?branch=master&event=push)
===========

A shell implementation of [Foreman](https://github.com/ddollar/foreman). Starts the process formations defined in a `Procfile`.

## Install

### macOS with Homebrew

    brew install chrismytton/formula/shoreman

### Standalone

Install as a standalone, change `~/bin/` to any other directory that's
in your `$PATH` if you wish.

```
curl https://github.com/chrismytton/shoreman/raw/master/shoreman.sh -sLo ~/bin/shoreman && \
chmod 755 ~/bin/shoreman
```

## Usage

Head into a project that has a `Procfile` in it, then simply run the
`shoreman` command. It will read your Procfile, and start up the
processes it finds. If there is a `.env` file in the directory then
environment variables will be read from it, as with foreman.

```
cd project-with-procfile
shoreman
```

## Running tests

Tests are written using [roundup](https://github.com/bmizerany/roundup).

To run the tests, go to the root of the repository then run `make`.

```
cd shoreman
make
```

## Annotated source code

There's a literate-programming-style annotated version of the source code available at https://www.chrismytton.uk/shoreman/.

### Generate documentation from source code

```
npm install -g docco
docco -l linear shoreman.sh
```

This puts the documentation in a `docs/` directory. You'll then need to manually
copy the contents of that directory over to the `gh-pages` branch and run
`mv shoreman.html index.html` in order to publish it to GitHub Pages.

## Projects using shoreman

- [dokku-shoreman](https://github.com/statianzo/dokku-shoreman) a plugin
  for [dokku](https://github.com/progrium/dokku) to allow it to run
  multiple process types.

## Contributors

See the [contributors](https://github.com/chrismytton/shoreman/graphs/contributors) section of GitHub Insights for this repository.

## Credits

Inspired by the original [Foreman](https://github.com/ddollar/foreman)
by David Dollar (@ddollar).

Copyright (c) Chris Mytton
