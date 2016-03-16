# asdf-nodejs

Node.js plugin for [asdf](https://github.com/asdf-vm/asdf) version manager

## Install

```
asdf plugin-add nodejs https://github.com/asdf-vm/asdf-nodejs.git
```

## Use

Check [asdf](https://github.com/asdf-vm/asdf) readme for instructions on how to install & manage versions of Node.js.

When installing Node.js using `asdf install`, you can pass custom configure options with the following env vars:

* `NODEJS_CONFIGURE_OPTIONS` - use only your configure options
* `NODEJS_EXTRA_CONFIGURE_OPTIONS` - append these configure options along with ones that this plugin already uses
