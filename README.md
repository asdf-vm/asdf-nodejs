# asdf-nodejs

[![Build Status](https://travis-ci.org/asdf-vm/asdf-nodejs.svg?branch=master)](https://travis-ci.org/asdf-vm/asdf-nodejs)

Node.js plugin for [asdf](https://github.com/asdf-vm/asdf) version manager

## Install

Install the plugin:

```bash
asdf plugin-add nodejs https://github.com/asdf-vm/asdf-nodejs.git
```

## Use

Check [asdf](https://github.com/asdf-vm/asdf) readme for instructions on how to install & manage versions of Node.js.

Under the hood, asdf-nodejs uses [node-build](https://github.com/nodenv/node-build)
to build and install Node.js, check its [README](https://github.com/nodenv/node-build/blob/master/README.md)

### `.nvmrc` and `.node-version` files

asdf uses the `.tool-versions` for auto-switching between software versions. To ease migration, you can have it read an existing `.nvmrc` or `.node-version` file to find out what version of Node.js should be used. To do this, add the following to `$HOME/.asdfrc`:

```
legacy_version_file = yes
```

## Default npm Packages

asdf-nodejs can automatically install a set of default set of npm package right after installing a Node.js version. To enable this feature, provide a `$HOME/.default-npm-packages` file that lists one package per line, for example:

```
lodash
request
express
```
