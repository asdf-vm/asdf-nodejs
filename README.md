# asdf-nodejs

[![Build Status](https://travis-ci.org/asdf-vm/asdf-nodejs.svg?branch=master)](https://travis-ci.org/asdf-vm/asdf-nodejs)

Node.js plugin for [asdf](https://github.com/asdf-vm/asdf) version manager

## About

Under the hood, asdf-nodejs will install if missing and use [node-build](https://github.com/nodenv/node-build) that will by default fetch ready made binaries.

## Requirements

### macOS
* Batteries included!

### Linux
* `curl`, `wget` or `aria2c` - `apt-get install curl`
* `openssl`, `shasum`, or `sha256sum`

## Install

Install the plugin:

```bash
asdf plugin-add nodejs https://github.com/asdf-vm/asdf-nodejs.git
```


## Use

To build from source, make sure [all requisite libraries](https://github.com/nodejs/node/blob/master/BUILDING.md#unix-and-macos) are available.

When installing Node.js using `asdf install`, you can pass custom configure options with the following env vars:

#### Building from source
* `NODE_CONFIGURE_OPTS`     - `./configure`
* `NODE_MAKE_OPTS`          - `make`
* `NODE_MAKE_INSTALL_OPTS`  - `make install`

And additional [build options](https://github.com/nodenv/node-build#custom-build-configuration).

#### Additional options
* `ASDF_NPM_DEFAULT_PACKAGES_FILE` - Defaults `default-npm-packages`
* `ASDF_SKIP_RESHIM`               - Defaults to 1, for skipping reshim on installs.
* `ASDF_NODE_BUILD_VERSION`        - Defaults to `v4.9.33`
* `ASDF_NODE_BUILD_MIRROR_URL`     - Defaults to official mirror `https://nodejs.org/dist/`.

If you are in China, you can set it to `ASDF_NODE_BUILD_MIRROR_URL=https://npm.taobao.org/mirrors/node/`.


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

You can specify a non-default location of this file by setting a `ASDF_NPM_DEFAULT_PACKAGES_FILE` variable.

## Temporarily disable reshimming

To avoid a slowdown when installing large packages (see https://github.com/asdf-vm/asdf-nodejs/issues/46), you can `ASDF_SKIP_RESHIM=1 npm i -g <package>` and reshim after installing all packages using `asdf reshim nodejs`.

## Checksum Verification
node-build will attempt to construct a mirror url by invoking `NODE_BUILD_MIRROR_CMD` with two arguments: `package_url` and `checksum`. If `NODE_BUILD_MIRROR_CMD` is unset, package mirror URL construction defaults to replacing `https://nodejs.org/dist` with `NODE_BUILD_MIRROR_URL`.

node-build will first try to fetch this package from `$NODE_BUILD_MIRROR_URL/<SHA2>` (note: this is the complete URL), where `<SHA2>` is the checksum for the file.

It will fall back to downloading the package from the original location if:

* the package was not found on the mirror;
* the mirror is down;
* the download is corrupt, i.e. the file's checksum doesn't match;
* no tool is available to calculate the checksum; or
* `NODE_BUILD_SKIP_MIRROR` is enabled.

You may specify a custom mirror by setting NODE_BUILD_MIRROR_URL.


#### Related notes

* [Verifying Node.js Binaries](https://github.com/nodenv/node-build#checksum-verification).
* Only versions `>=0.10.0` are checked. Before that version, signatures for SHA2-256 hashes might not be provided (and can not be installed with the `strict` setting for that reason).
