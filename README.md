# asdf-nodejs

Node.js plugin for [asdf](https://github.com/asdf-vm/asdf) version manager

## Install

```
asdf plugin-add nodejs https://github.com/asdf-vm/asdf-nodejs.git
```

## Bootstrap trust for signature validation

The plugin properly valides OpenPGP signatures, which is not yet done in any
other NodeJS version manager as of 2017-02. All you have to do is to bootstrap
the trust once as follows.

You can either import the OpenPGP public keys in your main OpenPGP keyring or use a dedicated keyring (recommended).
If you decided to do the later, prepare the dedicated keyring and make it temporarily the default one in your current shell:

```Shell
export GNUPGHOME="$HOME/.asdf/keyrings/nodejs" && mkdir -p "$GNUPGHOME" && chmod 0700 "$GNUPGHOME"
```

Then import the OpenPGP public keys of the [Release Team](https://github.com/nodejs/node/#release-team).

For more details, refer to [Verifying Node.js Binaries](https://blog.continuation.io/verifying-node-js-binaries/).
Note that only versions greater or equal to 0.10.0 are checked. Before that version, signatures for SHA2-256 hashes might not be provided.

This behavior can be influenced by the `NODEJS_CHECK_SIGNATURES` variable which supports the following options:

`no`: Do not check signatures/checksums.
`yes`: Check signatures/checksums if they should be present (enforced for >= 0.10.0).
`strict` (default): Check signatures/checksums and don’t operate on package versions which did not provide signatures/checksums properly (< 0.10.0).

## Use

Check [asdf](https://github.com/asdf-vm/asdf) readme for instructions on how to install & manage versions of Node.js.

When installing Node.js using `asdf install`, you can pass custom configure options with the following env vars:

* `NODEJS_CONFIGURE_OPTIONS` - use only your configure options
* `NODEJS_EXTRA_CONFIGURE_OPTIONS` - append these configure options along with ones that this plugin already uses
