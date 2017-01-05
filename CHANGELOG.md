# idearium-lib

This file is a history of the changes made to idearium-lib.

## 1.0.0-alpha.2

### Breaking changes

- Will no longer read environment specific configuration files such as `config.development.json` or `config.production.json`.

### Features

- Updated to a more simple `config` directory format. It will now only attempt to load one file `./config/config.js`. This file should contain defaults setup for the `development` environment. All other environment specific configuration changes should be made through ENV variables.

## 1.0.0-alpha.1

Initial commit of the library, based off `focusbooster-lib`.