# asdf-nodejs

[![Build Status](https://travis-ci.org/asdf-vm/asdf-nodejs.svg?branch=master)](https://travis-ci.org/asdf-vm/asdf-nodejs)

Node.js plugin for [asdf](https://github.com/asdf-vm/asdf) version manager

*The plugin properly validates OpenPGP signatures to check the authenticity of the package. Requires `gpg` to be available during package installs*

## Requirements

* _(MacOS)_ [GNU Core Utils](http://www.gnu.org/software/coreutils/coreutils.html) - `brew install coreutils`
* _(MacOS)_ [GnuPG](http://www.gnupg.org) - `brew install gpg`

## Install

Install the plugin:

```bash
asdf plugin-add nodejs https://github.com/asdf-vm/asdf-nodejs.git
```

Import the Node.js release team's OpenPGP keys to main keyring:

```bash
bash ~/.asdf/plugins/nodejs/bin/import-release-team-keyring
```

## Use

Check [asdf](https://github.com/asdf-vm/asdf) readme for instructions on how to install & manage versions of Node.js.

When installing Node.js using `asdf install`, you can pass custom configure options with the following env vars:

* `NODEJS_CONFIGURE_OPTIONS` - use only your configure options
* `NODEJS_EXTRA_CONFIGURE_OPTIONS` - append these configure options along with ones that this plugin already uses
* `NODEJS_CHECK_SIGNATURES` - `strict` is default. Other values are `no` and `yes`. Checks downloads against OpenPGP signatures from the Node.js release team.

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

## Using a dedicated OpenPGP keyring

The `gpg` commands above imports the OpenPGP public keys in your main OpenPGP keyring. However, you can also use a dedicated keyring in order to mitigate [this issue](https://github.com/nodejs/node/issues/9859).

To use a dedicated keyring, prepare the dedicated keyring and set it as the default keyring in the current shell:

```bash
export GNUPGHOME="${ASDF_DIR:-$HOME/.asdf}/keyrings/nodejs" && mkdir -p "$GNUPGHOME" && chmod 0700 "$GNUPGHOME"

# Imports Node.js release team's OpenPGP keys to the keyring
bash ~/.asdf/plugins/nodejs/bin/import-release-team-keyring
```

#### Related notes

* [Verifying Node.js Binaries](https://blog.continuation.io/verifying-node-js-binaries/).
* Only versions `>=0.10.0` are checked. Before that version, signatures for SHA2-256 hashes might not be provided (and can not be installed with the `strict` setting for that reason).

This behavior can be influenced by the `NODEJS_CHECK_SIGNATURES` env var which supports the following options:

* `strict` - (default): Check signatures/checksums and don’t operate on package versions which did not provide signatures/checksums properly (< 0.10.0).
* `no` - Do not check signatures/checksums
* `yes`- Check signatures/checksums if they should be present (enforced for >= 0.10.0)
