shoreman
========

A shell implementation of the Procfile format.

## Install

Install as a standalone.

```
curl https://raw.github.com/hecticjeff/shoreman/master/shoreman.sh -sLo ~/bin/shoreman && \
chmod 755 ~/bin/shoreman
```

To have an always up-to-date, bleeding edge, possibly broken
version available, you can use the folowing snippet in your `.bashrc`.

```shell
alias shoreman='sh -c "$(curl -fsSL https://raw.github.com/hecticjeff/shoreman/master/shoreman.sh)"'
```

## Usage

```
cd project-with-procfile
shoreman
```

## Credits

Inspired by the original [Foreman](https://github.com/ddollar/foreman)
by David Dollar (@ddollar) and [Norman](https://github.com/josh/norman) (foreman for
Node) by Josh Peek (@josh).

Copyright (c) Chris Mytton
