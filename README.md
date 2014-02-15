# shoreman(1)

A shell implementation of the Procfile format.

[![Build Status](https://travis-ci.org/hecticjeff/shoreman.png?branch=master)](https://travis-ci.org/hecticjeff/shoreman)

## Install

### Standalone

Install as a standalone, change `~/bin/` to any other directory that's
in your `$PATH` if you wish.

```
curl https://github.com/hecticjeff/shoreman/raw/master/shoreman.sh -sLo ~/bin/shoreman && \
chmod 755 ~/bin/shoreman
```

### Homebrew

    brew install --HEAD hecticjeff/formula/shoreman

## Usage

Head into a project that has a `Procfile` in it, then simply run the
`shoreman` command, it will read your Procfile, and start up the
processes it finds. If there is a `.env` file in the directory then
environment variables will be read from it, as with foreman.

```
cd project-with-procfile
shoreman
```

## Running tests

Tests are written using [roundup](http://bmizerany.github.com/roundup/)
which is downloaded using `curl` on every test run.

To run the tests, go to the root of the repository then run `make`.

```
cd shoreman
make
```

### Manually running tests

If you're on a mac then you should be able to run `brew update && brew install roundup`
to install roundup locally. Then you can run the tests from the root of
the repository.

```
cd shoreman
roundup test/shoreman_test.sh
```

## Projects using shoreman

- [dokku-shoreman](https://github.com/statianzo/dokku-shoreman) a plugin
  for [dokku](https://github.com/progrium/dokku) to allow it to run
  multiple process types.

## Todo

* Automatically assign a free port to processes.
* Add proper logging so it's clear what's coming from where.
* Add concurrency controls for process types.

## Contributors

* Chris Mytton ([@hecticjeff](https://github.com/hecticjeff))
* Mickael Riga ([@mig-hub](https://github.com/mig-hub))

## Credits

Inspired by the original [Foreman](https://github.com/ddollar/foreman)
by David Dollar (@ddollar) and [Norman](https://github.com/josh/norman) (foreman for
Node) by Josh Peek (@josh).

Copyright (c) Chris Mytton
