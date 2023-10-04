# asdf-nodejs [![Build](https://github.com/asdf-vm/asdf-nodejs/actions/workflows/workflow.yml/badge.svg)](https://github.com/asdf-vm/asdf-nodejs/actions/workflows/workflow.yml)

Node.js plugin for [asdf](https://github.com/asdf-vm/asdf) version manager

## Install

After installing [asdf](https://github.com/asdf-vm/asdf), install the plugin by running:

```bash
asdf plugin add nodejs https://github.com/asdf-vm/asdf-nodejs.git
```

## Use

Check [asdf](https://github.com/asdf-vm/asdf) readme for instructions on how to install & manage versions of Node.js at a system and project level.

Behind the scenes, `asdf-nodejs` utilizes [`node-build`](https://github.com/nodenv/node-build) to install pre-compiled binaries and compile from source if necessary. You can check its [README](https://github.com/nodenv/node-build/blob/master/README.md) for additional settings and some troubleshooting.

When compiling a version from source, you are going to need to install [all requirements for compiling Node.js](https://github.com/nodejs/node/blob/master/BUILDING.md#building-nodejs-on-supported-platforms) (be advised that different versions might require different configurations). That being said, `node-build` does a great job at handling edge cases and compilations rarely need a deep investigation.

### Configuration

`node-build` already has a [handful of settings](https://github.com/nodenv/node-build#custom-build-configuration), in additional to that `asdf-nodejs` has a few extra configuration variables:

- `ASDF_NODEJS_LEGACY_FILE_DYNAMIC_STRATEGY`: Enable and choose the strategy for
  dynamic/partial versions in legacy version files. Either `latest_installed` or
  `latest_available`. For more info check the [Partial and codename versions](#partial-and-codename-versions) section
- `ASDF_NODEJS_VERBOSE_INSTALL`: Enables verbose output for downloading and building. Any value different from empty is treated as enabled.
- `ASDF_NODEJS_FORCE_COMPILE`: Forces compilation from source instead of preferring pre-compiled binaries
- `ASDF_NODEJS_NODEBUILD_HOME`: Home for the node-build installation, defaults to `$ASDF_DIR/plugins/nodejs/.node-build`, you can install it in another place or share it with your system
- `ASDF_NODEJS_NODEBUILD`: Path to the node-build executable, defaults to `$ASDF_NODEJS_NODEBUILD_HOME/bin/node-build`
- `ASDF_NODEJS_SKIP_NODEBUILD_UPDATE`: Skip trying to update nodebuild prior to
  list-all and install. If enabling this var, you might need to [update nodebuild manually](#manually-updating-node-build-definitions)
  to get newly released versions
- `ASDF_NODEJS_CONCURRENCY`: How many jobs should be used in compilation. Defaults to half the computer cores
- `NODEJS_ORG_MIRROR`: (Legacy) overrides the default mirror used for downloading the distibutions, alternative to the `NODE_BUILD_MIRROR_URL` node-build env var

### `.nvmrc` and `.node-version` support

asdf uses a `.tool-versions` file for auto-switching between software versions. To ease migration, you can have it read an existing `.nvmrc` or `.node-version` file to find out what version of Node.js should be used. To do this, add the following to `$HOME/.asdfrc`:

```
legacy_version_file = yes
```

## Partial and codename versions

Many version managers allow you to use partial versions (e.g. `v10`) or NodeJS
codenames (e.g. `lts/hydrogen`) in version files, which are resolved at runtime.
However, this can be risky as it is not guaranteed that all developers will use
the same version, leading to non-reproducibility. In `asdf`, we prioritize
reproducibility, so you cannot use partial versions or codenames in a
`.tool-versions` file.

To address this, we offer an escape hatch for legacy version files. If you are
comfortable with non-reproducibility issues, you can choose between strategies
in a custom environment variable `ASDF_NODEJS_LEGACY_FILE_DYNAMIC_STRATEGY`. You
can export this variable from your shell rc file and it will become the default
behavior.

> **This option is only available for legacy version files (.nvmrc and
> .node-version, at the moment), for that you will need to set
> `legacy_version_file` to `yes` in your .asdfrc config file. More info on the
> [official docs](https://asdf-vm.com/manage/configuration.html#legacy-version-file)**
>
> The `.tool-versions` file will never support non-deterministic versions, if
> they were supported in the past that was an unintentional side-effect

The possible values for this variable are:

- `latest_installed`: Will get the latest version already installed that matches
  the version query. Just installing a new version that matches the dynamic
  version would be enough to update it. If no matching version is installed it
  fallbacks to the latest version available to download.
- `latest_available`: Will get the latest version available for installation
  that matches the version query, this means that when a new NodeJS version gets
  released you will need to install it before running any command

It is important to be aware of the risks of non-reproducibility. Debugging can
become more challenging and bugs may leak into production if the deployed node
version differs from the one used in development. Ideally, maintainers should be
encouraged to pin the version to a specific release to avoid these issues.

If non-reproducibility is not a concern for you, you can use one of the
following resolve scripts in your shell rc file:

```bash
export ASDF_NODEJS_LEGACY_FILE_DYNAMIC_STRATEGY=latest_installed
# OR
export ASDF_NODEJS_LEGACY_FILE_DYNAMIC_STRATEGY=latest_available
```

> **NOTE**: Partial versions and codenames only work for legacy version files: `.node-version` and `.nvmrc`.

### Default npm Packages

`asdf-nodejs` can automatically install a set of default set of npm package right after installing a Node.js version. To enable this feature, provide a `$HOME/.default-npm-packages` file that lists one package per line, for example:

```
lodash
request
express
```

You can specify a non-default location of this file by setting a `ASDF_NPM_DEFAULT_PACKAGES_FILE` variable.

### Running the wrapped node-build command

We provide a command for running the installed `node-build` command:

```bash
asdf nodejs nodebuild --version
```

### node-build advanced variations

`node-build` has some additional variations aside from the versions listed in `asdf list-all nodejs` (chakracore/graalvm branches and some others). As of now, we weakly support these variations. In the sense that they are available for install and can be used in a `.tool-versions` file, but we don't list them as installation candidates nor give them full attention.

Some of them will work out of the box, and some will need a bit of investigation to get them built. We are planning in providing better support for these variations in the future.

To list all the available variations run:

```bash
asdf nodejs nodebuild --definitions
```

_Note that this command only lists the current `node-build` definitions. You might want to [update the local `node-build` repository](#updating-node-build-definitions) before listing them._

### Manually updating node-build definitions

Every new node version needs to have a definition file in the `node-build` repository. `asdf-nodejs` already tries to update `node-build` on every new version installation, but if you want to update `node-build` manually for some reason we provide a command just for that:

```bash
asdf nodejs update-nodebuild
```

### Integrity/signature check

In the past `asdf-nodejs` checked for signatures and integrity by querying live keyservers. `node-build`, on the other hand, checks integrity by precomputing checksums ahead of time and versioning them together with the instructions for building them, making the process a lot more streamlined.

### Resolving latest available LTS version in a script

This plugin adds a custom subcommand `asdf nodejs resolve lts`. If you want to know what is the latest available LTS major version number you can do this:
```sh
# Before checking for aliases, update nodebuild to check for newly releasead versions
asdf nodejs update-nodebuild

asdf nodejs resolve lts
# outputs: 18.16.0
```
You also have the option of forcing a resolution strategy by using the flags `--latest-installed` and `--latest-available`
```bash
# Outputs the latest version installed locally which is a LTS
asdf nodejs resolve lts --latest-installed

# Outputs the latest version available for download which is a LTS
asdf nodejs resolve lts --latest-available
```
