shoreman
========

A shell implementation of the Procfile format.

## Install

### Standalone

Install as a standalone, change `~/bin/` to any other directory that's
in your `$PATH` if you wish.

```
curl https://raw.github.com/hecticjeff/shoreman/master/shoreman.sh -sLo ~/bin/shoreman && \
chmod 755 ~/bin/shoreman
```

### Homebrew

To install shoreman with homebrew use
[this gist](https://gist.github.com/1973792) with the following command:

```
brew install --HEAD https://gist.github.com/raw/1973792/e7e053623e9c9aaa52ef67afecc4391a65605629/shoreman.rb
```

## Usage

Head into a project that has a `Procfile` in it, then simply run the
`shoreman` command, it will read your Procfile, and start up the
processes it finds.

```
cd project-with-procfile
shoreman
```

## Todo

* Automatically assign a free port to processes.
* Add proper logging so it's clear what's coming from where.
* Add concurrency controls for process types.
* Support `.env` files.

## Credits

Inspired by the original [Foreman](https://github.com/ddollar/foreman)
by David Dollar (@ddollar) and [Norman](https://github.com/josh/norman) (foreman for
Node) by Josh Peek (@josh).

Copyright (c) Chris Mytton
