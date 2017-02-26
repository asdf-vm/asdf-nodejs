# asdf-nodejs

Node.js plugin for [asdf](https://github.com/asdf-vm/asdf) version manager

## Requirements

+ _(MacOS)_ [GNU Core Utils](http://www.gnu.org/software/coreutils/coreutils.html˙˚) - `brew install coreutils`

## Install

```
asdf plugin-add nodejs https://github.com/asdf-vm/asdf-nodejs.git

# Import keys to check signature
gpg --keyserver pool.sks-keyservers.net --recv-keys 94AE36675C464D64BAFA68DD7434390BDBE9B9C5
gpg --keyserver pool.sks-keyservers.net --recv-keys FD3A5288F042B6850C66B31F09FE44734EB7990E
gpg --keyserver pool.sks-keyservers.net --recv-keys 71DCFD284A79C3B38668286BC97EC7A07EDE3FC1
gpg --keyserver pool.sks-keyservers.net --recv-keys DD8F2338BAE7501E3DD5AC78C273792F7D83545D
gpg --keyserver pool.sks-keyservers.net --recv-keys C4F0DFFF4E8C1A8236409D08E73BC641CC11F4C8
gpg --keyserver pool.sks-keyservers.net --recv-keys B9AE9905FFD7803F25714661B63B535A4C206CA9
gpg --keyserver pool.sks-keyservers.net --recv-keys 56730D5401028683275BD23C23EFEFE93C4CFFFE
```

## Bootstrap trust for signature validation

The plugin properly valides OpenPGP signatures.
All you have to do is to bootstrap the trust once as follows.

You can either import the OpenPGP public keys in your main OpenPGP keyring or use a dedicated keyring (recommended in order to mitigate https://github.com/nodejs/node/issues/9859).
If you decided to do the later, prepare the dedicated keyring and make it temporarily the default one in your current shell:

```Shell
export GNUPGHOME="$HOME/.asdf/keyrings/nodejs" && mkdir -p "$GNUPGHOME" && chmod 0700 "$GNUPGHOME"
```

Then import the OpenPGP public keys of the [Release Team](https://github.com/nodejs/node/#release-team) as documented on the linked page or run the `import-release-team-keyring` script which is bundled with this plugin.

For more details, refer to [Verifying Node.js Binaries](https://blog.continuation.io/verifying-node-js-binaries/).
Note that only versions greater or equal to 0.10.0 are checked. Before that version, signatures for SHA2-256 hashes might not be provided (and can not be installed with the `strict` setting for that reason).

This behavior can be influenced by the `NODEJS_CHECK_SIGNATURES` variable which supports the following options:

* `strict` - (default): Check signatures/checksums and don’t operate on package versions which did not provide signatures/checksums properly (< 0.10.0).
* `no` - Do not check signatures/checksums
* `yes`- Check signatures/checksums if they should be present (enforced for >= 0.10.0)

## Use

Check [asdf](https://github.com/asdf-vm/asdf) readme for instructions on how to install & manage versions of Node.js.

When installing Node.js using `asdf install`, you can pass custom configure options with the following env vars:

* `NODEJS_CONFIGURE_OPTIONS` - use only your configure options
* `NODEJS_EXTRA_CONFIGURE_OPTIONS` - append these configure options along with ones that this plugin already uses
