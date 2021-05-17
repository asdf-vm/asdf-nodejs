# asdf-nodejs

[![Build Status](https://travis-ci.org/asdf-vm/asdf-nodejs.svg?branch=master)](https://travis-ci.org/asdf-vm/asdf-nodejs)

Node.js plugin for [asdf](https://github.com/asdf-vm/asdf) version manager

*The plugin properly validates OpenPGP signatures to check the authenticity of the package. Requires `gpg` to be available during package installs*

## Requirements


### macOS
* [GnuPG](http://www.gnupg.org) - `brew install gpg`
* awk - any posix compliant implementation (tested on gawk `brew install gawk`)

### Linux (Debian)

* [dirmngr](https://packages.debian.org/sid/dirmngr) - `apt-get install
  dirmngr`
* [GnuPG](http://www.gnupg.org) - `apt-get install gpg`
* [curl](https://curl.haxx.se) - `apt-get install curl`
* awk - any posix compliant implementation (tested on gawk `apt-get install gawk`)

## Install

After installing [asdf](https://github.com/asdf-vm/asdf), install the plugin by running:

```bash
asdf plugin-add nodejs https://github.com/asdf-vm/asdf-nodejs.git
```

We also support auto-reshimming of global npm package installations via a custom npm wrapper
For setting auto-reshiming, link the [wrapper file](./wrappers/bin/npm) somewhere into the path before the asdf shims directory, or simply add the following lines to your .bashrc/.zshrc configuration *after activating asdf*:

```
asdf list nodejs > /dev/null 2>&1 && \
    PATH="$(asdf nodejs wrappers-path):$PATH"
```

> **Explanation:**
> 
> Reshimming is the process of telling asdf to search for globally installed binaries, if we run `npm install -g typescript` we need to tell asdf to search for global installed binaries (), so that he can link them correctly with nodejs version changes,`tsc` the Typescript compiler will be found and shimmed by asdf in this example.
>
> This step is necessary because of the high dynamicity of nodejs version switching

## Use

Check [asdf](https://github.com/asdf-vm/asdf) readme for instructions on how to install & manage versions of Node.js.

When installing Node.js using `asdf install`, you can pass custom configure options with the following env vars:

* `NODEJS_CONFIGURE_OPTIONS` - use only your configure options
* `NODEJS_EXTRA_CONFIGURE_OPTIONS` - append these configure options along with ones that this plugin already uses
* `NODEJS_CHECK_SIGNATURES` - `strict` is default. Other values are `no` and `yes`. Checks downloads against OpenPGP signatures from the Node.js release team.
* `NODEJS_ORG_MIRROR` - official mirror `https://nodejs.org/dist/` is default. If you are in China, you can set it to `https://npm.taobao.org/mirrors/node/`.

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

## Problems with OpenPGP signatures in older versions

The plugin automatically imports the NodeJS release team's OpenPGP keys. If you are trying to install a previous release and facing any issue about verification, import the Node.js previous release team's OpenPGP keys to main keyring:

```bash
bash -c '${ASDF_DATA_DIR:=$HOME/.asdf}/plugins/nodejs/bin/import-previous-release-team-keyring'
```

## Using a dedicated OpenPGP keyring

The `bash` script mentioned in [the installation instructions](#install) (`import-release-team-keyring`) imports the OpenPGP public keys in your main OpenPGP keyring. However, you can also use a dedicated keyring in order to mitigate [this issue](https://github.com/nodejs/node/issues/9859).

To use a dedicated keyring, prepare the dedicated keyring and set it as the default keyring in the current shell:

```bash
export GNUPGHOME="${ASDF_DIR:-$HOME/.asdf}/keyrings/nodejs" && mkdir -p "$GNUPGHOME" && chmod 0700 "$GNUPGHOME"

# Imports Node.js release team's OpenPGP keys to the keyring
bash ~/.asdf/plugins/nodejs/bin/import-release-team-keyring
```

Again, if you used `brew` to manage the `asdf` installation use the following bash commands:

```bash
export GNUPGHOME="bash /usr/local/opt/asdf/keyrings/nodejs" && mkdir -p "$GNUPGHOME" && chmod 0700 "$GNUPGHOME"

# Imports Node.js release team's OpenPGP keys to the keyring
bash /usr/local/opt/asdf/plugins/nodejs/bin/import-release-team-keyring
```

#### Related notes

* [Verifying Node.js Binaries](https://github.com/nodejs/node#verifying-binaries).
* Only versions `>=0.10.0` are checked. Before that version, signatures for SHA2-256 hashes might not be provided (and can not be installed with the `strict` setting for that reason).

This behavior can be influenced by the `NODEJS_CHECK_SIGNATURES` env var which supports the following options:

* `strict` - (default): Check signatures/checksums and don’t operate on package versions which did not provide signatures/checksums properly (< 0.10.0).
* `no` - Do not check signatures/checksums
* `yes`- Check signatures/checksums if they should be present (enforced for >= 0.10.0)
